/**
 * Cloud Functions — Gemini 4-cut scenario + panel image generation.
 * GEMINI_API_KEY is injected via Firebase Secrets (never in client code).
 */
import { randomUUID } from "node:crypto";
import { GoogleGenAI } from "@google/genai";
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { setGlobalOptions } from "firebase-functions/v2";

initializeApp();
setGlobalOptions({ region: "asia-northeast3" });

const geminiApiKey = defineSecret("GEMINI_API_KEY");

/** Text scenario models. */
const MODEL_CANDIDATES = [
  "gemini-3.6-flash",
  "gemini-3-flash-preview",
  "gemini-flash-latest",
  "gemini-3.1-flash-lite",
];

/** Native image models (require billing on many keys; Pollinations is fallback). */
const IMAGE_MODEL_CANDIDATES = [
  "gemini-2.5-flash-image",
  "gemini-3.1-flash-image",
  "gemini-3.1-flash-lite-image",
];

const PANEL_LABELS = ["아침", "낮", "저녁", "밤"];

const COMIC_STYLE = `Warm soft Korean webtoon / 4-cut diary comic illustration.
Same gentle young character across panels: soft brown hair, cozy knit sweater, kind expression.
Pastel peach and rose palette, soft lighting, cozy atmosphere.
Single comic panel, square composition, no speech bubbles, no captions, no text, no watermark, no border.`;

function buildPrompt(diaryText) {
  return `당신은 따뜻하고 감성적인 4컷 만화 시나리오 작가입니다.
사용자가 쓴 일기를 바탕으로 반드시 장면 4개짜리 만화 시나리오를 만드세요.

규칙:
- 출력은 JSON만 (설명/마크다운 금지)
- panels 배열 길이는 정확히 4
- 각 장면 description은 1~2문장, 한국어, 그림으로 그리기 쉬운 구체적 장면
- 하루의 흐름(시작→전개→절정/감정→마무리)을 자연스럽게

일기:
"""
${diaryText}
"""

JSON 형식:
{"title":"짧은 제목","panels":[{"index":1,"description":"..."},{"index":2,"description":"..."},{"index":3,"description":"..."},{"index":4,"description":"..."}]}`;
}

function buildImagePrompt(description, panelIndex) {
  return `${COMIC_STYLE}
Panel ${panelIndex} of 4.
Scene to illustrate: ${description}`;
}

function extractJson(text) {
  if (!text || typeof text !== "string") {
    throw new Error("Empty model output");
  }
  const trimmed = text.trim();
  const fence = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/i);
  const raw = fence ? fence[1].trim() : trimmed;
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");
  if (start < 0 || end < 0) {
    throw new Error("No JSON object in model output");
  }
  return JSON.parse(raw.slice(start, end + 1));
}

function normalizePanels(parsed) {
  const panels = Array.isArray(parsed?.panels) ? parsed.panels : [];
  if (panels.length !== 4) {
    throw new Error(`Expected 4 panels, got ${panels.length}`);
  }
  return panels.map((p, i) => {
    const description = String(p.description ?? p.text ?? p.caption ?? "").trim();
    if (!description) {
      throw new Error(`Panel ${i + 1} missing description`);
    }
    return {
      index: i + 1,
      description,
      label: PANEL_LABELS[i],
    };
  });
}

function toResult(model, outputText) {
  const parsed = extractJson(outputText);
  const panels = normalizePanels(parsed);
  return {
    model,
    title: String(parsed.title ?? "오늘의 4컷 일기").trim() || "오늘의 4컷 일기",
    panels,
    rawText: outputText,
  };
}

async function generateWithContent(ai, model, prompt) {
  const response = await ai.models.generateContent({
    model,
    contents: prompt,
  });
  const outputText = response.text ?? "";
  if (!outputText.trim()) {
    throw new Error("Empty generateContent response");
  }
  return toResult(model, outputText);
}

async function generateWithInteractions(ai, model, prompt) {
  const interaction = await ai.interactions.create({
    model,
    input: prompt,
  });
  const outputText = interaction.output_text ?? "";
  if (!outputText.trim()) {
    throw new Error("Empty interactions response");
  }
  return toResult(model, outputText);
}

