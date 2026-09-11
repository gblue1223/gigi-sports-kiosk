# GIGI Sports Kiosk

9:16 세로형 모니터에 맞춘 예약 키오스크입니다. Flutter에서 `piggy-cms`의 예약 API를 호출하며, 예약은 CMS의 Supabase에 저장됩니다.

## 실행

CMS 데이터베이스·관리자·운영 설정을 먼저 준비합니다. 상세 절차는 인접 CMS 프로젝트의 `doc/KIOSK_BACKEND.md`를 참고하세요.

```sh
flutter pub get
flutter run -d windows --dart-define=CMS_BASE_URL=https://your-cms.example
```

Windows, Linux, Android, Web을 지원합니다. CMS 주소는 빌드 시 전달하며 운영에서는 HTTPS를 사용합니다. API 고정 키와 Supabase 비밀 키는 앱에 포함하지 않습니다.

같은 PC에서 개발할 때는:

```sh
# CMS 프로젝트에서 npm run dev 실행 후
flutter run -d windows --dart-define=CMS_BASE_URL=http://localhost:5173
# CMS의 KIOSK_ALLOWED_ORIGINS=http://localhost:8080 설정 필요
flutter run -d chrome --web-port=8080 --dart-define=CMS_BASE_URL=http://localhost:5173
```

CMS `/reservations`에서 매장을 선택해 10자리 연결 코드를 발급한 뒤 키오스크에 입력합니다. 코드는 CMS에서 발급할 때 지정한 유효시간(1~60분, 기본 5분) 내 1회 사용 가능하며 연결 세션도 CMS에서 발급 시 지정한 시간(1~168시간, 기본 8시간) 동안 유지됩니다. 세션 시간은 키오스크 연결 시점부터 계산되며, 이미 발급한 코드와 연결된 세션의 만료 시각은 설정 변경으로 바뀌지 않습니다. 앱 재시작 또는 만료 후에는 다시 연결합니다.

## Vercel Web 배포

Vercel의 환경변수는 Flutter의 컴파일 설정에 자동으로 포함되지 않습니다. 앱의 `String.fromEnvironment('CMS_BASE_URL')`가 값을 읽으려면 빌드 시 `--dart-define`으로 전달해야 합니다. [Dart 공식 문서](https://dart.dev/libraries/core/environment-declarations)

저장소의 `vercel.json`은 `bash scripts/vercel-build.sh`를 실행하고 `build/web`을 배포합니다. 빌드 스크립트가 Vercel의 `CMS_BASE_URL`을 검증해 Flutter에 전달합니다. Flutter가 설치되어 있지 않은 빌드 환경에는 로컬 검증 버전인 3.41.4를 설치합니다.

1. 키오스크 Vercel 프로젝트에 `CMS_BASE_URL=https://cms.gigi-sports.com`을 등록합니다. 사용하려는 Production/Preview 환경을 선택합니다.
2. 이 저장소를 배포 대상으로 사용하고 Root Directory가 키오스크 프로젝트 루트인지 확인합니다. 저장소 설정의 Build Command는 `bash scripts/vercel-build.sh`, Output Directory는 `build/web`입니다. [Vercel 설정 문서](https://vercel.com/docs/project-configuration/vercel-json)
3. 새 커밋을 배포하거나 **Redeploy**합니다. 환경변수를 변경해도 이미 만들어진 Web 파일에는 반영되지 않으므로 새 빌드가 필요합니다.
4. CMS 프로젝트의 `KIOSK_ALLOWED_ORIGINS`에는 실제 키오스크 Web 주소의 origin을 등록합니다. 예시: `https://kiosk.example.com`. CMS 주소를 넣는 항목이 아닙니다.
5. 새 배포 화면을 연 뒤 CMS에서 발급한 연결 코드를 입력합니다.

주소가 누락되거나 잘못된 경우 빌드를 실패시켜 빈 설정의 앱이 배포되는 것을 방지합니다. 빌드에는 공개 CMS 주소만 전달하며 CMS 세션 비밀 키는 전달하지 않습니다.

배포 설정 회귀 검증: `node --test scripts/test-build-config.mjs` (Node.js와 Bash 필요).

## 사용자 흐름

- 새 예약: 서버에서 날짜·요금·잔여 타석을 조회하고 예약 저장 성공 후에만 예약 번호를 표시합니다.
- 이용시간 변경: 60분/90분 전체 구간의 타석 여유를 다시 확인합니다.
- 통신 오류: 같은 화면에서 다시 예약 확정을 눌러 기존 요청의 결과를 확인합니다. 중복 터치를 차단합니다.
- 내 예약 확인: 휴대폰 번호와 완료 화면의 10자리 예약 번호를 입력합니다.
- 예약 번호는 사진으로 남겨 주세요. 완료 화면은 90초, 조회 화면은 2분 미사용 후 초기화됩니다.
- 현장 결제 방식입니다. 카드 결제와 SMS 발송은 연결하지 않았습니다.

## 검증

```sh
flutter analyze
flutter test
flutter build web --dart-define=CMS_BASE_URL=https://your-cms.example
```

테스트는 주입한 예약 저장소와 HTTP 테스트 클라이언트를 사용합니다. 실제 고객 예약을 생성하지 않습니다.
