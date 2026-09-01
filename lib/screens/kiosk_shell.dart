import 'package:flutter/material.dart';

import '../models/reservation.dart';
import '../theme.dart';

enum KioskRoute { home, booking, lookup }

class KioskShell extends StatefulWidget {
  const KioskShell({super.key});

  @override
  State<KioskShell> createState() => _KioskShellState();
}

class _KioskShellState extends State<KioskShell> {
  KioskRoute route = KioskRoute.home;

  void _goHome() => setState(() => route = KioskRoute.home);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KioskColors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: DecoratedBox(
                decoration: const BoxDecoration(color: KioskColors.cream),
                child: SafeArea(
                  child: switch (route) {
                    KioskRoute.home => HomeScreen(
                      onBooking: () =>
                          setState(() => route = KioskRoute.booking),
                      onLookup: () => setState(() => route = KioskRoute.lookup),
                    ),
                    KioskRoute.booking => BookingFlowScreen(onExit: _goHome),
                    KioskRoute.lookup => LookupScreen(onExit: _goHome),
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onBooking,
    required this.onLookup,
    super.key,
  });

  final VoidCallback onBooking;
  final VoidCallback onLookup;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const KioskHeader(showHome: false),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 28),
            children: [
              Semantics(
                header: true,
                child: Text(
                  '스크린 파크골프,\n쉽고 빠르게 예약하세요',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '원하시는 메뉴를 눌러주세요.\n예약은 1분이면 충분합니다.',
                style: TextStyle(
                  color: KioskColors.muted,
                  fontSize: 20,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 34),
              _HomeActionCard(
                key: const Key('new-booking-button'),
                icon: Icons.calendar_month_rounded,
                title: '새로 예약하기',
                description: '날짜와 시간을 선택해 예약합니다',
                color: KioskColors.green,
                foreground: Colors.white,
                onTap: onBooking,
              ),
              const SizedBox(height: 18),
              _HomeActionCard(
                key: const Key('lookup-button'),
                icon: Icons.search_rounded,
                title: '내 예약 확인',
                description: '휴대폰 번호로 예약을 찾습니다',
                color: Colors.white,
                foreground: KioskColors.ink,
                onTap: onLookup,
              ),
              const SizedBox(height: 26),
              const _TodayInfo(),
            ],
          ),
        ),
        const HelpFooter(),
      ],
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.foreground,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $description',
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            constraints: const BoxConstraints(minHeight: 142),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: color == Colors.white
                    ? KioskColors.line
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1414140A),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: foreground, size: 38),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        description,
                        style: TextStyle(
                          color: foreground.withValues(alpha: 0.76),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: foreground, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayInfo extends StatelessWidget {
  const _TodayInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
      decoration: BoxDecoration(
        color: KioskColors.greenSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.schedule_rounded, color: KioskColors.greenDark, size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘 운영시간',
                  style: TextStyle(
                    color: KioskColors.greenDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '오전 9:00 ~ 오후 10:00',
                  style: TextStyle(
                    color: KioskColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _OpenBadge(),
        ],
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        '영업 중',
        style: TextStyle(
          color: KioskColors.greenDark,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({required this.onExit, super.key});

  final VoidCallback onExit;

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  static const dates = [
    BookingDate(label: '오늘', day: 1, weekday: '화'),
    BookingDate(label: '내일', day: 2, weekday: '수'),
    BookingDate(label: '9월 3일', day: 3, weekday: '목'),
    BookingDate(label: '9월 4일', day: 4, weekday: '금'),
    BookingDate(label: '9월 5일', day: 5, weekday: '토'),
  ];

  static const slots = [
    TimeSlot('09:00', remaining: 2),
    TimeSlot('10:00', enabled: false),
    TimeSlot('11:00', remaining: 1),
    TimeSlot('12:00', remaining: 3),
    TimeSlot('13:00', remaining: 2),
    TimeSlot('14:00', remaining: 3),
    TimeSlot('15:00', enabled: false),
    TimeSlot('16:00', remaining: 2),
    TimeSlot('17:00', remaining: 1),
    TimeSlot('18:00', remaining: 3),
    TimeSlot('19:00', remaining: 2),
    TimeSlot('20:00', remaining: 3),
  ];

  final draft = ReservationDraft();
  int step = 0;
  bool completed = false;

  bool get canContinue => switch (step) {
    0 => draft.time != null,
    1 => true,
    2 => draft.phone.length == 11,
    3 => true,
    _ => false,
  };

  void _back() {
    if (step == 0) {
      _confirmExit();
    } else {
      setState(() => step--);
    }
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약을 그만할까요?'),
        content: const Text('선택한 내용은 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('계속 예약하기'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('첫 화면으로'),
          ),
        ],
      ),
    );
    if (shouldExit == true) widget.onExit();
  }

  void _next() {
    if (!canContinue) return;
    if (step < 3) {
      setState(() => step++);
    } else {
      setState(() => completed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return BookingSuccessScreen(draft: draft, onDone: widget.onExit);
    }

    return Column(
      children: [
        KioskHeader(onHome: _confirmExit),
        BookingProgress(currentStep: step),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(
              key: ValueKey(step),
              child: switch (step) {
                0 => DateTimeStep(
                  dates: dates,
                  slots: slots,
                  draft: draft,
                  onChanged: () => setState(() {}),
                ),
                1 => PartyStep(draft: draft, onChanged: () => setState(() {})),
                2 => ContactStep(
                  draft: draft,
                  onChanged: () => setState(() {}),
                ),
                _ => ConfirmStep(draft: draft, dates: dates),
              },
            ),
          ),
        ),
        BookingBottomBar(
          step: step,
          enabled: canContinue,
          onBack: _back,
          onNext: _next,
        ),
      ],
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
                color: active ? KioskColors.green : KioskColors.line,
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
                  color: active ? KioskColors.green : KioskColors.creamDark,
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
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[item],
                style: TextStyle(
                  color: active ? KioskColors.greenDark : KioskColors.subtle,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
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
          height: 104,
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
                  onChanged();
                },
                label: SizedBox(
                  width: 78,
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
                          fontWeight: FontWeight.w900,
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
                selectedColor: KioskColors.green,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : KioskColors.ink,
                ),
                side: BorderSide(
                  color: selected ? KioskColors.green : KioskColors.line,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            const Text(
              '시작 시간',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
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
          ? KioskColors.green
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
              color: selected ? KioskColors.green : KioskColors.line,
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
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                slot.enabled ? '${slot.remaining}자리 남음' : '예약 마감',
                style: TextStyle(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.78)
                      : KioskColors.subtle,
                  fontSize: 12,
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
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
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const TextSpan(
                              text: ' 명',
                              style: TextStyle(
                                color: KioskColors.ink,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        _DurationOption(
          minutes: 60,
          price: 10000,
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
          price: 15000,
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
              color: selected ? KioskColors.green : KioskColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? KioskColors.green : KioskColors.subtle,
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
                            fontWeight: FontWeight.w900,
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
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
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
                  fontWeight: FontWeight.w900,
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
        const Text('예약 안내 문자를 받을 휴대폰 번호입니다.'),
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
            color: phone.length == 11 ? KioskColors.green : KioskColors.line,
            width: 2,
          ),
        ),
        child: Text(
          phone.isEmpty ? '010 -          -' : formatted,
          style: TextStyle(
            color: phone.isEmpty ? KioskColors.subtle : KioskColors.ink,
            fontSize: 30,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w800,
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
                          fontWeight: FontWeight.w800,
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
                const _SummaryRow(
                  icon: Icons.storefront_rounded,
                  label: '매장',
                  value: 'GIGI Sports 미추홀점',
                ),
                const Divider(height: 30),
                _SummaryRow(
                  icon: Icons.calendar_month_rounded,
                  label: '예약 일시',
                  value: '9월 ${date.day}일 (${date.weekday})  ${draft.time}',
                ),
                const Divider(height: 30),
                _SummaryRow(
                  icon: Icons.groups_rounded,
                  label: '이용 인원',
                  value: '${draft.players}명 · ${draft.duration}분',
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
                  fontWeight: FontWeight.w900,
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
                  fontWeight: FontWeight.w800,
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

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({
    required this.draft,
    required this.onDone,
    super.key,
  });

  final ReservationDraft draft;
  final VoidCallback onDone;

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
                      color: KioskColors.green,
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
                    '예약 안내 문자를 보내드렸습니다.',
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
                        const Text(
                          'GIGI-0901-024',
                          style: TextStyle(
                            color: KioskColors.greenDark,
                            fontSize: 31,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Divider(height: 34),
                        Text(
                          '9월 ${BookingFlowScreenStateAccess.dateDay(draft.dateIndex)}일  ${draft.time}  ·  ${draft.players}명',
                          style: const TextStyle(
                            color: KioskColors.ink,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'GIGI Sports 미추홀점',
                          style: TextStyle(
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

abstract final class BookingFlowScreenStateAccess {
  static int dateDay(int index) => index + 1;
}

class LookupScreen extends StatefulWidget {
  const LookupScreen({required this.onExit, super.key});

  final VoidCallback onExit;

  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  String phone = '';
  bool searched = false;

  void _press(String value) {
    setState(() {
      searched = false;
      if (value == 'back') {
        if (phone.isNotEmpty) phone = phone.substring(0, phone.length - 1);
      } else if (phone.length < 11) {
        phone += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        KioskHeader(onHome: widget.onExit),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
            children: [
              Text(
                '예약을 확인할게요',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('예약할 때 입력한 휴대폰 번호를 눌러주세요.'),
              const SizedBox(height: 24),
              PhoneDisplay(phone: phone),
              const SizedBox(height: 18),
              NumberPad(onPressed: _press),
              if (searched) ...[
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: KioskColors.greenSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: KioskColors.greenDark,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '현재 예약 내역이 없습니다. 번호를 다시 확인해 주세요.',
                          style: TextStyle(
                            color: KioskColors.greenDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: KioskColors.line)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 138,
                child: OutlinedButton(
                  onPressed: widget.onExit,
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FilledButton.icon(
                  onPressed: phone.length == 11
                      ? () => setState(() => searched = true)
                      : null,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('예약 찾기'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class KioskHeader extends StatelessWidget {
  const KioskHeader({this.onHome, this.showHome = true, super.key});

  final VoidCallback? onHome;
  final bool showHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: KioskColors.line)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/brand/gigi_green.png',
            width: 136,
            height: 52,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'GIGI SPORTS',
              style: TextStyle(
                color: KioskColors.greenDark,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Spacer(),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '미추홀점',
                style: TextStyle(
                  color: KioskColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '2026. 9. 1. 화요일',
                style: TextStyle(color: KioskColors.muted, fontSize: 13),
              ),
            ],
          ),
          if (showHome) ...[
            const SizedBox(width: 14),
            IconButton.outlined(
              tooltip: '첫 화면',
              onPressed: onHome,
              icon: const Icon(Icons.home_outlined, size: 27),
              style: IconButton.styleFrom(minimumSize: const Size(54, 54)),
            ),
          ],
        ],
      ),
    );
  }
}

class HelpFooter extends StatelessWidget {
  const HelpFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 15, 28, 17),
      decoration: const BoxDecoration(
        color: KioskColors.black,
        border: Border(top: BorderSide(color: Color(0xFF2A2820))),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '도움이 필요하신가요?',
                  style: TextStyle(
                    color: Color(0xFFB9B6A8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '직원을 불러주세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: null,
            style: ButtonStyle(
              minimumSize: const WidgetStatePropertyAll(Size(126, 56)),
              backgroundColor: WidgetStatePropertyAll(
                KioskColors.green.withValues(alpha: 0.95),
              ),
              foregroundColor: const WidgetStatePropertyAll(Colors.white),
            ),
            child: const Text('직원 호출'),
          ),
        ],
      ),
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