async function callGemini(diaryText, apiKey) {
  const ai = new GoogleGenAI({ apiKey });
  const prompt = buildPrompt(diaryText);

  let lastError;
  for (const model of MODEL_CANDIDATES) {
    try {
      return await generateWithContent(ai, model, prompt);
    } catch (err) {
      lastError = err;
      console.warn(`generateContent failed: ${model}`, err?.message ?? err);
    }
    try {
      return await generateWithInteractions(ai, model, prompt);
    } catch (err) {
      lastError = err;
      console.warn(`interactions failed: ${model}`, err?.message ?? err);
    }
  }
  throw lastError ?? new Error("All Gemini models failed");
}

function extractInlineImage(response) {
  const parts = response?.candidates?.[0]?.content?.parts ?? response?.parts ?? [];
  for (const part of parts) {
    const data = part?.inlineData?.data ?? part?.inline_data?.data;
    const mimeType =
      part?.inlineData?.mimeType ??
      part?.inline_data?.mime_type ??
      "image/png";
    if (data) {
      return {
        buffer: Buffer.from(data, "base64"),
        mimeType: String(mimeType),
      };
    }
  }
  return null;
}

async function generatePanelWithGemini(ai, prompt) {
  let lastError;
  for (const model of IMAGE_MODEL_CANDIDATES) {
    try {
      const response = await ai.models.generateContent({
        model,
        contents: prompt,
        config: { responseModalities: ["Image"] },
      });
      const image = extractInlineImage(response);
      if (image) {
        return { ...image, provider: model };
      }
      lastError = new Error(`No image bytes from ${model}`);
    } catch (err) {
      lastError = err;
      console.warn(`image gen failed: ${model}`, err?.message ?? err);
    }
  }
  throw lastError ?? new Error("Gemini image generation failed");
}

async function generatePanelWithPollinations(prompt) {
  const url =
    "https://image.pollinations.ai/prompt/" +
    encodeURIComponent(prompt) +
    "?width=768&height=768&nologo=true&model=flux&enhance=true";
  const res = await fetch(url, {
    redirect: "follow",
    headers: { Accept: "image/*" },
  });
  if (!res.ok) {
    throw new Error(`Pollinations HTTP ${res.status}`);
  }
  const mimeType = res.headers.get("content-type") || "image/jpeg";
  const buffer = Buffer.from(await res.arrayBuffer());
  if (buffer.length < 1000) {
    throw new Error("Pollinations returned empty image");
  }
  return { buffer, mimeType, provider: "pollinations-flux" };
}

async function generatePanelImage(ai, description, panelIndex) {
  const prompt = buildImagePrompt(description, panelIndex);
  try {
    return await generatePanelWithGemini(ai, prompt);
  } catch (err) {
    console.warn(
      `Gemini image unavailable for panel ${panelIndex}, using fallback`,
      err?.message ?? err,
    );
    return generatePanelWithPollinations(prompt);
  }
}

function extForMime(mimeType) {
  if (mimeType.includes("webp")) return "webp";
  if (mimeType.includes("jpeg") || mimeType.includes("jpg")) return "jpg";
  return "png";
}

async function uploadPanelImage({
  bucket,
  publicId,
  comicId,
  panelIndex,
  buffer,
  mimeType,
}) {
  const ext = extForMime(mimeType);
  const storagePath = `comics/${publicId}/${comicId}/panel_${panelIndex}.${ext}`;
  const token = randomUUID();
  const file = bucket.file(storagePath);
  await file.save(buffer, {
    resumable: false,
    metadata: {
      contentType: mimeType,
      cacheControl: "public,max-age=31536000",
      metadata: {
        firebaseStorageDownloadTokens: token,
      },
    },
  });
  const downloadUrl =
    `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/` +
    `${encodeURIComponent(storagePath)}?alt=media&token=${token}`;
  return { storagePath, downloadUrl };
}

