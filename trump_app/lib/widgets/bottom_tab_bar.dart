import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── 色系 ────────────────────────────────────────────────────
const _kGold    = Color(0xFFFFD700);
const _kSurface = Color(0xFF111111);
const _kBorder  = Color(0xFF333333);

enum GameTab { home, feed, groom, tweet, events }

/// 底部像素風格 Tab Bar（對應設計稿底部導覽列）
class BottomGameTabBar extends StatelessWidget {
  final GameTab activeTab;
  final ValueChanged<GameTab> onTabChanged;

  const BottomGameTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  static const _tabs = [
    (tab: GameTab.home,   emoji: '🏠', label: 'HOME'),
    (tab: GameTab.feed,   emoji: '🍔', label: 'FEED'),
    (tab: GameTab.groom,  emoji: '💇', label: 'HAIR'),
    (tab: GameTab.tweet,  emoji: '🐦', label: 'TWEET'),
    (tab: GameTab.events, emoji: '🗺️', label: 'JOURNEY'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
      ),
      child: Row(
        children: _tabs.map((t) => _PixelTab(
          emoji: t.emoji,
          label: t.label,
          active: activeTab == t.tab,
          onTap: () => onTabChanged(t.tab),
        )).toList(),
      ),
    );
  }
}

class _PixelTab extends StatelessWidget {
  final String emoji;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PixelTab({
    required this.emoji,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: active ? _kGold.withValues(alpha: 0.12) : Colors.transparent,
            border: Border(
              top: BorderSide(
                color: active ? _kGold : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: active ? 18 : 15)),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.spaceMono(
                  fontSize: 7,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? _kGold : const Color(0xFF555555),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
