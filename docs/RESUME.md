# hsdaily-toon — 작업 재개 가이드

최종 저장: **2026-09-19** · Git `main` @ `d7e5c5f` (origin과 동기화됨)

---

## 운영 중인 서비스 (끄지 마세요)

아래는 **계속 켜 둔 채** 실시간 테스트에 쓰면 됩니다.

| 서비스 | 상태 | 메모 |
|--------|------|------|
| **GitHub** | ✅ | https://github.com/byki6768/hsdaily_toon |
| **Vercel** | ✅ 웹 배포 | https://hsdaily-toon-git-main-byki6768.vercel.app/ |
| **Firebase 프로젝트** | ✅ | `hsdaily-toon` (`asia-northeast3`) |
| **Firestore** | ✅ | users / public_ids / diaries / scenarios / comics / auth_lookup |
| **Storage** | ✅ | comics 패널 이미지 |
| **Auth** | ✅ | Google + Email/Password (휴대폰은 내부 이메일 매핑) |
| **Cloud Functions** | ✅ | 아래 목록 |

### Cloud Functions (`asia-northeast3`)

- `generateComicScenario` — 일기 → 4컷 시나리오
- `generateComicImages` — 시나리오 → 4컷 이미지
- `extractDiaryText` — 사진/PDF OCR
- `provisionMember` — 가입 후 Firestore 회원 문서 생성
- `withdrawMember` — 탈퇴(PII 삭제, publicId·콘텐츠 유지)

### Secret

- `GEMINI_API_KEY` (Firebase Secret Manager) — 클라이언트에 없음  
- 로컬 참고용: `.env.local` (gitignore, 커밋 금지)

---

## 현재까지 완료된 기능

- 랜딩 → 로그인/가입 → 닉네임 환영 → 홈
- Google / 이메일 / 휴대폰 가입·로그인
- 마이페이지(닉네임·비밀번호·탈퇴), 전역 로그아웃
- 일기 작성 + 음성 입력 + 사진/PDF OCR
- **2단계 만화**: ① 시나리오 ② 이미지 생성
- 에러 시 말풍선 후 입력 화면 복귀

---

## 다시 시작할 때 (체크리스트)

### 1) 코드 받기

```bash
cd "c:\Users\HS Kim\Desktop\MyProject\hsdaily_toon"
git pull origin main
flutter pub get
cd functions && npm install && cd ..
```

### 2) 로컬 실행 (선택)

```bash
flutter run -d chrome --web-port=8080
```

### 3) Firebase CLI (배포할 때만)

```bash
npx firebase-tools login
npx firebase-tools use hsdaily-toon
```

### 4) Cursor에서 이어서 말하기 (복사용)

```
docs/RESUME.md 기준으로 hsdaily-toon 작업을 이어서 해 줘.
GitHub main과 Vercel/Firebase는 이미 운영 중이야.
```

---

## 다음에 하면 좋은 일 (우선순위)

1. **갤러리** — 더미 → Firestore `comics` 실데이터 연동  
2. **하루 1회 생성 제한** — `usage_daily` / `app_config/limits` UI  
3. **사진 저장** — 결과 화면 실제 저장  
4. **Gemini 이미지 과금** — 무료 티어 이미지 쿼터 0이면 폴백(Pollinations) 유지 / 필요 시 결제 후 Gemini 이미지 우선  
5. **고아 Auth 계정** — 가입 실패 잔여 Auth만 남은 경우 Console에서 정리 (또는 관리용 CF)  
6. **보안** — 예전에 노출된 Gemini 키 재발급 권장; Callable에 `request.auth` 강화 검토  
7. **Android/iOS** — `flutterfire configure`로 네이티브 옵션 추가

---

## 중요 경로

| 항목 | 경로 |
|------|------|
| 이 문서 | `docs/RESUME.md` |
| 데이터 모델 | `docs/DATA_MODEL.md` |
| Gemini/OCR | `docs/GEMINI_SCENARIO.md` |
| Functions | `functions/index.js` |
| Auth | `lib/services/auth_service.dart` |
| 회원 provision | `lib/services/member_provision_service.dart` |
| 시나리오/이미지 | `lib/services/scenario_service.dart` |
| 라우터 | `lib/router/app_router.dart` |

---

## 주의

- `.env.local` / API 키는 **커밋하지 마세요** (이미 gitignore)
- Firebase·Vercel을 일시정지/삭제하면 라이브 테스트가 끊깁니다
- `main` 푸시하면 Vercel이 자동 재배포됩니다