async function generateAndStoreComicImages({
  apiKey,
  publicId,
  comicId,
  panels,
}) {
  const ai = new GoogleGenAI({ apiKey });
  const bucket = getStorage().bucket();

  const generated = await Promise.all(
    panels.map((panel) =>
      generatePanelImage(ai, panel.description, panel.index),
    ),
  );

  const uploaded = [];
  for (let i = 0; i < 4; i++) {
    const img = generated[i];
    const meta = await uploadPanelImage({
      bucket,
      publicId,
      comicId,
      panelIndex: i + 1,
      buffer: img.buffer,
      mimeType: img.mimeType,
    });
    uploaded.push({
      ...meta,
      provider: img.provider,
    });
  }

  return {
    imageUrls: uploaded.map((u) => u.downloadUrl),
    storagePaths: uploaded.map((u) => u.storagePath),
    imageProviders: uploaded.map((u) => u.provider),
  };
}

function makeGuestPublicId() {
  const alphabet =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let id = "G";
  for (let i = 0; i < 15; i++) {
    id += alphabet[Math.floor(Math.random() * alphabet.length)];
  }
  return id;
}

/**
 * Step 1 — Callable: { diaryText, publicId?, diaryId? }
 * Returns 4-panel scenario text only (no images).
 */
export const generateComicScenario = onCall(
  {
    secrets: [geminiApiKey],
    timeoutSeconds: 120,
    memory: "512MiB",
    invoker: "public",
  },
  async (request) => {
    const diaryText = String(request.data?.diaryText ?? "").trim();
    if (diaryText.length < 2) {
      throw new HttpsError("invalid-argument", "일기 내용이 너무 짧아요.");
    }
    if (diaryText.length > 5000) {
      throw new HttpsError("invalid-argument", "일기 내용이 너무 길어요.");
    }

    const db = getFirestore();
    const authUid = request.auth?.uid ?? null;

    let publicId = String(request.data?.publicId ?? "").trim();
    if (!publicId && authUid) {
      const userSnap = await db.collection("users").doc(authUid).get();
      publicId = userSnap.data()?.publicId ?? "";
    }
    if (!/^[A-Za-z][A-Za-z0-9]{15}$/.test(publicId)) {
      publicId = makeGuestPublicId();
    }

    let diaryId = String(request.data?.diaryId ?? "").trim();
    const today = new Date();
    const diaryDate = [
      today.getFullYear(),
      String(today.getMonth() + 1).padStart(2, "0"),
      String(today.getDate()).padStart(2, "0"),
    ].join("-");

    if (!diaryId) {
      const diaryRef = await db.collection("diaries").add({
        publicId,
        content: diaryText,
        diaryDate,
        loginIdentity: request.auth?.token?.email ?? "guest",
        loginIdentityType: request.auth ? "google" : "guest",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        status: "submitted",
      });
      diaryId = diaryRef.id;
    }

    let generated;
    try {
      generated = await callGemini(diaryText, geminiApiKey.value());
    } catch (err) {
      console.error("Gemini generation failed", err);
      throw new HttpsError(
        "internal",
        "시나리오 생성에 실패했어요. 잠시 후 다시 시도해 주세요.",
      );
    }

    const text = generated.panels
      .map((p) => `[컷 ${p.index}] ${p.description}`)
      .join("\n");

    const scenarioRef = await db.collection("scenarios").add({
      diaryId,
      publicId,
      text,
      panelsText: generated.panels.map((p) => p.description),
      title: generated.title,
      model: generated.model,
      createdAt: FieldValue.serverTimestamp(),
      status: "ready",
    });

    return {
      scenarioId: scenarioRef.id,
      diaryId,
      publicId,
      title: generated.title,
      model: generated.model,
      panels: generated.panels,
      text,
    };
  },
);

/**
 * Step 2 — Callable: { scenarioId } or { publicId, diaryId, title, panels[] }
 * Generates 4 panel images from scenario descriptions.
 */
