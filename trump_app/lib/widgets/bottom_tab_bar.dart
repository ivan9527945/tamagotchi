import 'package:flutter/material.dart';

enum GameTab { home, feed, groom, tweet, events }

class BottomGameTabBar extends StatelessWidget {
  final GameTab activeTab;
  final ValueChanged<GameTab> onTabChanged;

  const BottomGameTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  static const _tabs = [
    (tab: GameTab.home, emoji: '🏠', label: '首頁'),
    (tab: GameTab.feed, emoji: '🍔', label: '餵食'),
    (tab: GameTab.groom, emoji: '💇', label: '整髮'),
    (tab: GameTab.tweet, emoji: '🐦', label: '推文'),
    (tab: GameTab.events, emoji: '🗺️', label: '事件'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.93),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _tabs.map((t) => _TabItem(
            emoji: t.emoji,
            label: t.label,
            active: activeTab == t.tab,
            onTap: () => onTabChanged(t.tab),
          )).toList(),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.emoji,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFD700).withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: active ? 20 : 17)),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                color: active ? const Color(0xFFCC9900) : const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
