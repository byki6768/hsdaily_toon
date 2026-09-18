/**
 * Cloud Functions — Gemini 4-cut scenario generation.
 * GEMINI_API_KEY is injected via Firebase Secrets (never in client code).
 */
import { GoogleGenAI } from "@google/genai";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { setGlobalOptions } from "firebase-functions/v2";

initializeApp();
setGlobalOptions({ region: "asia-northeast3" });

const geminiApiKey = defineSecret("GEMINI_API_KEY");

/** Prefer the model from the product brief; fall back if unavailable. */
const MODEL_CANDIDATES = [
  "gemini-3.8-flash",
  "gemini-3.5-flash",
  "gemini-3-flash-preview",
  "gemini-2.5-flash",
];

const PANEL_TINTS = ["아침", "낮", "저녁", "밤"];

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
      label: PANEL_TINTS[i],
    };
  });
}

async function callGemini(diaryText, apiKey) {
  // GoogleGenAI reads GEMINI_API_KEY from env when constructed with {}.
  process.env.GEMINI_API_KEY = apiKey;
  const ai = new GoogleGenAI({});
  const input = buildPrompt(diaryText);

  let lastError;
  for (const model of MODEL_CANDIDATES) {
    try {
      const interaction = await ai.interactions.create({
        model,
        input,
      });
      const outputText = interaction.output_text ?? "";
      const parsed = extractJson(outputText);
      const panels = normalizePanels(parsed);
      return {
        model,
        title: String(parsed.title ?? "오늘의 4컷 일기").trim() || "오늘의 4컷 일기",
        panels,
        rawText: outputText,
      };
    } catch (err) {
      lastError = err;
      console.warn(`Gemini model failed: ${model}`, err?.message ?? err);
    }
  }
  throw lastError ?? new Error("All Gemini models failed");
}

function makeGuestPublicId() {
  const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let id = "G";
  for (let i = 0; i < 15; i++) {
    id += alphabet[Math.floor(Math.random() * alphabet.length)];
  }
  return id;
}

/**
 * Callable: { diaryText: string, publicId?: string, diaryId?: string }
 * Returns scenario + 4 panel descriptions; persists to Firestore `scenarios`.
 */
export const generateComicScenario = onCall(
  {
    secrets: [geminiApiKey],
    timeoutSeconds: 120,
    memory: "512MiB",
    // Diary flow may run before Google login is wired.
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
