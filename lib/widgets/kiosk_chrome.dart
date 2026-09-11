import 'package:flutter/material.dart';

import '../theme.dart';

class KioskHeader extends StatelessWidget {
  const KioskHeader({this.onHome, this.showHome = true, super.key});

  final VoidCallback? onHome;
  final bool showHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      decoration: const BoxDecoration(
        color: KioskColors.cream,
        border: Border(bottom: BorderSide(color: KioskColors.line)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/brand/gigi_green.png',
            width: 54,
            height: 54,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: 12),
          Semantics(
            label: 'GIGI SPORTS',
            excludeSemantics: true,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GIGI',
                    style: TextStyle(
                        color: KioskColors.forest,
                        fontSize: 29,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2)),
                SizedBox(height: 5),
                Text('SPORTS',
                    style: TextStyle(
                        color: KioskColors.greenDark,
                        fontSize: 10,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4)),
              ],
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('미추홀점',
                    style: TextStyle(
                        color: KioskColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('스크린 파크골프',
                    style: TextStyle(color: KioskColors.muted, fontSize: 13)),
              ],
            ),
          ),
          if (showHome) ...[
            const SizedBox(width: 18),
            IconButton.outlined(
              tooltip: '첫 화면',
              onPressed: onHome,
              icon: const Icon(Icons.home_outlined, size: 26),
              style: IconButton.styleFrom(
                minimumSize: const Size(54, 54),
                foregroundColor: KioskColors.greenDark,
                side: const BorderSide(color: KioskColors.line),
                backgroundColor: Colors.white,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: const BoxDecoration(
        color: KioskColors.forest,
        border: Border(top: BorderSide(color: Color(0xFF284638))),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.support_agent_rounded,
                color: KioskColors.mint, size: 27),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('도움이 필요하신가요?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('가까운 카운터에 문의해 주세요',
                    style: TextStyle(color: Color(0xFFBDCFC3), fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('안내',
              style: TextStyle(
                  color: KioskColors.mint,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
