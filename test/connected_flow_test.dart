import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigi_sports_kiosk/main.dart';
import 'package:gigi_sports_kiosk/models/reservation.dart';
import 'fake_booking_repository.dart';

class DelayedRepository extends FakeBookingRepository {
  final pending = Completer<Reservation>();
  @override
  Future<Reservation> create(
      ReservationDraft draft, String date, String requestId) {
    requestIds.add(requestId);
    return pending.future;
  }
}

void main() {
  Future<void> start(WidgetTester tester, FakeBookingRepository api) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(GigiKioskApp(api: api));
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pumpAndSettle();
  }

  Future<void> confirm(WidgetTester tester, {int? bay}) async {
    await tester.tap(find.byKey(const Key('new-booking-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00'));
    await tester.pump();
    if (bay != null) {
      await tester.ensureVisible(find.byKey(ValueKey('bay-$bay')));
      await tester.tap(find.byKey(ValueKey('bay-$bay')));
      await tester.pump();
    }
    await next(tester);
    await next(tester);
    for (final digit in '01012345678'.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    await next(tester);
  }

  testWidgets('selected bay appears in confirmation and is sent on create',
      (tester) async {
    final api = FakeBookingRepository();
    await start(tester, api);
    await confirm(tester, bay: 2);
    expect(find.text('2번 타석'), findsOneWidget);
    await next(tester);
    expect(api.createdBay, 2);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'duration change requires reselection when only the chosen bay becomes unavailable',
      (tester) async {
    final api = FakeBookingRepository()..selectedBayUnavailable = true;
    await start(tester, api);
    await tester.tap(find.byKey(const Key('new-booking-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('bay-2')));
    await tester.tap(find.byKey(const ValueKey('bay-2')));
    await next(tester);
    await tester.ensureVisible(find.text('90분'));
    await tester.tap(find.text('90분'));
    await tester.pumpAndSettle();
    expect(find.text('언제 이용하시나요?'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('continue-button')))
            .onPressed,
        isNull);
    await tester.ensureVisible(find.text('09:00'));
    await tester.tap(find.text('09:00'));
    await tester.pump();
    expect(find.byKey(const ValueKey('bay-2')), findsNothing);
    expect(find.byKey(const ValueKey('bay-1')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'network failure keeps confirmation and retries the same request id',
      (tester) async {
    final api = FakeBookingRepository()..failFirstCreate = true;
    await start(tester, api);
    await confirm(tester);
    await next(tester);
    expect(find.text('예약이 완료되었습니다!'), findsNothing);
    expect(find.text('통신 오류'), findsOneWidget);
    await next(tester);
    expect(api.requestIds.length, 2);
    expect(api.requestIds[0], api.requestIds[1]);
    expect(find.text('1234567890'), findsOneWidget);
    await tester.pump(const Duration(seconds: 91));
    await tester.pumpAndSettle();
    expect(find.text('새로 예약하기'), findsOneWidget);
  });
  testWidgets('duplicate taps cannot submit twice while awaiting the server',
      (tester) async {
    final api = DelayedRepository();
    await start(tester, api);
    await confirm(tester);
    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();
    expect(api.requestIds.length, 1);
    expect(find.text('예약이 완료되었습니다!'), findsNothing);
    api.pending.complete(api.result);
    await tester.pumpAndSettle();
    expect(find.text('1234567890'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'duration change refreshes availability and clears an unavailable selection',
      (tester) async {
    final api = FakeBookingRepository()..durationUnavailable = true;
    await start(tester, api);
    await tester.tap(find.byKey(const Key('new-booking-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00'));
    await tester.pump();
    await next(tester);
    await tester.ensureVisible(find.text('90분'));
    await tester.tap(find.text('90분'));
    await tester.pumpAndSettle();
    expect(find.text('언제 이용하시나요?'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('continue-button')))
            .onPressed,
        isNull);
  });
  testWidgets(
      'lookup returns a real result and clears personal information on idle',
      (tester) async {
    final api = FakeBookingRepository();
    await start(tester, api);
    await tester.tap(find.byKey(const Key('lookup-button')));
    await tester.pumpAndSettle();
    for (final digit in '01012345678'.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    expect(find.text('예약 번호 입력'), findsNothing);
    await tester.tap(find.text('예약 찾기'));
    await tester.pumpAndSettle();
    expect(api.lookupPhone, '01012345678');
    expect(find.text('예약 번호 1234567890'), findsOneWidget);
    await tester.pump(const Duration(minutes: 3));
    await tester.pumpAndSettle();
    expect(find.text('새로 예약하기'), findsOneWidget);
    expect(find.text('예약 번호 1234567890'), findsNothing);
  });
}
