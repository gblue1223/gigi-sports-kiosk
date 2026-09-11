import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gigi_sports_kiosk/services/booking_api.dart';
import 'package:gigi_sports_kiosk/models/reservation.dart';

void main() {
  http.Response paired() => http.Response(
      jsonEncode({
        'token': 'short-session',
        'expiresAt':
            DateTime.now().add(const Duration(hours: 8)).toIso8601String()
      }),
      200);
  test(
      'requires pairing and sends only an issued session, with booking price and request id',
      () async {
    final requests = <http.Request>[];
    final api = CmsBookingApi(
        baseUrl: 'https://cms.example',
        client: MockClient((request) async {
          requests.add(request);
          if (request.url.path.endsWith('/pair')) return paired();
          return http.Response(
              jsonEncode({
                'reservation': {
                  'id': '1',
                  'code': '0123456789',
                  'starts_at': '2026-12-01T00:00:00Z',
                  'players': 2,
                  'duration': 60,
                  'total_price': 24000,
                  'bay_number': 1,
                  'status': 'confirmed'
                }
              }),
              201);
        }));
    expect(api.paired, false);
    await expectLater(api.config(), throwsA(isA<BookingApiException>()));
    expect(requests, isEmpty);
    await api.pair('1234567890');
    expect(requests.first.headers.containsKey('authorization'), false);
    final draft = ReservationDraft()
      ..phone = '01012345678'
      ..time = '09:00'
      ..price60 = 12000;
    final id = newRequestId();
    final result = await api.create(draft, '2026-12-01', id);
    expect(result.code, '0123456789');
    expect(requests.last.headers['authorization'], 'Bearer short-session');
    expect(jsonDecode(requests.last.body), {
      'date': '2026-12-01',
      'time': '09:00',
      'players': 2,
      'duration': 60,
      'phone': '01012345678',
      'requestId': id,
      'expectedPrice': 24000
    });
  });
  test('revokes local session on 401 and surfaces conflict instead of success',
      () async {
    var status = 409;
    final api = CmsBookingApi(
        baseUrl: 'https://cms.example',
        client: MockClient((r) async => r.url.path.endsWith('/pair')
            ? paired()
            : http.Response(jsonEncode({'message': '예약 마감'}), status,
                headers: {'content-type': 'application/json; charset=utf-8'})));
    await api.pair('1234567890');
    await expectLater(
        api.availability('2026-12-01', 90),
        throwsA(
            isA<BookingApiException>().having((e) => e.status, 'status', 409)));
    status = 401;
    await expectLater(api.lookup('01012345678', '1234567890'),
        throwsA(isA<BookingApiException>()));
    expect(api.paired, false);
  });
  test('lookup uses POST body so phone does not appear in URL', () async {
    late http.Request request;
    final api = CmsBookingApi(
        baseUrl: 'https://cms.example',
        client: MockClient((r) async {
          if (r.url.path.endsWith('/pair')) return paired();
          request = r;
          return http.Response('{"reservations":[]}', 200);
        }));
    await api.pair('1234567890');
    expect(await api.lookup('01012345678', '1234567890'), isEmpty);
    expect(request.method, 'POST');
    expect(request.url.query, isEmpty);
    expect(jsonDecode(request.body),
        {'phone': '01012345678', 'code': '1234567890'});
  });
  test('request ids are version 4 UUIDs and differ', () {
    final ids = List.generate(100, (_) => newRequestId());
    expect(ids.toSet().length, 100);
    expect(
        ids.every((id) => RegExp(
                r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
            .hasMatch(id)),
        true);
  });
}
