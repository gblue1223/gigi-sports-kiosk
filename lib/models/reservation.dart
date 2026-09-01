class BookingDate {
  const BookingDate({
    required this.label,
    required this.day,
    required this.weekday,
  });

  final String label;
  final int day;
  final String weekday;
}

class TimeSlot {
  const TimeSlot(this.time, {this.remaining = 3, this.enabled = true});

  final String time;
  final int remaining;
  final bool enabled;
}

class ReservationDraft {
  int dateIndex = 0;
  String? time;
  int players = 2;
  int duration = 60;
  String phone = '';

  int get price => players * (duration == 60 ? 10000 : 15000);

  void reset() {
    dateIndex = 0;
    time = null;
    players = 2;
    duration = 60;
    phone = '';
  }
}
