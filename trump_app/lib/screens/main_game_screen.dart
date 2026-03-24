import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/trump_character_widget.dart';
import '../character/character_state.dart';
import '../widgets/stats_bar.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/bottom_tab_bar.dart';
import 'feed_screen.dart';
import 'groom_screen.dart';
import 'tweet_screen.dart';
import 'events_screen.dart';
import 'tan_spray_screen.dart';
import 'fox_news_screen.dart';
import 'sleep_screen.dart';

/// 🏠 主遊戲畫面（對應設計稿 Main Game Screen）
class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  bool _statsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StatsBar(),
            Expanded(child: _buildHomeContent()),
            GestureDetector(
              onTap: () => setState(() => _statsExpanded = !_statsExpanded),
              child: Container(
                width: 100,
                height: 28,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _statsExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                      size: 14,
                      color: const Color(0xFF888888),
                    ),
                    const SizedBox(width: 4),
                    const Text('行動', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF888888))),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _statsExpanded ? const StatsDetailRow() : const SizedBox.shrink(),
            ),
            BottomGameTabBar(
              activeTab: GameTab.home,
              onTabChanged: (tab) {
                Widget screen = switch (tab) {
                  GameTab.feed => const FeedScreen(),
                  GameTab.groom => const GroomScreen(),
                  GameTab.tweet => const TweetScreen(),
                  GameTab.events => const EventsScreen(),
                  _ => const SizedBox.shrink(),
                };
                if (tab != GameTab.home) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<GameState>(),
                        child: Scaffold(body: SafeArea(child: screen)),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final gs = context.watch<GameState>();
    return Stack(
      children: [
        // ── 角色場景背景（Pencil 設計稿 image nodeId）──────────
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              gs.stage.stageImagePath,
              key: ValueKey(gs.stageIndex),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(
                color: gs.stage.bgColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        // 底部漸層遮罩（讓 UI 元件可讀）
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 0.75, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.60),
                ],
              ),
            ),
          ),
        ),
        // 角色腳下陰影
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 130,
              height: 24,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x50000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
        ),
        // 對話泡泡
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(child: const SpeechBubble()),
        ),
        // 角色
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: TrumpCharacterWidget(
                key: ValueKey(gs.stageIndex),
                stage: gs.stage,
                size: 260,
              ),
            ),
          ),
        ),
        // 成長解鎖提示
        if (gs.canAdvanceStage)
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: gs.advanceStage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x40FFD700), blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎉 成長解鎖！點擊升級 → ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    Text(gs.stage.displayName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        // 右側快捷行動
        Positioned(
          bottom: 10,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuickAction(
                emoji: '🟧',
                label: '噴色',
                onTap: () => _pushScreen(context, const TanSprayScreen()),
              ),
              const SizedBox(height: 8),
              _QuickAction(
                emoji: '📺',
                label: 'Fox',
                onTap: () => _pushScreen(context, const FoxNewsScreen()),
              ),
              const SizedBox(height: 8),
              _QuickAction(
                emoji: '💤',
                label: '睡覺',
                onTap: () => _pushScreen(context, const SleepScreen()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _pushScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<GameState>(),
          child: Scaffold(body: SafeArea(child: screen)),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF555555))),
          ],
        ),
      ),
    );
  }
}
