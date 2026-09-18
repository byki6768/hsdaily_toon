# hsdaily-toon Firestore / Storage 데이터 모델

프로젝트: `hsdaily-toon`  
인증: Firebase Auth (우선 Google Sign-In, 이후 Email / Phone 확장)  
DB: Cloud Firestore  
이미지: Firebase Storage

---

## 핵심 설계 원칙

| 개념 | 설명 |
|------|------|
| **authUid** | Firebase Auth UID. 로그인·보안 규칙용. 탈퇴 시 Auth 계정 삭제. |
| **publicId** | 회원 고유 16자리 ID (`^[A-Za-z][A-Za-z0-9]{15}$`). **영구**. 탈퇴해도 콘텐츠에 남음. |
| **비밀번호** | Firestore에 저장하지 않음. Email/Password는 Firebase Auth가 관리. |
| **콘텐츠 소유** | `diaries` / `scenarios` / `comics` 는 모두 `publicId` 로 연결. |

탈퇴 시: Auth 삭제 + `users/{authUid}` 민감정보(이메일·전화·닉네임 등) 제거/`isWithdrawn=true`.  
`publicId`·일기·시나리오·만화는 유지.

---

## 컬렉션 한눈에 보기

```
users/{authUid}
public_ids/{publicId}
diaries/{diaryId}
scenarios/{scenarioId}
comics/{comicId}
usage_daily/{publicId}_{yyyyMMdd}
app_config/limits
```

---

## 1) `users` — 활성 계정 프로필

**문서 ID:** Firebase Auth `uid`

| 필드 | 타입 | 설명 |
|------|------|------|
| `publicId` | string | 16자리 영구 ID |
| `nickname` | string \| null | 최초 로그인 시 입력 |
| `nicknameSet` | bool | 닉네임 설정 완료 여부 |
| `email` | string \| null | 이메일 로그인용 (`***@***.***`) |
| `googleEmail` | string \| null | Google 계정 이메일 |
| `phone` | map \| null | `{ countryCode: "+82", nationalNumber: "1012345678" }` |
| `phoneDisplay` | string \| null | 표시용 `+82 10-1234-5678` |
| `authProviders` | string[] | `google` \| `email` \| `phone` |
| `photoUrl` | string \| null | Google 프로필 등 |
| `status` | string | `active` \| `withdrawn` |
| `isWithdrawn` | bool | |
| `withdrawnAt` | timestamp \| null | |
| `createdAt` | timestamp | |
| `updatedAt` | timestamp | |
| `lastLoginAt` | timestamp | |
| `lastComicDate` | string \| null | `yyyy-MM-dd` (빠른 1일 1회 체크) |
| `comicCountTotal` | number | 누적 생성 수 |

> 비밀번호 해시는 저장하지 않음.

---

## 2) `public_ids` — 영구 ID 레지스트리

**문서 ID:** `publicId`

| 필드 | 타입 | 설명 |
|------|------|------|
| `publicId` | string | |
| `authUid` | string \| null | 탈퇴 후 null |
| `status` | string | `active` \| `orphaned` |
| `createdAt` | timestamp | |
| `releasedAt` | timestamp \| null | 탈퇴 시각 |

---

## 3) `diaries` — 일기

**문서 ID:** 자동 ID

| 필드 | 타입 | 설명 |
|------|------|------|
| `publicId` | string | 작성자 영구 ID |
| `content` | string | 일기 본문 |
| `diaryDate` | string | 일기 날짜 `yyyy-MM-dd` |
| `loginIdentity` | string | 작성 시점 식별자 스냅샷 (googleEmail / email / phoneDisplay) |
| `loginIdentityType` | string | `google` \| `email` \| `phone` |
| `createdAt` | timestamp | |
| `updatedAt` | timestamp | |
| `status` | string | `draft` \| `submitted` \| `deleted` |

인덱스 예: `publicId ASC, diaryDate DESC`

---

## 4) `scenarios` — AI 시나리오

**문서 ID:** 자동 ID

| 필드 | 타입 | 설명 |
|------|------|------|
| `diaryId` | string | → `diaries` |
| `publicId` | string | |
| `text` | string | 시나리오 전문 |
| `panelsText` | string[] \| null | 컷별 텍스트(확장) |
| `model` | string \| null | 사용 모델명 |
| `createdAt` | timestamp | |
| `status` | string | `ready` \| `failed` |