export const generateComicImages = onCall(
  {
    secrets: [geminiApiKey],
    timeoutSeconds: 540,
    memory: "1GiB",
    invoker: "public",
  },
  async (request) => {
    const db = getFirestore();
    const scenarioId = String(request.data?.scenarioId ?? "").trim();

    let publicId = String(request.data?.publicId ?? "").trim();
    let diaryId = String(request.data?.diaryId ?? "").trim();
    let title = String(request.data?.title ?? "").trim();
    let panels = Array.isArray(request.data?.panels)
      ? request.data.panels
      : [];

    if (scenarioId) {
      const snap = await db.collection("scenarios").doc(scenarioId).get();
      if (!snap.exists) {
        throw new HttpsError("not-found", "시나리오를 찾을 수 없어요.");
      }
      const data = snap.data() ?? {};
      publicId = publicId || String(data.publicId ?? "");
      diaryId = diaryId || String(data.diaryId ?? "");
      title = title || String(data.title ?? "오늘의 4컷 일기");
      if (!panels.length) {
        const panelsText = Array.isArray(data.panelsText)
          ? data.panelsText
          : [];
        panels = panelsText.map((description, i) => ({
          index: i + 1,
          description: String(description ?? "").trim(),
          label: PANEL_LABELS[i],
        }));
      }
    }

    if (!/^[A-Za-z][A-Za-z0-9]{15}$/.test(publicId)) {
      publicId = makeGuestPublicId();
    }
    if (!title) title = "오늘의 4컷 일기";

    let normalized;
    try {
      normalized = normalizePanels({ panels });
    } catch (err) {
      throw new HttpsError(
        "invalid-argument",
        "시나리오 장면이 부족해요. 먼저 시나리오를 만들어 주세요.",
      );
    }

    const comicRef = db.collection("comics").doc();
    await comicRef.set({
      scenarioId: scenarioId || null,
      diaryId: diaryId || null,
      publicId,
      title,
      imageUrls: [],
      storagePaths: [],
      thumbnailUrl: null,
      createdAt: FieldValue.serverTimestamp(),
      status: "processing",
    });

    try {
      const images = await generateAndStoreComicImages({
        apiKey: geminiApiKey.value(),
        publicId,
        comicId: comicRef.id,
        panels: normalized,
      });
      await comicRef.update({
        imageUrls: images.imageUrls,
        storagePaths: images.storagePaths,
        thumbnailUrl: images.imageUrls[0] ?? null,
        imageProviders: images.imageProviders,
        status: "ready",
      });

      return {
        comicId: comicRef.id,
        scenarioId: scenarioId || null,
        diaryId: diaryId || null,
        publicId,
        title,
        panels: normalized,
        imageUrls: images.imageUrls,
        storagePaths: images.storagePaths,
        imageProviders: images.imageProviders,
      };
    } catch (err) {
      console.error("Comic image generation failed", err);
      await comicRef.update({
        status: "failed",
        error: String(err?.message ?? err),
      });
      throw new HttpsError(
        "internal",
        "만화 이미지 생성에 실패했어요. 잠시 후 다시 시도해 주세요.",
      );
    }
  },
);

/**
 * OCR / Vision — extract diary text from image or PDF via Gemini.
 * Callable: { mimeType: string, dataBase64: string }
 */
