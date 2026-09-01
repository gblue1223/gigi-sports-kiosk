# GIGI Sports Kiosk

9:16 세로형 모니터에 맞춘 시니어 친화 예약 키오스크 프로토타입입니다.

## 지원 플랫폼

- Android
- Web
- Windows
- Linux

## 실행

```sh
flutter pub get
flutter run -d windows
```

Web은 `flutter run -d chrome`, Linux는 `flutter run -d linux`, Android는 연결된
기기에서 `flutter run`으로 실행할 수 있습니다.

## 주요 흐름

첫 화면의 **새로 예약하기**를 선택한 뒤 날짜/시간, 이용 인원/시간, 연락처를
입력하고 최종 확인하면 예약 번호가 생성됩니다. 현재 데이터는 UI 검증을 위한
로컬 데모 데이터이며 서버 API 연결 지점은 `BookingFlowScreen`의 예약 완료
메서드입니다.
