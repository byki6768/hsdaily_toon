# hsdaily-toon (4컷 일기)

Flutter 3.x 기반 **웹 + 모바일** 크로스 플랫폼 앱입니다.

- **앱 이름**: 4컷 일기 (Daily-toon)
- **DB / Auth / Functions**: Firebase (`hsdaily-toon`)
- **GitHub**: https://github.com/byki6768/hsdaily_toon
- **Vercel (웹)**: https://hsdaily-toon-behs8ev9c-byki6768.vercel.app

## 구조 (FSD)

```
lib/
├── main.dart
├── router/app_router.dart
├── shared/layout/responsive_layout.dart
├── theme/app_theme.dart
├── services/
└── features/
    ├── home/     (screen · ui · model)
    ├── auth/     (screen · ui · model)
    ├── diary/    (screen · ui · model)
    └── gallery/  (screen · ui · model)
```

| Feature | 역할 |
|---------|------|
| `home` | 앱 메인 화면 |
| `auth` | 로그인 및 사용자 인증 |
| `diary` | 일기 작성, AI 시나리오 생성 |
| `gallery` | 생성된 4컷 일기 모아보기 |

## 실행

```bash
flutter pub get
flutter run -d chrome   # 웹
flutter run             # 연결된 모바일/에뮬레이터
```

## Firebase

- 프로젝트 ID: `hsdaily-toon`
- 웹 앱 설정: `lib/firebase_options.dart`
- Google 로그인: Authentication 콘솔에서 사용 설정 완료
- Gemini 시나리오: Cloud Function `generateComicScenario` (`asia-northeast3`)
- 상세 스키마: `docs/DATA_MODEL.md`
- 재개 가이드: `docs/RESUME.md`

## 다음 단계

1. Flutter에 Google 로그인 + 닉네임 온보딩 연동
2. UI/UX 폴리시, 갤러리 실데이터 연결
3. (선택) 커스텀 Vercel 프로덕션 도메인도 Authorized domains에 추가
