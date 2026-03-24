import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/character_state.dart';
import '../character/trump_sprite_animation.dart';
import '../widgets/speech_bubble.dart';

// ── 設計稿色系（完全對應 trump_tamagotchi.pen）────────────────
const _kBg      = Color(0xFF0A0A0A);
const _kGold    = Color(0xFFFFD700);
const _kRed     = Color(0xFFCC0000);
const _kNavy    = Color(0xFF002868);
const _kBtnRed  = Color(0xFF660000);
const _kBtnNavy = Color(0xFF001844);

TextStyle _mono({double size = 10, Color color = _kGold, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

// ─────────────────────────────────────────────────────────────
/// 主遊戲畫面（對應設計稿 01 - MAIN SCREEN, ID: R5mX1）
// ─────────────────────────────────────────────────────────────
class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  bool _actionsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ① headerBar (h:60) — 紅底金框
            // _HeaderBar(),
            // ② stageBar (h:32) — 深藍，階段 + 年份
            _StageBar(gs: gs),
            // ③ 主區域：背景圖 + 疊加 stats / sprite / 按鈕
            Expanded(child: _MainArea(gs: gs, actionsExpanded: _actionsExpanded)),
            // ④ 收合把手 + 操作按鈕
            _CollapseHandle(
              expanded: _actionsExpanded,
              onToggle: () => setState(() => _actionsExpanded = !_actionsExpanded),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: _actionsExpanded ? _ActSection(gs: gs) : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ① headerBar
// ─────────────────────────────────────────────────────────────
class _HeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kRed,
        border: Border.all(color: _kGold, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('★ 最偉大的寵物 ★', style: _mono(size: 14, color: _kGold)),
          const SizedBox(height: 2),
          Text('讓你的電子雞再次偉大',
              style: _mono(size: 8, color: const Color(0xFFFFEEAA), weight: FontWeight.normal)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ② stageBar
// ─────────────────────────────────────────────────────────────
class _StageBar extends StatelessWidget {
  final GameState gs;
  const _StageBar({required this.gs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: _kNavy,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('▶ ${gs.stage.chineseName}', style: _mono(size: 9, color: Colors.white)),
          Text('年紀：${gs.stage.ageRange}',
              style: _mono(size: 9, color: _kGold, weight: FontWeight.normal)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ③ 主區域：背景圖疊加 stats / sprite
// ─────────────────────────────────────────────────────────────
class _MainArea extends StatelessWidget {
  final GameState gs;
  final bool actionsExpanded;
  const _MainArea({required this.gs, required this.actionsExpanded});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景圖（根據故事線切換）
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: SizedBox.expand(
              key: ValueKey(gs.stage.bgImagePath),
              child: Image.asset(
                gs.stage.bgImagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stack) =>
                    const ColoredBox(color: Color(0xFF001133)),
              ),
            ),
          ),
        ),
        // 半透明暗化遮罩
        Container(color: Colors.black.withValues(alpha: 0.35)),

        // 整體垂直佈局（stats → 中間空白 → sprite → 按鈕）
        Column(
          children: [
            // statsSection（半透明背景疊在頂部）
            _StatsSection(gs: gs),
            // 升級橫幅
            if (gs.canAdvanceStage)
              GestureDetector(
                onTap: gs.advanceStage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  color: _kGold,
                  child: Center(
                    child: Text('▲ 升級進化！點此長大 ▲', style: _mono(size: 13, color: Colors.black)),
                  ),
                ),
              ),
            // Sprite 角色 + 泡泡（泡泡緊貼角色上方，整體置中）
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: const SpeechBubble(),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: TrumpSpriteAnimation(
                      key: ValueKey(gs.stageIndex),
                      stage: gs.stage,
                      charState: gs.characterState,
                      size: 220,
                    ),
                  ),
                ],
              ),
            ),
            // 底部：階段名 + 心情
            Container(
              color: Colors.black.withValues(alpha: 0.55),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(gs.stage.pixelName, style: _mono(size: 9, color: _kGold)),
                  _MoodIndicator(gs: gs),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MoodIndicator extends StatelessWidget {
  final GameState gs;
  const _MoodIndicator({required this.gs});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = gs.ego >= 80
        ? ('◆', 'OVERLOAD', _kRed)
        : gs.ego >= 50
            ? ('●', '開心', const Color(0xFF00FF88))
            : gs.hunger <= 20
                ? ('▲', '飢餓', const Color(0xFFFF6600))
                : gs.energy <= 20
                    ? ('■', '疲憊', const Color(0xFF888888))
                    : ('●', '普通', const Color(0xFF00DDFF));
    return Text('$icon $label', style: _mono(size: 9, color: color, weight: FontWeight.normal));
  }
}

// ─────────────────────────────────────────────────────────────
// statsSection — 半透明疊在背景頂部
// ─────────────────────────────────────────────────────────────
class _StatsSection extends StatelessWidget {
  final GameState gs;
  const _StatsSection({required this.gs});

  String _blocks(double val, {double max = 100, int count = 10}) {
    final n = ((val / max) * count).round().clamp(0, count);
    return '■' * n + '□' * (count - n);
  }

  @override
  Widget build(BuildContext context) {
    final wealthDisplay = gs.wealth >= 1000000
        ? '\$${(gs.wealth / 1000000).toStringAsFixed(1)}M'
        : gs.wealth >= 1000
            ? '\$${(gs.wealth / 1000).toStringAsFixed(0)}K'
            : '\$${gs.wealth.toInt()}';
    final fameDisplay =
        gs.fame >= 1000 ? '${(gs.fame / 1000).toStringAsFixed(0)}K' : '${gs.fame.toInt()}';

    final stats = [
      ('財富', _blocks(gs.wealth, max: 10000), wealthDisplay, _kGold),
      ('名氣', _blocks(gs.fame, max: 100000), fameDisplay, const Color(0xFFFF88FF)),
      ('飢餓', _blocks(gs.hunger), '${gs.hunger.toInt()}%', const Color(0xFFFF6600)),
      ('自我', _blocks(gs.ego), '${gs.ego.toInt()}%', const Color(0xFFFFAA00)),
      ('精力', _blocks(gs.energy), '${gs.energy.toInt()}%', const Color(0xFF00DDFF)),
      ('支持', _blocks(gs.support), '${gs.support.toInt()}%', const Color(0xFFFF4444)),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F0F0F).withValues(alpha: 0.8),
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      child: Column(
        children: [
          for (int row = 0; row < 3; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  _StatCell(stats[row * 2].$1, stats[row * 2].$2, stats[row * 2].$3, stats[row * 2].$4),
                  const SizedBox(width: 8),
                  _StatCell(stats[row * 2 + 1].$1, stats[row * 2 + 1].$2, stats[row * 2 + 1].$3, stats[row * 2 + 1].$4),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String blocks;
  final String value;
  final Color color;
  const _StatCell(this.label, this.blocks, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: _mono(size: 13, color: const Color(0xFF888888), weight: FontWeight.normal)),
              Text(value, style: _mono(size: 13, color: color, weight: FontWeight.normal)),
            ],
          ),
          Text(blocks, style: _mono(size: 13, color: color, weight: FontWeight.normal)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 收合把手
// ─────────────────────────────────────────────────────────────
class _CollapseHandle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  const _CollapseHandle({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: double.infinity,
        height: 22,
        decoration: BoxDecoration(
          color: _kBg,
          border: Border(top: BorderSide(color: _kGold.withValues(alpha: 0.6), width: 1)),
        ),
        child: Center(
          child: AnimatedRotation(
            turns: expanded ? 0 : 0.5,
            duration: const Duration(milliseconds: 280),
            child: Icon(Icons.keyboard_arrow_down, color: _kGold, size: 16),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// actSec — 2排×3按鈕（直接呼叫 GameState，不跳頁）
// ─────────────────────────────────────────────────────────────
class _ActSection extends StatelessWidget {
  final GameState gs;
  const _ActSection({required this.gs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      color: _kBg.withValues(alpha: 0.85),
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: Column(
        children: [
          // 排1：餵食 / 關稅 / 睡覺
          Expanded(
            child: Row(
              children: [
                _ActBtn(label: '餵食', bgColor: _kBtnRed, onTap: () => gs.feed('BigMac')),
                const SizedBox(width: 6),
                _ActBtn(label: '關稅', bgColor: _kGold.withValues(alpha: 0.85), textColor: Colors.black, onTap: () => gs.imposeTariff()),
                const SizedBox(width: 6),
                _ActBtn(label: '睡覺', bgColor: _kBtnNavy, onTap: () => gs.forceSleep()),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // 排2：發推 / 高爾夫球 / 談判
          Expanded(
            child: Row(
              children: [
                _ActBtn(label: '發推', bgColor: _kBtnNavy, onTap: () => gs.postTweet('MAKE AMERICA GREAT AGAIN! TREMENDOUS! SAD!')),
                const SizedBox(width: 6),
                _ActBtn(label: '高爾夫球', bgColor: _kBtnRed, onTap: () => gs.playGolf()),
                const SizedBox(width: 6),
                _ActBtn(label: '談判', bgColor: _kBtnNavy, onTap: () => gs.negotiate()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActBtn extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;
  const _ActBtn({required this.label, required this.bgColor, required this.onTap, this.textColor = _kGold});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: _kGold, width: 1.5),
          ),
          child: Center(
            child: Text(label, style: _mono(size: 9, color: textColor), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
