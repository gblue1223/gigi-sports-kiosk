import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigi_sports_kiosk/main.dart';
import 'fake_booking_repository.dart';

void main() {
  Future<void> setPortraitSize(
    WidgetTester tester, {
    Size size = const Size(720, 1280),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('home screen fits a 9:16 kiosk display', (tester) async {
    await setPortraitSize(tester);
    await tester.pumpWidget(GigiKioskApp(api: FakeBookingRepository()));
    await tester.pumpAndSettle();

    expect(find.text('새로 예약하기'), findsOneWidget);
    expect(find.text('내 예약 확인'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(540, 960), const Size(720, 1280)]) {
    testWidgets('home actions remain reachable at $size with larger text',
        (tester) async {
      await setPortraitSize(tester, size: size);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(GigiKioskApp(api: FakeBookingRepository()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final lookup = find.byKey(const Key('lookup-button'));
      await tester.ensureVisible(lookup);
      await tester.pumpAndSettle();
      await tester.tap(lookup);
      await tester.pumpAndSettle();
      expect(find.text('예약을 확인할게요'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      final booking = find.byKey(const Key('new-booking-button'));
      await tester.ensureVisible(booking);
      await tester.pumpAndSettle();
      await tester.tap(booking);
      await tester.pumpAndSettle();
      expect(find.text('언제 이용하시나요?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('user can complete a reservation', (tester) async {
    await setPortraitSize(tester);
    await tester.pumpWidget(GigiKioskApp(api: FakeBookingRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('new-booking-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('09:00'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pumpAndSettle();

    expect(find.text('몇 분이 이용하시나요?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pumpAndSettle();

    expect(find.text('연락처를 입력해 주세요'), findsOneWidget);
    for (final digit in '01012345678'.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pumpAndSettle();

    expect(find.text('예약 내용을 확인해 주세요'), findsOneWidget);
    expect(find.text('010-1234-5678'), findsOneWidget);
    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pumpAndSettle();

    expect(find.text('예약이 완료되었습니다!'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('테스트 매장'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
