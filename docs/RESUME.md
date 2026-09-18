# hsdaily-toon — 작업 재개 가이드

마지막 저장 시점 기준으로, 다음에 이어서 할 일을 정리한 문서입니다.

## 현재까지 완료된 것

- Flutter 웹/모바일 뼈대 + FSD 구조 (`home` / `auth` / `diary` / `gallery`)
- 반응형 레이아웃, 홈·일기·로딩·결과·갤러리(더미) UI
- Firebase 프로젝트 `hsdaily-toon`
  - Firestore 스키마·Rules·Indexes (`docs/DATA_MODEL.md`)
  - Storage Rules
  - **Authentication → Google 사용 설정 완료** (콘솔에서 직접 켜 둠)
  - Cloud Function `generateComicScenario` (`asia-northeast3`)
  - Secret `GEMINI_API_KEY` (서버 전용, 클라이언트에 키 없음)
- 일기 → Gemini 4컷 시나리오 → Firestore `scenarios` 저장 흐름
- **GitHub**: https://github.com/byki6768/hsdaily_toon (`main`)
- **Vercel 배포**: https://hsdaily-toon-behs8ev9c-byki6768.vercel.app

## 다시 시작하기 (로컬)

```bash
cd "c:\Users\HS Kim\Desktop\MyProject\hsdaily_toon"
flutter pub get
cd functions && npm install && cd ..
flutter run -d chrome
```

Firebase CLI (배포/시크릿 확인 시):

```bash
npx firebase-tools login
npx firebase-tools use hsdaily-toon
```

## 다음에 할 일 (우선순위)

### 1) Google 로그인 앱 연동 (Auth는 콘솔 준비됨)

- Flutter에 `firebase_auth` + `google_sign_in`(또는 웹용 팝업) 연결
- 최초 로그인 시 `users` + `public_ids` 생성, **닉네임 입력** UI
- `auth` feature 화면을 placeholder에서 실제 로그인으로 교체
- 웹: Firebase 콘솔 → Authentication → Settings → **Authorized domains**에  
  `hsdaily-toon-behs8ev9c-byki6768.vercel.app` 및 프로덕션 Vercel 도메인 추가

### 2) GitHub — 완료

https://github.com/byki6768/hsdaily_toon

### 3) Vercel 웹 배포 — 1차 완료

- 배포 URL: https://hsdaily-toon-behs8ev9c-byki6768.vercel.app
- Cloud Functions는 Firebase에 유지 (`asia-northeast3`)
- 이후 `main` push 시 Vercel 자동 배포 확인

### 4) UI/UX 마무리

- 홈·일기·결과·갤러리 톤 통일, 빈 상태/에러/로딩 카피 정리
- Google 로그인·닉네임 온보딩 플로우
- 결과 화면: 시나리오 텍스트 ↔ (추후) 이미지 생성 연동
- 갤러리: 더미 → Firestore `comics` / `scenarios` 실데이터
- 하루 1회 생성 제한 (`usage_daily` / `app_config/limits`) UI 반영

### 5) (선택) 보안·운영

- 채팅에 노출된 Gemini 키는 **재발급 권장** 후  
  `npx firebase-tools functions:secrets:set GEMINI_API_KEY`
- Callable `invoker: public` → 로그인 필수 시 `request.auth` 검사로 강화
- Firestore Rules는 `publicId` 기준으로 이미 설계됨

## 중요 경로 빠른 링크

| 항목 | 경로 |
|------|------|
| 데이터 모델 | `docs/DATA_MODEL.md` |
| Gemini 흐름 | `docs/GEMINI_SCENARIO.md` |
| Cloud Function | `functions/index.js` |
| 시나리오 클라이언트 | `lib/services/scenario_service.dart` |
| Firebase 옵션(웹) | `lib/firebase_options.dart` |
| Firestore 경로 상수 | `lib/services/firestore_paths.dart` |

## Cursor에서 다시 열 때 예시 프롬프트

> hsdaily-toon 이어서: Google 로그인을 Flutter에 연결하고 users/public_ids + 닉네임 온보딩을 구현해 줘. Vercel 도메인을 Firebase Authorized domains에 넣고, UI/UX 폴리시를 진행해 줘.

---

저장일: GitHub/Vercel 1차 배포 반영 후. Firebase(콘솔·Functions·Secret)는 클라우드에 유지됨.
