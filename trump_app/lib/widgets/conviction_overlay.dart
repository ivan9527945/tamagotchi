import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kGold = Color(0xFFFFD700);
const _kRed  = Color(0xFFCC0000);
const _kNavy = Color(0xFF002868);

TextStyle _mono({double size = 12, Color color = _kGold, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

/// ⚖️ 重罪定罪危機
/// EGO 持續被媒體攻擊消耗，玩家需不斷點擊「EGO BOOST」維持 EGO > 0
/// 同時 SUPPORT 計量顯示大眾反應
/// 撐過 10 秒 → 勝利（支持率上升，EGO危機解除）
/// EGO 歸零 → 失敗 → 遊戲重置回 0 歲
class ConvictionOverlay extends StatefulWidget {
  final void Function(bool survived) onComplete;
  const ConvictionOverlay({super.key, required this.onComplete});

  @override
  State<ConvictionOverlay> createState() => _ConvictionOverlayState();
}

class _ConvictionOverlayState extends State<ConvictionOverlay>
    with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 10;
  static const double _egoDecayPerSecond = 12.0; // 每秒 EGO 下降（10秒版加速）
  static const double _egoBoostPerTap = 8.0;    // 每次點擊 EGO 增加

  double _ego = 80.0;
  double _support = 45.0;  // 輿論計量（50以上算好）
  int _secondsLeft = _totalSeconds;
  bool _done = false;
  int _tapCount = 0;

  // 媒體攻擊字幕（循環播放）
  static const _headlines = [
    '📰 CNN: 「史上首位被定罪的前總統」',
    '📰 NYT: 「34 項重罪全部成立」',
    '📰 MSNBC: 「法院裁決對民主的重要性」',
    '📺 Fox News: 「這是政治迫害！」',
    '📱 Twitter: 「WITCH HUNT 趨勢升溫」',
    '📰 WaPo: 「史無前例的歷史時刻」',
  ];
  int _headlineIdx = 0;

  late final AnimationController _pulseCtrl;
  Timer? _gameTimer;
  Timer? _headlineTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _secondsLeft--;
        _ego = (_ego - _egoDecayPerSecond).clamp(0, 100);
        // 媒體攻擊也拉低 support
        _support = (_support - 0.8).clamp(0, 100);
      });
      if (_ego <= 0) {
        t.cancel();
        _headlineTimer?.cancel();
        _finish(false);
      } else if (_secondsLeft <= 0) {
        t.cancel();
        _headlineTimer?.cancel();
        _finish(true);
      }
    });

    _headlineTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (!mounted) return;
      setState(() => _headlineIdx = (_headlineIdx + 1) % _headlines.length);
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _headlineTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _egoBoost() {
    if (_done) return;
    setState(() {
      _ego = (_ego + _egoBoostPerTap).clamp(0, 100);
      _support = (_support + 0.5).clamp(0, 100); // 強硬反應也略拉 support
      _tapCount++;
    });
  }

  void _finish(bool survived) {
    if (_done) return;
    setState(() => _done = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) widget.onComplete(survived);
    });
  }

  Color get _egoColor {
    if (_ego > 50) return _kGold;
    if (_ego > 25) return const Color(0xFFFF8800);
    return _kRed;
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _ResultPanel(survived: _ego > 0);

    return Material(
      color: Colors.black.withValues(alpha: 0.94),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 頂部欄
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color: _kNavy,
                child: Row(children: [
                  Text('⚖️ 重罪定罪 2024', style: _mono(size: 10)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: _secondsLeft > 15 ? _kGold : _kRed),
                    ),
                    child: Text('${_secondsLeft}s',
                        style: _mono(size: 11, color: _secondsLeft > 15 ? _kGold : _kRed)),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // EGO 計量
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('😤 EGO', style: _mono(size: 10, color: _egoColor)),
                Text('${_ego.toInt()}%', style: _mono(size: 10, color: _egoColor)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _ego / 100,
                  minHeight: 14,
                  backgroundColor: const Color(0xFF222222),
                  valueColor: AlwaysStoppedAnimation(_egoColor),
                ),
              ),
              const SizedBox(height: 8),

              // SUPPORT 計量
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('🗳️ 輿論支持', style: _mono(size: 10, color: const Color(0xFF888888))),
                Text('${_support.toInt()}%',
                    style: _mono(size: 10,
                        color: _support >= 50 ? const Color(0xFF00FF88) : _kRed)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _support / 100,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF222222),
                  valueColor: AlwaysStoppedAnimation(
                      _support >= 50 ? const Color(0xFF00FF88) : _kRed),
                ),
              ),
              const SizedBox(height: 12),

              // 媒體攻擊跑馬燈
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_headlineIdx),
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: const Color(0xFF111111),
                  child: Text(_headlines[_headlineIdx],
                      textAlign: TextAlign.center,
                      style: _mono(size: 8, color: const Color(0xFFFF8888), weight: FontWeight.normal)),
                ),
              ),
              const SizedBox(height: 8),

              // 指示文字
              Text('點擊下方按鈕維持 EGO！',
                  style: _mono(size: 9, color: Colors.white38, weight: FontWeight.normal)),
              const SizedBox(height: 6),
              Text('已反擊 $_tapCount 次',
                  style: _mono(size: 9, color: Colors.white38, weight: FontWeight.normal)),

              const Spacer(),

              // EGO BOOST 大按鈕
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => GestureDetector(
                  onTap: _egoBoost,
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _kRed.withValues(alpha: 0.7 + _pulseCtrl.value * 0.2),
                      border: Border.all(color: _kGold, width: 2),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('😤 EGO BOOST!',
                          style: _mono(size: 18, color: _kGold)),
                      const SizedBox(height: 4),
                      Text('「這是政治迫害！WITCH HUNT!」',
                          style: _mono(size: 8, color: _kGold.withValues(alpha: 0.7),
                              weight: FontWeight.normal)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final bool survived;
  const _ResultPanel({required this.survived});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.94),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(survived ? '😤' : '💔', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(survived ? 'EGO 存活！' : 'EGO 崩潰！',
                style: _mono(size: 20, color: survived ? _kGold : _kRed),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              survived
                  ? '你頂住了媒體狂轟！\n「這是政治迫害！」你反覆強調——\n支持者信了。\nSUPPORT +10，EGO 回穩'
                  : 'EGO 完全崩潰……\n媒體的攻擊讓你喘不過氣。\nSUPPORT -20，EGO 清零',
              textAlign: TextAlign.center,
              style: _mono(size: 9, color: Colors.white70, weight: FontWeight.normal),
            ),
          ]),
        ),
      ),
    );
  }
}
