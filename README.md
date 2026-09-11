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

CMS `/reservations`에서 매장을 선택해 10자리 연결 코드를 발급한 뒤 키오스크에 입력합니다. 코드는 5분 내 1회 사용 가능하며 연결은 8시간 유지됩니다. 앱 재시작 또는 만료 후에는 다시 연결합니다.

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