export const extractDiaryText = onCall(
  {
    secrets: [geminiApiKey],
    timeoutSeconds: 120,
    memory: "1GiB",
    invoker: "public",
  },
  async (request) => {
    const mimeType = String(request.data?.mimeType ?? "").trim().toLowerCase();
    const dataBase64 = String(request.data?.dataBase64 ?? "").trim();

    const allowed = new Set([
      "image/jpeg",
      "image/jpg",
      "image/png",
      "image/webp",
      "image/gif",
      "application/pdf",
    ]);
    if (!allowed.has(mimeType)) {
      throw new HttpsError(
        "invalid-argument",
        "이미지(JPG/PNG/WebP/GIF)나 PDF만 올릴 수 있어요.",
      );
    }
    if (!dataBase64 || dataBase64.length < 32) {
      throw new HttpsError("invalid-argument", "파일이 비어 있어요.");
    }
    // ~6MB base64 ≈ 4.5MB binary — keep under callable limits.
    if (dataBase64.length > 8_000_000) {
      throw new HttpsError(
        "invalid-argument",
        "파일이 너무 커요. 조금 더 작은 파일로 올려 주세요.",
      );
    }

    const prompt = `이 파일에 적힌 글자를 읽어, 일기 본문으로 쓸 수 있는 한국어 텍스트만 추출하세요.
규칙:
- 설명/마크다운/따옴표 없이 본문만 출력
- 글자가 없으면 빈 문자열
- 날짜·제목이 보이면 자연스럽게 포함해도 됨
- 손으로 쓴 글씨도 최대한 읽기`;

    const ai = new GoogleGenAI({ apiKey: geminiApiKey.value() });
    const visionModels = [
      "gemini-3.6-flash",
      "gemini-3-flash-preview",
      "gemini-flash-latest",
      "gemini-3.1-flash-lite",
    ];

    let lastError;
    for (const model of visionModels) {
      try {
        const response = await ai.models.generateContent({
          model,
          contents: [
            {
              role: "user",
              parts: [
                { text: prompt },
                {
                  inlineData: {
                    mimeType:
                      mimeType === "image/jpg" ? "image/jpeg" : mimeType,
                    data: dataBase64,
                  },
                },
              ],
            },
          ],
        });
        const text = String(response.text ?? "").trim();
        return { text, model };
      } catch (err) {
        lastError = err;
        console.warn(`Vision OCR failed: ${model}`, err?.message ?? err);
      }
    }

    console.error("Vision OCR failed", lastError);
    throw new HttpsError(
      "internal",
      "글자를 읽는 중에 문제가 생겼어요. 잠시 후 다시 시도해 주세요.",
    );
  },
);

/**
 * Soft-withdraw: scrub PII + Auth account, keep publicId and content.
 */
