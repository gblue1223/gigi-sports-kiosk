import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../theme.dart';

class LookupReservationCard extends StatelessWidget {
  const LookupReservationCard({required this.reservation, super.key});
  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final row = reservation;
    final start = row.startsAt.toUtc().add(const Duration(hours: 9));
    final end = start.add(Duration(minutes: row.duration));
    String clock(DateTime date) =>
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][start.weekday - 1];
    final amount = row.totalPrice.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
    final (Color accent, Color tint, IconData icon) = switch (row.status) {
      'confirmed' => (
          KioskColors.greenDark,
          KioskColors.greenSoft,
          Icons.check_circle_outline_rounded
        ),
      'checked_in' => (
          const Color(0xFF165D91),
          const Color(0xFFEAF3FA),
          Icons.sports_golf_rounded
        ),
      'cancelled' => (
          const Color(0xFFA8463C),
          const Color(0xFFFBEFEC),
          Icons.cancel_outlined
        ),
      'no_show' => (
          const Color(0xFF806019),
          const Color(0xFFF7F1E2),
          Icons.event_busy_outlined
        ),
      _ => (KioskColors.muted, KioskColors.creamDark, Icons.task_alt_rounded),
    };
    final active = row.status == 'confirmed' || row.status == 'checked_in';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(height: 5, color: active ? accent : KioskColors.line),
        Padding(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                      '${start.year}년 ${start.month}월 ${start.day}일 ($weekday)',
                      style: const TextStyle(
                          fontSize: 20,
                          color: KioskColors.ink,
                          fontWeight: FontWeight.w700)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                        color: tint, borderRadius: BorderRadius.circular(30)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon, size: 19, color: accent),
                      const SizedBox(width: 6),
                      Text(row.statusLabel,
                          style: TextStyle(
                              color: accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ]),
            const SizedBox(height: 22),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('시작 시간', style: TextStyle(fontSize: 15)),
                    Text(clock(start),
                        style: const TextStyle(
                            fontSize: 42,
                            height: 1.2,
                            letterSpacing: -1,
                            color: KioskColors.ink,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('${clock(end)} 종료',
                        style: const TextStyle(fontSize: 17)),
                  ])),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                decoration: BoxDecoration(
                    color: active ? tint : KioskColors.cream,
                    borderRadius: BorderRadius.circular(18)),
                child: Column(children: [
                  Text('이용 타석',
                      style: TextStyle(
                          color: active ? accent : KioskColors.muted,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Text('${row.bayNumber}번',
                      style: TextStyle(
                          color: active ? accent : KioskColors.muted,
                          fontSize: 32,
                          height: 1.2,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
            ]),
            const SizedBox(height: 22),
            const Divider(height: 1),
            const SizedBox(height: 18),
            SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 20,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.people_outline_rounded,
                          size: 22, color: KioskColors.muted),
                      const SizedBox(width: 8),
                      Text('${row.players}명 · ${row.duration}분',
                          style: const TextStyle(
                              fontSize: 18,
                              color: KioskColors.ink,
                              fontWeight: FontWeight.w600)),
                    ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('현장 결제 금액',
                              style: TextStyle(fontSize: 14)),
                          Text('$amount원',
                              style: const TextStyle(
                                  fontSize: 24,
                                  color: KioskColors.ink,
                                  fontWeight: FontWeight.w800)),
                        ]),
                  ],
                )),
            const SizedBox(height: 16),
            Text('예약 번호 ${row.code}',
                style: const TextStyle(
                    fontSize: 14,
                    color: KioskColors.muted,
                    letterSpacing: 0.4)),
          ]),
        ),
      ]),
    );
  }
}
