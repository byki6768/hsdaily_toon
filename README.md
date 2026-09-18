# hsdaily-toon (4컷 일기)

Flutter 3.x 기반 **웹 + 모바일** 크로스 플랫폼 앱의 프로젝트 뼈대입니다.

- **앱 이름**: 4컷 일기 (Daily-toon)
- **DB**: Firebase (연결은 이후 단계에서 진행)
- **배포 예정**: GitHub → Vercel (웹)

이번 단계는 **폴더/파일 구조만** 구성합니다. UI·API·Firebase·더미 데이터는 포함하지 않습니다.

## 구조 (FSD)

```
lib/
├── main.dart
├── router/app_router.dart
├── shared/layout/responsive_layout.dart
├── theme/app_theme.dart
├── services/firebase_service.dart
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

## 반응형 레이아웃 (예정)

- **데스크톱** (≥ 769px): 왼쪽 사이드바 + 오른쪽 메인
- **모바일** (≤ 768px): 상단 일렬 메뉴 + 아래 메인

규칙은 `lib/shared/layout/responsive_layout.dart`에 주석으로 정리되어 있습니다.

## 실행

```bash
flutter pub get
flutter run -d chrome   # 웹
flutter run             # 연결된 모바일/에뮬레이터
```

## Firebase

- 프로젝트 ID: `hsdaily-toon`
- 웹 앱 설정은 `lib/firebase_options.dart`에 반영됨
- 앱 시작 시 `FirebaseService.initialize()`로 초기화 (`lib/services/firebase_service.dart`)
- Analytics는 웹에서만 활성화
- Android / iOS 앱은 아직 미등록 — 콘솔에 앱 추가 후 `flutterfire configure` 권장

## 다음 단계 (예정)

1. 홈 화면 UI (따뜻하고 감성적인 분위기)
2. 반응형 레이아웃 구현
3. Auth / Firestore 연동
4. 라우팅 완성
5. Vercel 웹 배포 설정
