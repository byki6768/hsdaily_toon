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
- 웹: Firebase 콘솔 → Authentication → Settings → **Authorized domains**에 Vercel 도메인 추가

### 2) GitHub 연동

```bash
# 이 폴더는 이미 git init + 초기 커밋된 상태여야 함
gh repo create hsdaily-toon --private --source=. --remote=origin --push
# 또는 GitHub에서 빈 repo 생성 후:
git remote add origin https://github.com/<USER>/hsdaily-toon.git
git push -u origin main
```

주의: `.env`, `GEMINI_API_KEY`, `functions/.env`는 커밋하지 말 것 (이미 gitignore).

### 3) Vercel 웹 배포

Flutter 웹은 정적 빌드 후 Hosting/Vercel에 올리는 방식이 일반적입니다.

```bash
flutter build web --release
```

- Vercel: GitHub 연결 → Root는 빌드 산출물 전략 선택
  - 옵션 A: GitHub Action으로 `flutter build web` 후 `build/web` 배포
  - 옵션 B: Vercel 대신 **Firebase Hosting** (`firebase deploy --only hosting`)도 가능
- Cloud Functions는 이미 Firebase에 있음 → Vercel에 Functions를 옮길 필요 없음
- 웹에서 Callable 호출 시 region `asia-northeast3` 유지 (`ScenarioService`)

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

> hsdaily-toon 이어서 진행해 줘. Google 로그인을 Flutter에 연결하고 users/public_ids 최초 가입(닉네임)까지 구현한 뒤, GitHub push와 Vercel(또는 Firebase Hosting) 웹 배포를 설정해 줘. 마지막에 UI/UX 폴리시를 해 줘.

---

저장일: 로컬 git 초기 커밋 기준. Firebase(콘솔·Functions·Secret)는 클라우드에 유지됨.
