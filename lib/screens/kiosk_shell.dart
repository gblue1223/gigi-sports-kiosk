import 'dart:async';
import 'package:flutter/material.dart';
import '../services/booking_api.dart';
import 'connected_booking.dart';

import '../models/reservation.dart';
import '../theme.dart';
import '../widgets/kiosk_chrome.dart';
import 'home_screen.dart';

enum KioskRoute { home, booking, lookup }

class KioskShell extends StatefulWidget {
  const KioskShell({this.api, super.key});
  final BookingRepository? api;

  @override
  State<KioskShell> createState() => _KioskShellState();
}

class _KioskShellState extends State<KioskShell> {
  KioskRoute route = KioskRoute.home;
  late final BookingRepository api;
  Timer? idle;
  @override
  void initState() {
    super.initState();
    api = widget.api ?? CmsBookingApi();
  }

  void _activity() {
    idle?.cancel();
    if (route == KioskRoute.lookup) {
      idle = Timer(const Duration(minutes: 2), _goHome);
    }
  }

  @override
  void dispose() {
    idle?.cancel();
    if (widget.api == null) api.close();
    super.dispose();
  }

  void _goHome() {
    idle?.cancel();
    if (mounted) setState(() => route = KioskRoute.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KioskColors.forest,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: DecoratedBox(
                decoration: const BoxDecoration(color: KioskColors.cream),
                child: SafeArea(
                  child: Listener(
                      onPointerDown: (_) => _activity(),
                      child: !api.paired
                          ? PairingScreen(
                              api: api, onPaired: () => setState(() {}))
                          : switch (route) {
                              KioskRoute.home => HomeScreen(
                                  onBooking: () => setState(
                                      () => route = KioskRoute.booking),
                                  onLookup: () => setState(() {
                                    route = KioskRoute.lookup;
                                    _activity();
                                  }),
                                ),
                              KioskRoute.booking =>
                                BookingFlowScreen(onExit: _goHome, api: api),
                              KioskRoute.lookup =>
                                LookupScreen(onExit: _goHome, api: api),
                            }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BookingProgress extends StatelessWidget {
  const BookingProgress({required this.currentStep, super.key});

  final int currentStep;

  static const labels = ['일시', '인원', '연락처', '확인'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (index) {
          if (index.isOdd) {
            final active = index ~/ 2 < currentStep;
            return Expanded(
              child: Container(
                height: 3,
                color: active ? KioskColors.greenDark : KioskColors.line,
              ),
            );
          }
          final item = index ~/ 2;
          final active = item <= currentStep;
          return Column(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? KioskColors.greenDark : KioskColors.creamDark,
                  shape: BoxShape.circle,
                ),
                child: item < currentStep
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 23,
                      )
                    : Text(
                        '${item + 1}',
                        style: TextStyle(
                          color: active ? Colors.white : KioskColors.subtle,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[item],
                style: TextStyle(
                  color: active ? KioskColors.greenDark : KioskColors.subtle,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class DateTimeStep extends StatelessWidget {
  const DateTimeStep({
    required this.dates,
    required this.slots,
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final List<BookingDate> dates;
  final List<TimeSlot> slots;
  final ReservationDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 30),
      children: [
        Text('언제 이용하시나요?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('날짜와 시작 시간을 선택해 주세요.'),
        const SizedBox(height: 24),
        SizedBox(
          height: 104 * MediaQuery.textScalerOf(context).scale(1),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = dates[index];
              final selected = draft.dateIndex == index;
              return ChoiceChip(
                selected: selected,
                showCheckmark: false,
                onSelected: (_) {
                  draft.dateIndex = index;
                  draft.time = null;
                  draft.bayNumber = null;
                  onChanged();
                },
                label: SizedBox(
                  width: 78 * MediaQuery.textScalerOf(context).scale(1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.day}',
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${item.weekday}요일',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                labelPadding: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
                selectedColor: KioskColors.greenDark,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : KioskColors.ink,
                ),
                side: BorderSide(
                  color: selected ? KioskColors.greenDark : KioskColors.line,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              );
            },
          ),
        ),
        if (draft.time != null) ...[
          const SizedBox(height: 24),
          const Text('이용 타석',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('${draft.time}부터 ${draft.duration}분 동안 이용 가능한 타석입니다.'),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            ChoiceChip(
              label: const Text('자동 배정'),
              selected: draft.bayNumber == null,
              onSelected: (_) {
                draft.bayNumber = null;
                onChanged();
              },
            ),
            for (final slot in slots.where((slot) => slot.time == draft.time))
              for (final bay in slot.availableBays)
                ChoiceChip(
                  key: ValueKey('bay-$bay'),
                  label: Text('$bay번 타석'),
                  selected: draft.bayNumber == bay,
                  onSelected: (_) {
                    draft.bayNumber = bay;
                    onChanged();
                  },
                ),
          ]),
        ],
        const SizedBox(height: 30),
        Row(
          children: [
            const Text(
              '시작 시간',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Container(width: 10, height: 10, color: KioskColors.line),
            const SizedBox(width: 7),
            const Text(
              '예약 마감',
              style: TextStyle(color: KioskColors.muted, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            childAspectRatio: 1.7,
          ),
          itemBuilder: (context, index) {
            final slot = slots[index];
            final selected = draft.time == slot.time;
            return _TimeButton(
              slot: slot,
              selected: selected,
              onTap: slot.enabled
                  ? () {
                      draft.time = slot.time;
                      draft.bayNumber = null;
                      onChanged();
                    }
                  : null,
            );
          },
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final TimeSlot slot;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: !slot.enabled
          ? KioskColors.creamDark
          : selected
              ? KioskColors.greenDark
              : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? KioskColors.greenDark : KioskColors.line,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slot.time,
                style: TextStyle(
                  color: !slot.enabled
                      ? KioskColors.subtle
                      : selected
                          ? Colors.white
                          : KioskColors.ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                slot.enabled ? '${slot.remaining}자리 남음' : '예약 마감',
                style: TextStyle(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.78)
                      : KioskColors.subtle,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PartyStep extends StatelessWidget {
  const PartyStep({required this.draft, required this.onChanged, super.key});

  final ReservationDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 30),
      children: [
        Text('몇 분이 이용하시나요?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('이용 인원과 시간을 선택해 주세요.'),
        const SizedBox(height: 28),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이용 인원',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CounterButton(
                      icon: Icons.remove_rounded,
                      label: '인원 줄이기',
                      enabled: draft.players > 1,
                      onTap: () {
                        draft.players--;
                        onChanged();
                      },
                    ),
                    SizedBox(
                      width: 180,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${draft.players}',
                              style: const TextStyle(
                                color: KioskColors.greenDark,
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(
                              text: ' 명',
                              style: TextStyle(
                                color: KioskColors.ink,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _CounterButton(
                      icon: Icons.add_rounded,
                      label: '인원 늘리기',
                      enabled: draft.players < 4,
                      onTap: () {
                        draft.players++;
                        onChanged();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    '한 타석은 최대 4명까지 이용할 수 있습니다',
                    style: TextStyle(color: KioskColors.muted, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '이용 시간',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        _DurationOption(
          minutes: 60,
          price: draft.price60,
          description: '가볍게 한 라운드',
          selected: draft.duration == 60,
          onTap: () {
            draft.duration = 60;
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        _DurationOption(
          minutes: 90,
          price: draft.price90,
          description: '여유 있게 즐기기',
          selected: draft.duration == 90,
          recommended: true,
          onTap: () {
            draft.duration = 90;
            onChanged();
          },
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      child: IconButton.filledTonal(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: 34),
        style: IconButton.styleFrom(
          minimumSize: const Size(72, 72),
          backgroundColor: KioskColors.greenSoft,
          foregroundColor: KioskColors.greenDark,
          disabledBackgroundColor: KioskColors.creamDark,
          disabledForegroundColor: KioskColors.subtle,
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  const _DurationOption({
    required this.minutes,
    required this.price,
    required this.description,
    required this.selected,
    required this.onTap,
    this.recommended = false,
  });

  final int minutes;
  final int price;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? KioskColors.greenSoft : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? KioskColors.greenDark : KioskColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? KioskColors.greenDark : KioskColors.subtle,
                size: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$minutes분',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (recommended) ...[
                          const SizedBox(width: 9),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: KioskColors.gold,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '추천',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: KioskColors.muted,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_formatNumber(price)}원/인',
                style: const TextStyle(
                  color: KioskColors.greenDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactStep extends StatelessWidget {
  const ContactStep({required this.draft, required this.onChanged, super.key});

  final ReservationDraft draft;
  final VoidCallback onChanged;

  void _press(String value) {
    if (value == 'back') {
      if (draft.phone.isNotEmpty) {
        draft.phone = draft.phone.substring(0, draft.phone.length - 1);
      }
    } else if (draft.phone.length < 11) {
      draft.phone += value;
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 30),
      children: [
        Text('연락처를 입력해 주세요', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('예약 확인에 사용할 휴대폰 번호입니다.'),
        const SizedBox(height: 24),
        PhoneDisplay(phone: draft.phone),
        const SizedBox(height: 18),
        NumberPad(onPressed: _press),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: KioskColors.greenSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: KioskColors.greenDark,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '입력한 번호는 예약 확인과 안내에만 사용됩니다.',
                  style: TextStyle(
                    color: KioskColors.greenDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PhoneDisplay extends StatelessWidget {
  const PhoneDisplay({required this.phone, super.key});

  final String phone;

  @override
  Widget build(BuildContext context) {
    final formatted = _formatPhone(phone);
    return Semantics(
      label: phone.isEmpty ? '휴대폰 번호 입력란' : '입력된 번호 $formatted',
      child: Container(
        height: 82,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                phone.length == 11 ? KioskColors.greenDark : KioskColors.line,
            width: 2,
          ),
        ),
        child: Text(
          phone.isEmpty ? '010 -          -' : formatted,
          style: TextStyle(
            color: phone.isEmpty ? KioskColors.subtle : KioskColors.ink,
            fontSize: 30,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class NumberPad extends StatelessWidget {
  const NumberPad({required this.onPressed, super.key});

  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'back'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final keyValue = keys[index];
        if (keyValue.isEmpty) return const SizedBox.shrink();
        final isBack = keyValue == 'back';
        return Semantics(
          button: true,
          label: isBack ? '한 글자 지우기' : keyValue,
          child: Material(
            color: isBack ? KioskColors.creamDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => onPressed(keyValue),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KioskColors.line),
                ),
                child: isBack
                    ? const Icon(
                        Icons.backspace_outlined,
                        color: KioskColors.ink,
                        size: 28,
                      )
                    : Text(
                        keyValue,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ConfirmStep extends StatelessWidget {
  const ConfirmStep({required this.draft, required this.dates, super.key});

  final ReservationDraft draft;
  final List<BookingDate> dates;

  @override
  Widget build(BuildContext context) {
    final date = dates[draft.dateIndex];
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 30),
      children: [
        Text(
          '예약 내용을 확인해 주세요',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text('내용이 맞으면 아래 예약 확정 버튼을 눌러주세요.'),
        const SizedBox(height: 26),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _SummaryRow(
                  icon: Icons.storefront_rounded,
                  label: '매장',
                  value: draft.storeName,
                ),
                const Divider(height: 30),
                _SummaryRow(
                  icon: Icons.calendar_month_rounded,
                  label: '예약 일시',
                  value: '${date.fullLabel}  ${draft.time}',
                ),
                const Divider(height: 30),
                _SummaryRow(
                  icon: Icons.groups_rounded,
                  label: '이용 인원',
                  value: '${draft.players}명 · ${draft.duration}분',
                ),
                const Divider(height: 30),
                _SummaryRow(
                  icon: Icons.sports_golf_rounded,
                  label: '이용 타석',
                  value: draft.bayNumber == null
                      ? '자동 배정'
                      : '${draft.bayNumber}번 타석',
                ),
                const Divider(height: 30),
                _SummaryRow(
                  icon: Icons.phone_rounded,
                  label: '연락처',
                  value: _formatPhone(draft.phone),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [KioskColors.black, Color(0xFF0D2417)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text(
                '현장 결제 금액',
                style: TextStyle(
                  color: Color(0xFFB9B6A8),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${_formatNumber(draft.price)}원',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '※ 결제는 방문하신 뒤 카운터에서 진행합니다. 예약 시간 10분 전까지 방문해 주세요.',
          style: TextStyle(color: KioskColors.muted, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: KioskColors.greenSoft,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: KioskColors.greenDark, size: 27),
        ),
        const SizedBox(width: 17),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: KioskColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: KioskColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BookingBottomBar extends StatelessWidget {
  const BookingBottomBar({
    required this.step,
    required this.enabled,
    required this.onBack,
    required this.onNext,
    super.key,
  });

  final int step;
  final bool enabled;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: KioskColors.line)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 138,
            child: OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('이전'),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: FilledButton(
              key: const Key('continue-button'),
              onPressed: enabled ? onNext : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(step == 3 ? '예약 확정' : '다음'),
                  const SizedBox(width: 9),
                  Icon(
                    step == 3
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({
    required this.draft,
    required this.onDone,
    required this.reservation,
    super.key,
  });

  final ReservationDraft draft;
  final VoidCallback onDone;
  final Reservation reservation;
  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  Timer? timer;
  ReservationDraft get draft => widget.draft;
  Reservation get reservation => widget.reservation;
  VoidCallback get onDone => widget.onDone;
  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 90), () {
      if (mounted) onDone();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const KioskHeader(showHome: false),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: KioskColors.greenSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: KioskColors.greenDark,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '예약이 완료되었습니다!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '예약 번호를 사진으로 남겨 주세요.\n90초 뒤 첫 화면으로 돌아갑니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 19),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: KioskColors.line),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '예약 번호',
                          style: TextStyle(
                            color: KioskColors.muted,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reservation.code,
                          style: const TextStyle(
                            color: KioskColors.greenDark,
                            fontSize: 31,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Divider(height: 34),
                        Text(
                          '${reservation.dateLabel} · ${reservation.players}명\n${reservation.bayNumber}번 타석 · ${reservation.totalPrice}원',
                          style: const TextStyle(
                            color: KioskColors.ink,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          draft.storeName,
                          style: const TextStyle(
                            color: KioskColors.muted,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDone,
              icon: const Icon(Icons.home_rounded),
              label: const Text('첫 화면으로 돌아가기'),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatPhone(String value) {
  if (value.length <= 3) return value;
  if (value.length <= 7) {
    return '${value.substring(0, 3)}-${value.substring(3)}';
  }
  return '${value.substring(0, 3)}-${value.substring(3, 7)}-${value.substring(7)}';
}

String _formatNumber(int value) {
  final source = value.toString();
  final result = StringBuffer();
  for (var index = 0; index < source.length; index++) {
    if (index > 0 && (source.length - index) % 3 == 0) result.write(',');
    result.write(source[index]);
  }
  return result.toString();
}
