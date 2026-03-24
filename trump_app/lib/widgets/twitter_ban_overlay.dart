import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kGold = Color(0xFFFFD700);
const _kRed  = Color(0xFFCC0000);

TextStyle _mono({double size = 12, Color color = _kGold, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

/// 🚫 Twitter 封號危機
/// 60 秒倒數計時（代表 24 小時）
/// 玩家必須在時間到之前選擇「移往 Truth Social」
/// 若時間到前未選 → 強制封號，粉絲大量流失
class TwitterBanOverlay extends StatefulWidget {
  /// [movedToTruthSocial] true = 主動遷移，false = 被動封號
  final void Function(bool movedToTruthSocial) onComplete;
  const TwitterBanOverlay({super.key, required this.onComplete});

  @override
  State<TwitterBanOverlay> createState() => _TwitterBanOverlayState();
}

class _TwitterBanOverlayState extends State<TwitterBanOverlay>
    with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 60;
  int _secondsLeft = _totalSeconds;
  bool _chosen = false;
  bool _moved = false;

  late final AnimationController _shakeCtrl;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 80))
      ..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _triggerBan();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _moveToTruthSocial() {
    if (_chosen) return;
    _timer?.cancel();
    setState(() { _chosen = true; _moved = true; });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onComplete(true);
    });
  }

  void _triggerBan() {
    if (_chosen) return;
    setState(() { _chosen = true; _moved = false; });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onComplete(false);
    });
  }

  double get _progress => _secondsLeft / _totalSeconds;

  Color get _timerColor {
    if (_progress > 0.5) return _kGold;
    if (_progress > 0.2) return const Color(0xFFFF8800);
    return _kRed;
  }

  @override
  Widget build(BuildContext context) {
    if (_chosen) return _ResultPanel(moved: _moved);

    final urgent = _secondsLeft <= 15;

    return Material(
      color: Colors.black.withValues(alpha: 0.94),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Twitter 藍鳥 被划叉
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (_, __) => Transform.translate(
                  offset: urgent ? Offset(_shakeCtrl.value * 3, 0) : Offset.zero,
                  child: const Text('🚫', style: TextStyle(fontSize: 64)),
                ),
              ),
              const SizedBox(height: 12),
              Text('TWITTER 永久封號', style: _mono(size: 16, color: _kRed)),
              const SizedBox(height: 6),
              Text('2021 年 1 月 8 日',
                  style: _mono(size: 10, color: Colors.white54, weight: FontWeight.normal)),
              const SizedBox(height: 20),

              // 倒數計時器
              Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: 120, height: 120,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFF222222),
                    valueColor: AlwaysStoppedAnimation(_timerColor),
                  ),
                ),
                Column(children: [
                  Text('${_secondsLeft}s', style: _mono(size: 28, color: _timerColor)),
                  Text('剩餘時間', style: _mono(size: 8, color: Colors.white38, weight: FontWeight.normal)),
                ]),
              ]),
              const SizedBox(height: 20),

              // 情境說明
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: _kRed.withValues(alpha: 0.5)),
                  color: _kRed.withValues(alpha: 0.05),
                ),
                child: Text(
                  'Twitter 已封禁你的帳號\n（8800 萬粉絲），理由是\n「煽動暴力」。\n\n你有 24 小時決定是否\n移往 Truth Social。',
                  textAlign: TextAlign.center,
                  style: _mono(size: 9, color: Colors.white70, weight: FontWeight.normal),
                ),
              ),
              const SizedBox(height: 24),

              // 行動按鈕
              GestureDetector(
                onTap: _moveToTruthSocial,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B0000),
                    border: Border.all(color: _kGold, width: 2),
                  ),
                  child: Column(children: [
                    Text('移往 TRUTH SOCIAL ▶', style: _mono(size: 12, color: _kGold)),
                    const SizedBox(height: 4),
                    Text('粉絲部分流失，但保住發言權',
                        style: _mono(size: 8, color: _kGold.withValues(alpha: 0.6),
                            weight: FontWeight.normal)),
                  ]),
                ),
              ),
              if (urgent) ...[
                const SizedBox(height: 8),
                Text('⚠ 時間快到了！',
                    style: _mono(size: 10, color: _kRed),
                    textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final bool moved;
  const _ResultPanel({required this.moved});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.94),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(moved ? '✅' : '🔇', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(moved ? 'Truth Social 啟用！' : '永久沉默！',
                style: _mono(size: 18, color: moved ? const Color(0xFF00FF88) : _kRed),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              moved
                  ? '成功移往 Truth Social！\n粉絲只剩三分之一，\n但你仍然有發言台。\nFAME -30%，EGO -15'
                  : '被迫接受封號！\n發聲管道全失。\nFAME -50%，SUPPORT -20',
              textAlign: TextAlign.center,
              style: _mono(size: 9, color: Colors.white70, weight: FontWeight.normal),
            ),
          ]),
        ),
      ),
    );
  }
}