export const withdrawMember = onCall(
  {
    timeoutSeconds: 60,
    memory: "256MiB",
    invoker: "public",
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요해요.");
    }
    const uid = request.auth.uid;
    const db = getFirestore();
    const userRef = db.collection("users").doc(uid);
    const snap = await userRef.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "회원 정보를 찾을 수 없어요.");
    }
    const data = snap.data() ?? {};
    const publicId = String(data.publicId ?? "");
    const email = data.email ? String(data.email) : "";
    const googleEmail = data.googleEmail ? String(data.googleEmail) : "";
    const phone = data.phone ?? null;

    const batch = db.batch();
    batch.set(
      userRef,
      {
        publicId,
        nickname: null,
        nicknameSet: false,
        email: null,
        googleEmail: null,
        phone: null,
        phoneDisplay: null,
        authProviders: [],
        photoUrl: null,
        status: "withdrawn",
        isWithdrawn: true,
        withdrawnAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        // keep createdAt / comic stats for analytics
      },
      { merge: true },
    );

    if (publicId) {
      batch.set(
        db.collection("public_ids").doc(publicId),
        {
          authUid: null,
          status: "orphaned",
          releasedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    const lookups = [];
    if (email) lookups.push(`email_${email.toLowerCase()}`);
    if (googleEmail) lookups.push(`email_${googleEmail.toLowerCase()}`);
    if (phone?.countryCode && phone?.nationalNumber) {
      lookups.push(
        `phone_${phone.countryCode}_${phone.nationalNumber}`,
      );
    }
    for (const key of lookups) {
      batch.delete(db.collection("auth_lookup").doc(key));
    }

    await batch.commit();

    try {
      await getAuth().deleteUser(uid);
    } catch (err) {
      console.error("Auth delete failed", err);
      throw new HttpsError(
        "internal",
        "탈퇴 처리 중 문제가 생겼어요. 잠시 후 다시 시도해 주세요.",
      );
    }

    return { ok: true, publicId };
  },
);

/**
 * Provision Firestore membership after Firebase Auth signup/login.
 * Admin write avoids client rule edge-cases on first profile create.
 * Callable (auth required): {
 *   email?, googleEmail?, countryCode?, nationalNumber?,
 *   authProviders: string[], photoUrl?
 * }
 */
export const provisionMember = onCall(
  {
    timeoutSeconds: 60,
    memory: "256MiB",
    invoker: "public",
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요해요.");
    }
    const uid = request.auth.uid;
    const db = getFirestore();
    const userRef = db.collection("users").doc(uid);
    const existing = await userRef.get();
    if (existing.exists) {
      const data = existing.data() ?? {};
      if (data.isWithdrawn === true || data.status === "withdrawn") {
        throw new HttpsError("failed-precondition", "탈퇴한 계정입니다");
      }
      return {
        authUid: uid,
        publicId: data.publicId,
        nickname: data.nickname ?? null,
        nicknameSet: data.nicknameSet === true,
        email: data.email ?? null,
        googleEmail: data.googleEmail ?? null,
        phone: data.phone ?? null,
        phoneDisplay: data.phoneDisplay ?? null,
        authProviders: data.authProviders ?? [],
        photoUrl: data.photoUrl ?? null,
        status: data.status ?? "active",
        isWithdrawn: false,
      };
    }

    const email = String(request.data?.email ?? "").trim().toLowerCase() || null;
    const googleEmail =
      String(request.data?.googleEmail ?? "").trim().toLowerCase() || null;
    const countryCodeRaw = String(request.data?.countryCode ?? "").trim();
    const nationalRaw = String(request.data?.nationalNumber ?? "").trim();
    const authProviders = Array.isArray(request.data?.authProviders)
      ? request.data.authProviders.map(String)
      : ["email"];
    const photoUrl = String(request.data?.photoUrl ?? "").trim() || null;

    const digits = (s) => String(s).replace(/[^0-9]/g, "");
    let phone = null;
    let phoneDisplay = null;
    if (countryCodeRaw || nationalRaw) {
      const cc = `+${digits(countryCodeRaw) || "82"}`;
      const nn = digits(nationalRaw);
      if (nn.length < 9 || nn.length > 11) {
        throw new HttpsError(
          "invalid-argument",
          "휴대폰 번호를 입력하세요",
        );
      }
      phone = { countryCode: cc, nationalNumber: nn };
      phoneDisplay = `${cc} ${nn}`;
    }

    const letters =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    const alnum =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    let publicId = "";
    for (let attempt = 0; attempt < 12; attempt++) {
      let id = letters[Math.floor(Math.random() * letters.length)];
      for (let i = 0; i < 15; i++) {
        id += alnum[Math.floor(Math.random() * alnum.length)];
      }
      const snap = await db.collection("public_ids").doc(id).get();
      if (!snap.exists) {
        publicId = id;
        break;
      }
    }
    if (!publicId) {
      throw new HttpsError("internal", "고유 ID를 만들지 못했어요.");
    }

    const now = FieldValue.serverTimestamp();
    const batch = db.batch();
    batch.set(userRef, {
      publicId,
      nickname: null,
      nicknameSet: false,
      email,
      googleEmail,
      phone,
      phoneDisplay,
      authProviders,
      photoUrl,
      status: "active",
      isWithdrawn: false,
      withdrawnAt: null,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
      lastComicDate: null,
      comicCountTotal: 0,
    });
    batch.set(db.collection("public_ids").doc(publicId), {
      publicId,
      authUid: uid,
      status: "active",
      createdAt: now,
      releasedAt: null,
    });

    if (email) {
      batch.set(db.collection("auth_lookup").doc(`email_${email}`), {
        authUid: uid,
        type: "email",
        value: email,
      });
    }
    if (googleEmail) {
      batch.set(db.collection("auth_lookup").doc(`email_${googleEmail}`), {
        authUid: uid,
        type: "googleEmail",
        value: googleEmail,
      });
    }
    if (phone) {
      batch.set(
        db
          .collection("auth_lookup")
          .doc(`phone_${phone.countryCode}_${phone.nationalNumber}`),
        {
          authUid: uid,
          type: "phone",
          countryCode: phone.countryCode,
          nationalNumber: phone.nationalNumber,
        },
      );
    }

    await batch.commit();

    return {
      authUid: uid,
      publicId,
      nickname: null,
      nicknameSet: false,
      email,
      googleEmail,
      phone,
      phoneDisplay,
      authProviders,
      photoUrl,
      status: "active",
      isWithdrawn: false,
    };
  },
);
