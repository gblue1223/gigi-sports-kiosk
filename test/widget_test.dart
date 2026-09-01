import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigi_sports_kiosk/main.dart';

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
    await tester.pumpWidget(const GigiKioskApp());
    await tester.pumpAndSettle();

    expect(find.text('새로 예약하기'), findsOneWidget);
    expect(find.text('내 예약 확인'), findsOneWidget);
    expect(find.byType(FlutterError), findsNothing);
  });

  testWidgets('user can complete a reservation', (tester) async {
    await setPortraitSize(tester);
    await tester.pumpWidget(const GigiKioskApp());
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
    expect(find.text('GIGI-0901-024'), findsOneWidget);
  });
}
