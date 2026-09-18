# Gemini 시나리오 생성

## 보안

- API 키는 **클라이언트(Flutter)에 넣지 않습니다.**
- Firebase Secret `GEMINI_API_KEY` → Cloud Function 환경에서만 사용
- 로컬 예시: `.env.example` 참고 (`functions/.env`는 gitignore)

시크릿 설정:
```bash
npx firebase-tools functions:secrets:set GEMINI_API_KEY --data-file=- --project hsdaily-toon
```

## 흐름

1. 앱: 일기 작성 → `generateComicScenario` callable 호출  
2. Function: Gemini로 4장면 JSON 시나리오 생성  
3. Firestore `diaries` / `scenarios` 저장  
4. Function: 컷별 이미지 생성 → Storage `comics/{publicId}/{comicId}/panel_N.*` 업로드 → `comics` 저장  
5. 앱: `imageUrls`로 결과 화면 4칸 표시

## 모델

시나리오: `gemini-3.6-flash` → `gemini-3-flash-preview` → `gemini-flash-latest` → `gemini-3.1-flash-lite`  
이미지: `gemini-2.5-flash-image` → `gemini-3.1-flash-image` → `gemini-3.1-flash-lite-image`  
이미지 폴백: Pollinations (Gemini 이미지 쿼터/과금 미설정 시)  
SDK: `@google/genai` ≥ 2.x
