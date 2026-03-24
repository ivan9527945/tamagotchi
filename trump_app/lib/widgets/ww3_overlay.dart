import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ymca_dance_widget.dart';

const _kGold = Color(0xFFFFD700);
const _kRed  = Color(0xFFCC0000);
const _kNavy = Color(0xFF002868);

TextStyle _mono({double size = 12, Color color = _kGold, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

/// 🌍💥 特殊結局事件：是否發起第三次世界大戰？
///
/// 顯示選擇畫面，玩家選擇「開戰」或「和平」。
/// 動畫素材稍後替換：
///   - 開戰動畫佔位：[_WarAnimation]（TODO: 替換為實際動畫）
///   - 和平動畫佔位：[_PeaceAnimation]（TODO: 替換為實際動畫）
class Ww3Overlay extends StatefulWidget {
  final VoidCallback onWar;
  final VoidCallback onPeace;
  const Ww3Overlay({super.key, required this.onWar, required this.onPeace});

  @override
  State<Ww3Overlay> createState() => _Ww3OverlayState();
}

class _Ww3OverlayState extends State<Ww3Overlay>
    with SingleTickerProviderStateMixin {
  _Choice? _choice;
  bool _animating = false;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _pick(_Choice choice) {
    if (_animating) return;
    setState(() { _choice = choice; _animating = true; });
    // 顯示動畫 2.5 秒後回調
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      choice == _Choice.war ? widget.onWar() : widget.onPeace();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_animating && _choice != null) {
      return _choice == _Choice.war
          ? const _WarAnimation()
          : const _PeaceAnimation();
    }

    return Material(
      color: Colors.black.withValues(alpha: 0.96),
      child: SafeArea(
        child: Column(
          children: [
            // ── 頂部警報欄 ──────────────────────────────
            AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, _) => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: _kRed.withValues(alpha: 0.6 + _glowCtrl.value * 0.4),
                child: Text('⚠  緊急決策  ⚠',
                    textAlign: TextAlign.center,
                    style: _mono(size: 11, color: Colors.white, weight: FontWeight.normal)),
              ),
            ),

            const Spacer(),

            // ── 主要問題 ────────────────────────────────
            const Text('🌍', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('總統先生，', style: _mono(size: 14, color: Colors.white70, weight: FontWeight.normal)),
            const SizedBox(height: 8),
            Text('是否發起', style: _mono(size: 20, color: Colors.white)),
            const SizedBox(height: 4),
            AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, _) => Text(
                '第三次世界大戰？',
                style: _mono(size: 22,
                    color: _kRed.withValues(alpha: 0.7 + _glowCtrl.value * 0.3)),
              ),
            ),

            const Spacer(),

            // ── 選項按鈕 ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // 開戰
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pick(_Choice.war),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _kRed.withValues(alpha: 0.85),
                          border: Border.all(color: _kGold, width: 2),
                        ),
                        child: Column(children: [
                          const Text('💥', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text('開戰！', style: _mono(size: 14, color: _kGold)),
                          const SizedBox(height: 4),
                          Text('FIRE AND FURY',
                              style: _mono(size: 8, color: _kGold.withValues(alpha: 0.6),
                                  weight: FontWeight.normal)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 和平
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pick(_Choice.peace),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _kNavy.withValues(alpha: 0.85),
                          border: Border.all(color: _kGold, width: 2),
                        ),
                        child: Column(children: [
                          const Text('🕊️', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text('和平！', style: _mono(size: 14, color: _kGold)),
                          const SizedBox(height: 4),
                          Text('ART OF THE DEAL',
                              style: _mono(size: 8, color: _kGold.withValues(alpha: 0.6),
                                  weight: FontWeight.normal)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

enum _Choice { war, peace }

// ── 開戰動畫 ────────────────────────────────────────────────────

class _WarAnimation extends StatelessWidget {
  const _WarAnimation();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💥', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text('FIRE AND FURY!',
                style: GoogleFonts.spaceMono(
                    fontSize: 20, color: const Color(0xFFCC0000),
                    fontWeight: FontWeight.w700, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text('世界大戰已開始',
                style: GoogleFonts.spaceMono(
                    fontSize: 12, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

// ── 和平動畫：YMCA 舞蹈 ──────────────────────────────────────────

class _PeaceAnimation extends StatelessWidget {
  const _PeaceAnimation();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text('ART OF THE DEAL  ✓',
                style: GoogleFonts.spaceMono(
                    fontSize: 13, color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text('和平協議達成！川普慶祝跳舞中…',
                style: GoogleFonts.spaceMono(
                    fontSize: 10, color: Colors.white54)),
            const SizedBox(height: 12),
            const Expanded(
              child: YmcaDanceWidget(loop: true, fps: 8),
            ),
            const SizedBox(height: 16),
            Text('🕊️  WORLD PEACE  🕊️',
                style: GoogleFonts.spaceMono(
                    fontSize: 14, color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
