import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kGold = Color(0xFFFFD700);
const _kRed  = Color(0xFFCC0000);
const _kNavy = Color(0xFF002868);

TextStyle _mono({double size = 12, Color color = _kGold, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

/// 通用選舉夜 Overlay（2016 / 2024 共用）
class ElectionNightOverlay extends StatefulWidget {
  final int year;
  final int trumpTarget;    // 川普最終票數
  final int opponentTarget; // 對手最終票數
  final String opponentName;
  final VoidCallback onComplete;

  const ElectionNightOverlay({
    super.key,
    required this.year,
    required this.trumpTarget,
    required this.opponentTarget,
    required this.opponentName,
    required this.onComplete,
  });

  @override
  State<ElectionNightOverlay> createState() => _ElectionNightOverlayState();
}

class _ElectionNightOverlayState extends State<ElectionNightOverlay>
    with SingleTickerProviderStateMixin {
  int _trumpVotes = 0;
  int _opponentVotes = 0;
  bool _finished = false;
  bool _showVictory = false;
  int _tick = 0;

  late final AnimationController _glowCtrl;
  Timer? _countTimer;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 800), _startCount);
  }

  void _startCount() {
    if (!mounted) return;
    _countTimer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (!mounted) { t.cancel(); return; }
      _tick++;
      final progress = (_tick / 60).clamp(0.0, 1.0);
      final eased = Curves.easeInCubic.transform(progress);
      setState(() {
        _trumpVotes    = (eased * widget.trumpTarget).round();
        _opponentVotes = (eased * widget.opponentTarget).round();
      });
      if (_tick >= 60) {
        t.cancel();
        setState(() {
          _trumpVotes    = widget.trumpTarget;
          _opponentVotes = widget.opponentTarget;
          _finished = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _showVictory = true);
        });
      }
    });
  }

  @override
  void dispose() {
    _countTimer?.cancel();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Text('📺  選舉夜  ${widget.year}.11',
                  style: _mono(size: 10, color: const Color(0xFF888888), weight: FontWeight.normal)),
              const SizedBox(height: 4),
              Text('ELECTION NIGHT', style: _mono(size: 20, color: _kGold)),
              const SizedBox(height: 20),
              _ScoreBoard(
                trumpVotes: _trumpVotes,
                opponentVotes: _opponentVotes,
                opponentName: widget.opponentName,
              ),
              const SizedBox(height: 16),
              _ElectoralBar(trumpVotes: _trumpVotes, opponentVotes: _opponentVotes),
              const SizedBox(height: 8),
              Text('需要 270 票勝選',
                  style: _mono(size: 9, color: const Color(0xFF666666), weight: FontWeight.normal)),
              const SizedBox(height: 24),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: _showVictory
                      ? _VictoryPanel(
                          glowCtrl: _glowCtrl,
                          year: widget.year,
                          trumpTarget: widget.trumpTarget,
                          opponentTarget: widget.opponentTarget,
                          onConfirm: widget.onComplete,
                        )
                      : _CountingPanel(finished: _finished),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  final int trumpVotes;
  final int opponentVotes;
  final String opponentName;
  const _ScoreBoard({required this.trumpVotes, required this.opponentVotes, required this.opponentName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(children: [
            Text('TRUMP', style: _mono(size: 13, color: _kRed)),
            const SizedBox(height: 4),
            Text('$trumpVotes', style: _mono(size: 48, color: _kRed)),
          ]),
        ),
        Column(children: [
          Text('VS', style: _mono(size: 10, color: const Color(0xFF555555))),
          const SizedBox(height: 4),
          const Text('🗳️', style: TextStyle(fontSize: 24)),
        ]),
        Expanded(
          child: Column(children: [
            Text(opponentName, style: _mono(size: 13, color: _kNavy)),
            const SizedBox(height: 4),
            Text('$opponentVotes', style: _mono(size: 48, color: _kNavy)),
          ]),
        ),
      ],
    );
  }
}

class _ElectoralBar extends StatelessWidget {
  final int trumpVotes;
  final int opponentVotes;
  const _ElectoralBar({required this.trumpVotes, required this.opponentVotes});

  @override
  Widget build(BuildContext context) {
    const total = 538;
    final tFrac = trumpVotes    / total;
    final oFrac = opponentVotes / total;
    final uFrac = (1.0 - tFrac - oFrac).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 18,
        child: Row(
          children: [
            Flexible(flex: (tFrac * 1000).round(), child: Container(color: _kRed)),
            Flexible(flex: (uFrac * 1000).round().clamp(1, 1000), child: Container(color: const Color(0xFF222222))),
            Flexible(flex: (oFrac * 1000).round(), child: Container(color: _kNavy)),
          ],
        ),
      ),
    );
  }
}

class _CountingPanel extends StatelessWidget {
  final bool finished;
  const _CountingPanel({required this.finished});
  @override
  Widget build(BuildContext context) => Center(
    key: const ValueKey('counting'),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: _kGold, strokeWidth: 2),
      const SizedBox(height: 12),
      Text(finished ? '計票完成...' : '計票進行中...',
          style: _mono(size: 11, color: const Color(0xFF888888), weight: FontWeight.normal)),
    ]),
  );
}

class _VictoryPanel extends StatelessWidget {
  final AnimationController glowCtrl;
  final int year;
  final int trumpTarget;
  final int opponentTarget;
  final VoidCallback onConfirm;
  const _VictoryPanel({
    required this.glowCtrl, required this.year,
    required this.trumpTarget, required this.opponentTarget, required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isSecondTerm = year == 2024;
    return Column(
      key: const ValueKey('victory'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: glowCtrl,
          builder: (_, __) => Text('🏆  WINNER  🏆',
              style: _mono(size: 22,
                  color: _kGold.withValues(alpha: 0.5 + glowCtrl.value * 0.5)),
              textAlign: TextAlign.center),
        ),
        const SizedBox(height: 8),
        Text('$trumpTarget vs $opponentTarget', style: _mono(size: 16, color: Colors.white)),
        const SizedBox(height: 6),
        Text(isSecondTerm ? '史上最偉大的勝利！' : '沒有人預料到這一刻！',
            style: _mono(size: 11, color: const Color(0xFFFFEEAA), weight: FontWeight.normal)),
        if (isSecondTerm) ...[
          const SizedBox(height: 4),
          Text('成為美國史上第二位非連續任期總統',
              style: _mono(size: 9, color: const Color(0xFF888888), weight: FontWeight.normal),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('🔓 隱藏結局解鎖：TWICE PRESIDENT',
              style: _mono(size: 10, color: _kGold), textAlign: TextAlign.center),
        ],
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onConfirm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: _kRed,
              border: Border.all(color: _kGold, width: 2),
            ),
            child: Text(
              isSecondTerm ? 'FOUR MORE YEARS! ▶' : 'MAKE AMERICA GREAT AGAIN! ▶',
              style: _mono(size: 10, color: _kGold),
            ),
          ),
        ),
      ],
    );
  }
}