---

## 5) `comics` — 4컷 만화 메타 + Storage URL

**문서 ID:** 자동 ID (= Storage 폴더명으로 사용)

| 필드 | 타입 | 설명 |
|------|------|------|
| `scenarioId` | string | → `scenarios` |
| `diaryId` | string | → `diaries` |
| `publicId` | string | |
| `title` | string | 갤러리 제목 |
| `imageUrls` | string[4] | 다운로드 URL (순서 = 컷 1~4) |
| `storagePaths` | string[4] | Storage 상대 경로 |
| `thumbnailUrl` | string \| null | 대표 썸네일(보통 컷1) |
| `createdAt` | timestamp | |
| `status` | string | `ready` \| `processing` \| `failed` |

---

## 6) `usage_daily` — 하루 1회 생성 제한

**문서 ID:** `{publicId}_{yyyyMMdd}`

| 필드 | 타입 | 설명 |
|------|------|------|
| `publicId` | string | |
| `date` | string | `yyyyMMdd` |
| `comicGeneratedCount` | number | |
| `diaryCount` | number | |
| `updatedAt` | timestamp | |

한도: `app_config/limits.maxComicsPerDay` (기본 1)와 비교.

---

## 7) `app_config` — 앱 설정

**문서 ID:** `limits`

| 필드 | 타입 | 기본 |
|------|------|------|
| `maxComicsPerDay` | number | 1 |
| `maxDiaryLength` | number | 5000 |
| `passwordMinLength` | number | 6 |
| `passwordMaxLength` | number | 16 |

---

## 관계 구조

```
Firebase Auth (uid)
        │ 1:1
        ▼
   users/{authUid} ──publicId──► public_ids/{publicId}
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                 ▼
              diaries/{id}     scenarios/{id}      comics/{id}
                    │                 │                 │
                    └──── diaryId ────┘                 │
                                      └─ scenarioId ────┘
```

- 콘텐츠는 모두 **`publicId`** 로 묶임 (탈퇴 후에도 조회·갤러리 가능 정책에 맞게 Rules 조정).
- 시나리오 → 일기: `diaryId`
- 만화 → 시나리오·일기: `scenarioId`, `diaryId`

---

## Storage 경로 규칙

```
comics/{publicId}/{comicId}/panel_1.webp
comics/{publicId}/{comicId}/panel_2.webp
comics/{publicId}/{comicId}/panel_3.webp
comics/{publicId}/{comicId}/panel_4.webp
comics/{publicId}/{comicId}/thumb.webp   # optional
```

Firestore 필드:
- `storagePaths[i]` = 위 경로
- `imageUrls[i]` = `getDownloadURL()` 결과 (또는 Firebase 다운로드 토큰 URL)
- 이후 CDN/리사이즈 도입 시 URL만 교체, 경로는 유지

---

## Google 최초 로그인 플로우

1. Google Sign-In → `authUid` 확보  
2. `users/{authUid}` 존재 여부 확인  
3. **없으면**  
   - `publicId` 생성 (충돌 시 재시도)  
   - `public_ids/{publicId}` 생성  
   - 닉네임 입력 UI → `nickname`, `nicknameSet=true`  
   - `authProviders: ['google']`, `googleEmail` 저장  
4. **있고 `nicknameSet==false`** → 닉네임만 추가 입력  
5. **있고 withdrawn** → 재가입 정책에 따라 새 `publicId` 또는 복구  
6. `lastLoginAt` 갱신  

---

## 비밀번호 / 로그인 형식 (앱 검증)

- 비밀번호: 길이 6~16, 문자·숫자·특수문자 허용 (Auth Email provider)  
- 이메일: 표준 이메일 정규식  
- 휴대폰: `countryCode` = `+` + 숫자 2자리, `nationalNumber` = 9~10자리 숫자 (`-` 제거 후 저장)

---

## 확장 여지

- `comics.panelStyle`, `scenarios.promptVersion`  
- `users.locale`, `users.timezone`  
- `diaries.mood`  
- Soft delete: `status: deleted` + `deletedAt`
