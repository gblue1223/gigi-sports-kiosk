import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/kiosk_chrome.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(
      {required this.onBooking, required this.onLookup, super.key});

  final VoidCallback onBooking;
  final VoidCallback onLookup;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      final inset = compact ? 24.0 : 32.0;
      return Column(
        children: [
          const KioskHeader(showHome: false),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(inset, 20, inset, 24),
              children: [
                _BrandHero(compact: compact),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('오늘의 라운드를 시작하세요',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontSize: compact ? 25 : 30)),
                          const SizedBox(height: 8),
                          const Text('이용하실 메뉴를 눌러주세요.',
                              style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 16),
                      const _QuickBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 22),
                _HomeActionCard(
                  key: const Key('new-booking-button'),
                  primary: true,
                  icon: Icons.calendar_month_outlined,
                  title: '새로 예약하기',
                  description: '날짜와 시간을 선택해 예약합니다',
                  onTap: onBooking,
                  compact: compact,
                ),
                const SizedBox(height: 14),
                _HomeActionCard(
                  key: const Key('lookup-button'),
                  icon: Icons.search_rounded,
                  title: '내 예약 확인',
                  description: '휴대폰 번호로 예약을 찾습니다',
                  onTap: onLookup,
                  compact: compact,
                ),
                const SizedBox(height: 24),
                const Text('예약 가능한 날짜와 시간은 예약 화면에서 확인해 주세요.'),
              ],
            ),
          ),
          const HelpFooter(),
        ],
      );
    });
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/brand/gigi_hero.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, 0.15),
              excludeFromSemantics: true,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF07180E).withValues(alpha: 0.12),
                    const Color(0xFF07180E).withValues(alpha: 0.34),
                    const Color(0xFF07180E).withValues(alpha: 0.96),
                  ],
                  stops: const [0, 0.35, 1],
                ),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(minHeight: compact ? 272 : 432),
            padding: EdgeInsets.all(compact ? 26 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11251B).withValues(alpha: 0.78),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text('GIGI SCREEN PARK GOLF',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2)),
                ),
                SizedBox(height: compact ? 40 : 174),
                Semantics(
                  header: true,
                  child: Text.rich(
                    TextSpan(children: const [
                      TextSpan(text: '가까운 일상,\n'),
                      TextSpan(
                          text: '새로운 라운드.',
                          style: TextStyle(color: KioskColors.mint)),
                    ]),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 36 : 44,
                        height: 1.18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.6),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('함께 즐기는 스크린 파크골프, GIGI SPORTS',
                    style: TextStyle(
                        color: Color(0xFFE4E9E3), fontSize: 17, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickBadge extends StatelessWidget {
  const _QuickBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
          color: KioskColors.greenSoft,
          borderRadius: BorderRadius.circular(30)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined,
              size: 19, color: KioskColors.greenDark),
          SizedBox(width: 5),
          Text('간편 예약',
              style: TextStyle(
                  color: KioskColors.greenDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard(
      {required this.icon,
      required this.title,
      required this.description,
      required this.onTap,
      required this.compact,
      this.primary = false,
      super.key});

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool compact;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final foreground = primary ? Colors.white : KioskColors.ink;
    final radius = BorderRadius.circular(24);
    return Semantics(
      button: true,
      label: '$title, $description',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
                color: primary
                    ? KioskColors.greenDark.withValues(alpha: 0.15)
                    : KioskColors.black.withValues(alpha: 0.03),
                blurRadius: 22,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Material(
          color: primary ? KioskColors.greenDark : Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                  color: primary ? Colors.transparent : KioskColors.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: compact ? 20 : 26, vertical: primary ? 28 : 24),
              child: Row(
                children: [
                  Container(
                    width: compact ? 54 : 68,
                    height: compact ? 54 : 68,
                    decoration: BoxDecoration(
                        color: primary
                            ? Colors.white.withValues(alpha: 0.12)
                            : KioskColors.greenSoft,
                        borderRadius: BorderRadius.circular(20)),
                    child: Icon(icon,
                        size: compact ? 29 : 34,
                        color:
                            primary ? KioskColors.mint : KioskColors.greenDark),
                  ),
                  SizedBox(width: compact ? 16 : 22),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                color: foreground,
                                fontSize: compact ? 27 : 31,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8)),
                        const SizedBox(height: 8),
                        Text(description,
                            style: TextStyle(
                                color: primary
                                    ? const Color(0xFFE0EFE5)
                                    : KioskColors.muted,
                                fontSize: compact ? 16 : 18,
                                height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded,
                      color: foreground, size: compact ? 26 : 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
