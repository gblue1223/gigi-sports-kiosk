import 'package:gigi_sports_kiosk/models/reservation.dart';
import 'package:gigi_sports_kiosk/services/booking_api.dart';

class FakeBookingRepository extends BookingRepository {
  final requestIds = <String>[];
  bool failFirstCreate = false;
  bool durationUnavailable = false;
  String? lookupPhone;
  String? lookupCode;
  final result = Reservation(
      id: 'test',
      code: '1234567890',
      startsAt: DateTime.utc(2026, 12, 1),
      players: 2,
      duration: 60,
      totalPrice: 24000,
      bayNumber: 2,
      status: 'confirmed');
  @override
  Future<BookingConfig> config() async => BookingConfig(
      storeName: '테스트 매장',
      dates: [
        BookingDate.fromIso('2026-12-01', 0),
        BookingDate.fromIso('2026-12-02', 1)
      ],
      price60: 12000,
      price90: 18000,
      openMinute: 540,
      closeMinute: 1320);
  @override
  Future<List<TimeSlot>> availability(String date, int duration) async => [
        TimeSlot('09:00',
            remaining: durationUnavailable && duration == 90 ? 0 : 2,
            enabled: !(durationUnavailable && duration == 90)),
        const TimeSlot('10:00'),
      ];
  @override
  Future<Reservation> create(
      ReservationDraft draft, String date, String requestId) async {
    requestIds.add(requestId);
    if (failFirstCreate && requestIds.length == 1) {
      throw const BookingApiException('통신 오류');
    }
    return result;
  }

  @override
  Future<List<Reservation>> lookup(String phone, String code) async {
    lookupPhone = phone;
    lookupCode = code;
    return phone == '01012345678' && code == result.code ? [result] : [];
  }
}
