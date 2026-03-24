import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kGold = Color(0xFFFFD700);
const _kRed  = Color(0xFFCC0000);

TextStyle _mono({double size = 12, Color color = _kGold, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

/// 🎯 暗殺未遂 小遊戲（2024）
/// 隨機位置出現紅色靶心（危險）和綠色安全區（DUCK! 閃躲）
/// 玩家必須在 2 秒內點擊安全區，連續成功 3 次即可通關
/// 任何失誤（點錯或超時）→ 挑戰失敗（仍然存活，但 SUPPORT 較低）
class AssassinationOverlay extends StatefulWidget {
  final void Function(bool dodged) onComplete;
  const AssassinationOverlay({super.key, required this.onComplete});

  @override
  State<AssassinationOverlay> createState() => _AssassinationOverlayState();
}

class _AssassinationOverlayState extends State<AssassinationOverlay>
    with TickerProviderStateMixin {
  static const int _totalRounds = 3;
  static const double _windowSeconds = 2.0;

  final _random = Random();
  int _round = 0;
  int _successCount = 0;
  bool _done = false;
  bool _roundActive = false;
  bool _hit = false;   // 玩家是否點到安全區
  bool _miss = false;  // 點到危險區或超時

  // 靶心（危險）和安全區位置（0–1 normalized）
  Offset _dangerPos = const Offset(0.5, 0.5);
  Offset _safePos   = const Offset(0.3, 0.7);

  late AnimationController _countdownCtrl;
  Timer? _roundTimer;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _countdownCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_windowSeconds * 1000).toInt()),
    );
    _startNextRound();
  }

  @override
  void dispose() {
    _countdownCtrl.dispose();
    _roundTimer?.cancel();
    _startTimer?.cancel();
    super.dispose();
  }

  void _startNextRound() {
    if (_round >= _totalRounds) {
      _finish(_successCount >= 2); // 3 輪中至少 2 輪成功
      return;
    }
    setState(() {
      _roundActive = false;
      _hit = false;
      _miss = false;
      _dangerPos = Offset(
        0.15 + _random.nextDouble() * 0.7,
        0.15 + _random.nextDouble() * 0.55,
      );
      // 安全區距危險區至少 0.25
      Offset safeCandidate;
      do {
        safeCandidate = Offset(
          0.1 + _random.nextDouble() * 0.8,
          0.2 + _random.nextDouble() * 0.6,
        );
      } while ((safeCandidate - _dangerPos).distance < 0.25);
      _safePos = safeCandidate;
    });

    // 800ms 後啟動本輪
    _startTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _roundActive = true);
      _countdownCtrl.forward(from: 0);
      _roundTimer = Timer(Duration(milliseconds: (_windowSeconds * 1000).toInt()), () {
        if (!mounted) return;
        if (!_hit) {
          // 超時 = 未閃躲
          setState(() { _miss = true; _roundActive = false; });
          _nextRound();
        }
      });
    });
  }

  void _tapSafe() {
    if (!_roundActive || _hit || _miss) return;
    _roundTimer?.cancel();
    setState(() {
      _hit = true;
      _roundActive = false;
      _successCount++;
    });
    _nextRound();
  }

  void _tapDanger() {
    if (!_roundActive || _hit || _miss) return;
    _roundTimer?.cancel();
    setState(() {
      _miss = true;
      _roundActive = false;
    });
    _nextRound();
  }

  void _nextRound() {
    _round++;
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _startNextRound();
    });
  }

  void _finish(bool dodged) {
    if (_done) return;
    setState(() => _done = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) widget.onComplete(dodged);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _ResultPanel(dodged: _successCount >= 2, success: _successCount);

    return Material(
      color: Colors.black.withValues(alpha: 0.94),
      child: SafeArea(
        child: Stack(
          children: [
            // ── 背景 + 頂部 UI ────────────────────────────
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: _kRed,
                  child: Row(children: [
                    Text('🎯 暗殺未遂 2024', style: _mono(size: 10)),
                    const Spacer(),
                    Text('成功 $_successCount / ${_round.clamp(0, _totalRounds)} 輪',
                        style: _mono(size: 9, color: Colors.white, weight: FontWeight.normal)),
                  ]),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      return Stack(
                        children: [
                          // 背景氛圍
                          Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.8,
                                colors: [Color(0xFF1A0000), Colors.black],
                              ),
                            ),
                          ),
                          // 說明文字
                          Positioned(
                            top: 16, left: 0, right: 0,
                            child: Text(
                              _roundActive
                                ? '⚠ 快！點擊綠色安全區！'
                                : (_hit ? '✓ 閃躲成功！' : (_miss ? '✗ 太慢了！' : '準備...')),
                              textAlign: TextAlign.center,
                              style: _mono(size: 12,
                                  color: _roundActive ? Colors.white
                                      : (_hit ? const Color(0xFF00FF88) : _kRed)),
                            ),
                          ),
                          // 危險靶心（點到失分）
                          if (_round < _totalRounds)
                            Positioned(
                              left: _dangerPos.dx * w - 35,
                              top: _dangerPos.dy * h - 35,
                              child: GestureDetector(
                                onTap: _tapDanger,
                                child: _Target(
                                  color: _kRed,
                                  label: '🎯',
                                  active: _roundActive,
                                ),
                              ),
                            ),
                          // 安全區（點到得分）
                          if (_round < _totalRounds)
                            Positioned(
                              left: _safePos.dx * w - 35,
                              top: _safePos.dy * h - 35,
                              child: GestureDetector(
                                onTap: _tapSafe,
                                child: _Target(
                                  color: const Color(0xFF00AA44),
                                  label: '🛡️',
                                  active: _roundActive,
                                ),
                              ),
                            ),
                          // 倒數進度條
                          if (_roundActive)
                            Positioned(
                              bottom: 16, left: 20, right: 20,
                              child: AnimatedBuilder(
                                animation: _countdownCtrl,
                                builder: (_, __) => LinearProgressIndicator(
                                  value: 1 - _countdownCtrl.value,
                                  backgroundColor: const Color(0xFF222222),
                                  valueColor: AlwaysStoppedAnimation(
                                    _countdownCtrl.value < 0.5 ? _kGold : _kRed),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Target extends StatefulWidget {
  final Color color;
  final String label;
  final bool active;
  const _Target({required this.color, required this.label, required this.active});

  @override
  State<_Target> createState() => _TargetState();
}

class _TargetState extends State<_Target> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox(width: 70, height: 70);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.25 + _ctrl.value * 0.25),
          border: Border.all(color: widget.color, width: 2 + _ctrl.value),
        ),
        child: Center(child: Text(widget.label, style: const TextStyle(fontSize: 28))),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final bool dodged;
  final int success;
  const _ResultPanel({required this.dodged, required this.success});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.94),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(dodged ? '🤜' : '😱', style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(dodged ? '閃躲成功！' : '被擊中了……',
              style: _mono(size: 20, color: dodged ? const Color(0xFF00FF88) : _kRed),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('成功 $success / 3 輪',
              style: _mono(size: 14, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            dodged
                ? '「他們沒辦法阻止我！\n我比子彈還快！」\nSUPPORT +15，EGO +20'
                : '受了點傷，但依然站立。\n「我沒有死！這讓我更強！」\nSUPPORT +5，EGO +10',
            textAlign: TextAlign.center,
            style: _mono(size: 9, color: Colors.white70, weight: FontWeight.normal),
          ),
        ]),
      ),
    );
  }
}
