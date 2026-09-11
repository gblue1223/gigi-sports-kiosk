import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';

class BookingApiException implements Exception {
  const BookingApiException(this.message, {this.status});
  final String message;
  final int? status;
  @override
  String toString() => message;
}

abstract class BookingRepository {
  bool get paired => true;
  Future<void> pair(String code) async {}
  Future<BookingConfig> config();
  Future<List<TimeSlot>> availability(String date, int duration);
  Future<Reservation> create(
      ReservationDraft draft, String date, String requestId);
  Future<List<Reservation>> lookup(String phone, String code);
  void close() {}
}

class CmsBookingApi extends BookingRepository {
  CmsBookingApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? const String.fromEnvironment('CMS_BASE_URL');
  final http.Client _client;
  final String _baseUrl;
  // Short-lived credentials issued after one-time CMS pairing; never persisted.
  String? _token;
  DateTime? _expiresAt;
  @override
  bool get paired =>
      _token != null && (_expiresAt?.isAfter(DateTime.now()) ?? false);
  Future<Map<String, dynamic>> _request(String endpoint,
      {Map<String, String>? query, Map<String, dynamic>? body}) async {
    final base = Uri.tryParse(_baseUrl);
    if (base == null ||
        !base.hasAuthority ||
        !['http', 'https'].contains(base.scheme)) {
      throw const BookingApiException('CMS 서버 주소 설정이 필요합니다. 직원에게 문의해 주세요.');
    }
    if (base.scheme != 'https' &&
        !['localhost', '127.0.0.1', '10.0.2.2', '[::1]'].contains(base.host)) {
      throw const BookingApiException('CMS 서버는 HTTPS 주소를 사용해야 합니다.');
    }
    if (endpoint != 'pair' && !paired) {
      throw const BookingApiException('키오스크 연결이 만료되었습니다. 첫 화면에서 재연결해 주세요.',
          status: 401);
    }
    final url =
        base.resolve('/api/kiosk/$endpoint').replace(queryParameters: query);
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token'
    };
    try {
      final response = await (body == null
              ? _client.get(url, headers: headers)
              : _client.post(url, headers: headers, body: jsonEncode(body)))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 401) _token = null;
      Map<String, dynamic> data;
      try {
        data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } catch (_) {
        throw const BookingApiException('서버 응답을 확인할 수 없습니다. 직원에게 문의해 주세요.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw BookingApiException(
            data['message'] as String? ?? '요청을 처리하지 못했습니다.',
            status: response.statusCode);
      }
      return data;
    } on TimeoutException {
      throw const BookingApiException('응답이 늦어지고 있습니다. 같은 화면에서 다시 시도해 주세요.');
    } on http.ClientException {
      throw const BookingApiException('서버에 연결하지 못했습니다. 네트워크를 확인하고 다시 시도해 주세요.');
    }
  }

  @override
  Future<void> pair(String code) async {
    final data = await _request('pair', body: {'code': code});
    _expiresAt = DateTime.parse(data['expiresAt'] as String);
    _token = data['token'] as String;
  }

  @override
  Future<BookingConfig> config() async =>
      BookingConfig.fromJson(await _request('config'));
  @override
  Future<List<TimeSlot>> availability(String date, int duration) async {
    final data = await _request('availability',
        query: {'date': date, 'duration': '$duration'});
    return (data['slots'] as List)
        .map((v) => TimeSlot(v['time'] as String,
            remaining: v['remaining'] as int,
            enabled: (v['remaining'] as int) > 0))
        .toList();
  }

  @override
  Future<Reservation> create(
      ReservationDraft draft, String date, String requestId) async {
    final data = await _request('reservations', body: {
      'date': date,
      'time': draft.time,
      'players': draft.players,
      'duration': draft.duration,
      'phone': draft.phone,
      'requestId': requestId,
      'expectedPrice': draft.price,
    });
    return Reservation.fromJson(data['reservation'] as Map<String, dynamic>);
  }

  @override
  Future<List<Reservation>> lookup(String phone, String code) async {
    final data = await _request('lookup', body: {'phone': phone, 'code': code});
    return (data['reservations'] as List)
        .map((v) => Reservation.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  @override
  void close() => _client.close();
}

String newRequestId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
