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
2. Function: Gemini Interactions API (`@google/genai`)로 4장면 JSON 생성  
3. Firestore `diaries` (+ 없으면 생성) → `scenarios` 저장  
4. 앱: 패널 설명으로 결과 화면 표시 (이미지는 아직 placeholder)

## 모델

우선순위: `gemini-3.6-flash` → `gemini-3-flash-preview` → `gemini-flash-latest` → `gemini-3.1-flash-lite`  
SDK: `@google/genai` ≥ 2.x (`models.generateContent` 우선, Interactions 폴백)
