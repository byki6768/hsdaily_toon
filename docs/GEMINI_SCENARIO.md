# Gemini 시나리오 생성

## 보안

- API 키는 **클라이언트(Flutter)에 넣지 않습니다.**
- Firebase Secret `GEMINI_API_KEY` → Cloud Function 환경에서만 사용
- 로컬: 루트 `.env.local` (gitignore) — `GEMINI_API_KEY` / `GEMINI_VISION_API_KEY`
- 예시: `.env.example` 참고

시크릿 설정:
```bash
npx firebase-tools functions:secrets:set GEMINI_API_KEY --data-file=- --project hsdaily-toon
```

## 입력 보조

- **음성**: 웹은 Web Speech API, 모바일은 네이티브 STT → 일기 칸에 자동 입력 → 기존 Gemini 시나리오/이미지 흐름으로 전달
- **사진·PDF**: `extractDiaryText` (Gemini Vision) → 추출 텍스트를 일기 칸에 자동 입력

시크릿 설정:
```bash
npx firebase-tools functions:secrets:set GEMINI_API_KEY --data-file=- --project hsdaily-toon
```

## 흐름

1. 앱: 일기 작성 → `generateComicScenario` (1단계)  
2. Function: Gemini로 4장면 JSON 시나리오 생성 → Firestore `scenarios` 저장  
3. 앱: 4칸 프레임 하단에 시나리오 문장 표시 + 다시 **만화로 만들기**  
4. 앱: `generateComicImages` (2단계)  
5. Function: 컷별 이미지 생성 → Storage 업로드 → `comics` 저장  
6. 앱: `imageUrls`로 완성된 4컷 표시

## 모델

시나리오: `gemini-3.6-flash` → `gemini-3-flash-preview` → `gemini-flash-latest` → `gemini-3.1-flash-lite`  
이미지: `gemini-2.5-flash-image` → `gemini-3.1-flash-image` → `gemini-3.1-flash-lite-image`  
이미지 폴백: Pollinations (Gemini 이미지 쿼터/과금 미설정 시)  
SDK: `@google/genai` ≥ 2.x
