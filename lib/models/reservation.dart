class BookingDate {
  const BookingDate(
      {required this.iso,
      required this.label,
      required this.day,
      required this.weekday});
  factory BookingDate.fromIso(String iso, int index) {
    final date = DateTime.parse(iso);
    return BookingDate(
        iso: iso,
        label: index == 0
            ? '오늘'
            : index == 1
                ? '내일'
                : '${date.month}월 ${date.day}일',
        day: date.day,
        weekday: ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1]);
  }
  final String iso;
  final String label;
  final int day;
  final String weekday;
  String get fullLabel => '${DateTime.parse(iso).month}월 $day일 ($weekday)';
}

class TimeSlot {
  const TimeSlot(this.time,
      {this.remaining = 0,
      this.enabled = false,
      this.availableBays = const []});
  final String time;
  final int remaining;
  final bool enabled;
  final List<int> availableBays;
}

class BookingConfig {
  const BookingConfig(
      {required this.storeName,
      required this.dates,
      required this.price60,
      required this.price90,
      required this.openMinute,
      required this.closeMinute});
  factory BookingConfig.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>;
    final dates = json['dates'] as List;
    return BookingConfig(
        storeName: store['name'] as String,
        dates: List.generate(
            dates.length, (i) => BookingDate.fromIso(dates[i] as String, i)),
        price60: store['price_60'] as int,
        price90: store['price_90'] as int,
        openMinute: store['open_minute'] as int,
        closeMinute: store['close_minute'] as int);
  }
  final String storeName;
  final List<BookingDate> dates;
  final int price60;
  final int price90;
  final int openMinute;
  final int closeMinute;
  String get hours {
    String time(int m) =>
        '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
    return '${time(openMinute)} – ${time(closeMinute)}';
  }
}

class ReservationDraft {
  int dateIndex = 0;
  String? time;
  int? bayNumber;
  int players = 2;
  int duration = 60;
  String phone = '';
  int price60 = 0;
  int price90 = 0;
  String storeName = '';
  int get price => players * (duration == 60 ? price60 : price90);
}

class Reservation {
  const Reservation(
      {required this.id,
      required this.code,
      required this.startsAt,
      required this.players,
      required this.duration,
      required this.totalPrice,
      required this.bayNumber,
      required this.status});
  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
      id: json['id'] as String,
      code: json['code'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String).toUtc(),
      players: json['players'] as int,
      duration: json['duration'] as int,
      totalPrice: json['total_price'] as int,
      bayNumber: json['bay_number'] as int,
      status: json['status'] as String);
  final String id;
  final String code;
  final DateTime startsAt;
  final int players;
  final int duration;
  final int totalPrice;
  final int bayNumber;
  final String status;
  String get dateLabel {
    final d = startsAt.toUtc().add(const Duration(hours: 9));
    return '${d.month}월 ${d.day}일 ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get statusLabel =>
      const {
        'confirmed': '예약 확정',
        'checked_in': '입장',
        'completed': '이용 완료',
        'cancelled': '취소',
        'no_show': '미방문'
      }[status] ??
      status;
}
