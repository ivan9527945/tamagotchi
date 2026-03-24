import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../character/character_state.dart';

const _kGold = Color(0xFFFFD700);
const _kRed  = Color(0xFFCC0000);
const _kNavy = Color(0xFF002868);

TextStyle _mono({double size = 12, Color color = _kGold, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

/// 成長階段關卡小遊戲 Overlay
/// 每個升級按鈕對應一個主題關卡；失敗 → resetGame()
class StageGateOverlay extends StatelessWidget {
  final CharacterStage targetStage; // 要升到的階段
  final VoidCallback onSuccess;     // 過關 → advanceStage()
  final VoidCallback onFail;        // 失敗 → resetGame()

  const StageGateOverlay({
    super.key,
    required this.targetStage,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  Widget build(BuildContext context) {
    return switch (targetStage) {
      CharacterStage.queensKid       => _CoinTapGame(onSuccess: onSuccess, onFail: onFail),
      CharacterStage.militaryCadet   => _DrillGame(onSuccess: onSuccess, onFail: onFail),
      CharacterStage.whartonBoy      => _WhartonExam(onSuccess: onSuccess, onFail: onFail),
      CharacterStage.daddysApprentice => _SliderDealGame(onSuccess: onSuccess, onFail: onFail, hard: false),
      CharacterStage.manhattanMogul  => _SliderDealGame(onSuccess: onSuccess, onFail: onFail, hard: true),
      CharacterStage.casinoKing      => _ConstructionTapGame(onSuccess: onSuccess, onFail: onFail),
      CharacterStage.tvStar          => _CasinoWheelGame(onSuccess: onSuccess, onFail: onFail),
      CharacterStage.candidate       => _YoureFireGame(onSuccess: onSuccess, onFail: onFail),
      _ => const SizedBox.shrink(),
    };
  }
}

// ─── 共用元件 ──────────────────────────────────────────────────

class _GateHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const _GateHeader({required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: _kNavy,
      child: Text('🔒 升級關卡', textAlign: TextAlign.center,
          style: _mono(size: 10, color: Colors.white, weight: FontWeight.normal)),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 6),
        Text(title, style: _mono(size: 14, color: _kGold), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(subtitle, style: _mono(size: 9, color: Colors.white54, weight: FontWeight.normal),
            textAlign: TextAlign.center),
      ]),
    ),
  ]);
}

Widget _resultBanner(bool success, String msg) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(12),
  color: success ? const Color(0xFF003300) : const Color(0xFF330000),
  child: Text(msg, textAlign: TextAlign.center,
      style: _mono(size: 11, color: success ? const Color(0xFF00FF88) : _kRed)),
);

// ─── 1. 撿錢！→ queensKid ──────────────────────────────────────
// 8 秒內點擊出現的金幣，需要 10 個

class _CoinTapGame extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFail;
  const _CoinTapGame({required this.onSuccess, required this.onFail});

  @override
  State<_CoinTapGame> createState() => _CoinTapGameState();
}

class _CoinTapGameState extends State<_CoinTapGame> {
  static const int _goal = 10;
  static const int _seconds = 30;
  final _random = Random();
  int _collected = 0;
  int _timeLeft = _seconds;
  bool _done = false;
  final List<_Coin> _coins = [];
  Timer? _spawnTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 900), (_) => _spawnCoin());
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) { t.cancel(); _finish(); }
    });
  }

  @override
  void dispose() { _spawnTimer?.cancel(); _countdownTimer?.cancel(); super.dispose(); }

  void _spawnCoin() {
    if (_done || !mounted) return;
    setState(() {
      _coins.add(_Coin(
        id: _random.nextInt(99999),
        x: 0.05 + _random.nextDouble() * 0.85,
        y: 0.1  + _random.nextDouble() * 0.7,
      ));
    });
  }

  void _tapCoin(int id) {
    if (_done) return;
    setState(() {
      _coins.removeWhere((c) => c.id == id);
      _collected++;
    });
    if (_collected >= _goal) _finish();
  }

  void _finish() {
    if (_done) return;
    _spawnTimer?.cancel();
    _countdownTimer?.cancel();
    final success = _collected >= _goal;
    setState(() => _done = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) success ? widget.onSuccess() : widget.onFail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(
        child: Column(children: [
          _GateHeader(emoji: '💰', title: '弗雷德的金錢課', subtitle: '30 秒內撿到 $_goal 枚金幣！'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('已撿：$_collected / $_goal', style: _mono(size: 11, color: _kGold)),
              Text('${_timeLeft}s', style: _mono(size: 11, color: _timeLeft <= 3 ? _kRed : _kGold)),
            ]),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _done
                ? Center(child: _resultBanner(_collected >= _goal,
                    _collected >= _goal ? '✓ 全部撿到！繼承家業！' : '✗ 太慢了！重頭來過！'))
                : LayoutBuilder(builder: (ctx, box) {
                    final w = box.maxWidth; final h = box.maxHeight;
                    return Stack(
                      children: _coins.map((c) => Positioned(
                        left: c.x * w - 22, top: c.y * h - 22,
                        child: GestureDetector(
                          onTap: () => _tapCoin(c.id),
                          child: const Text('💰', style: TextStyle(fontSize: 36)),
                        ),
                      )).toList(),
                    );
                  }),
          ),
        ]),
      ),
    );
  }
}

class _Coin { final int id; final double x, y; const _Coin({required this.id, required this.x, required this.y}); }

// ─── 2. 正步操練 → militaryCadet ────────────────────────────────
// 擺動條到達綠色中心區時點擊，3/5 次成功

class _DrillGame extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFail;
  const _DrillGame({required this.onSuccess, required this.onFail});

  @override
  State<_DrillGame> createState() => _DrillGameState();
}

class _DrillGameState extends State<_DrillGame> with SingleTickerProviderStateMixin {
  static const int _total = 5;
  static const int _needed = 3;
  late final AnimationController _barCtrl;
  int _round = 0, _hits = 0;
  bool _done = false;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _barCtrl.dispose(); super.dispose(); }

  void _tap() {
    if (_done || _round >= _total) return;
    final pos = _barCtrl.value; // 0–1; green zone: 0.4–0.6
    final hit = pos >= 0.4 && pos <= 0.6;
    setState(() {
      _round++;
      if (hit) { _hits++; _feedback = '✓ 完美！'; }
      else { _feedback = '✗ 不準！'; }
    });
    if (_round >= _total) _finish();
  }

  void _finish() {
    _barCtrl.stop();
    setState(() => _done = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _hits >= _needed ? widget.onSuccess() : widget.onFail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(child: Column(children: [
        _GateHeader(emoji: '🎖️', title: '軍事學院正步操練', subtitle: '條到綠色中心時點擊！需 $_needed/$_total 次精準'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$_round / $_total 次', style: _mono(size: 10)),
            Text('命中 $_hits', style: _mono(size: 10, color: const Color(0xFF00FF88))),
          ]),
        ),
        const SizedBox(height: 16),
        if (!_done) ...[
          // 擺動條
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedBuilder(
              animation: _barCtrl,
              builder: (_, __) {
                return Stack(alignment: Alignment.center, children: [
                  // 底部軌道
                  Container(height: 24, decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(4),
                  )),
                  // 綠色中心區
                  FractionallySizedBox(
                    widthFactor: 0.2,
                    child: Container(height: 24, color: const Color(0xFF00AA44).withValues(alpha: 0.4)),
                  ),
                  // 移動滑塊
                  Align(
                    alignment: Alignment(_barCtrl.value * 2 - 1, 0),
                    child: Container(width: 12, height: 24, color: _kGold),
                  ),
                ]);
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(_feedback, style: _mono(size: 13,
              color: _feedback.startsWith('✓') ? const Color(0xFF00FF88) : _kRed)),
          const Spacer(),
          GestureDetector(
            onTap: _tap,
            child: Container(
              width: double.infinity, height: 90,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kNavy, border: Border.all(color: _kGold, width: 2),
              ),
              child: Center(child: Text('報到！', style: _mono(size: 22, color: _kGold))),
            ),
          ),
        ] else
          Expanded(child: Center(child: _resultBanner(_hits >= _needed,
              _hits >= _needed ? '✓ 優等生！進入軍校！' : '✗ 不合格！重頭來過！'))),
      ])),
    );
  }
}

// ─── 3. 沃頓入學面試 → whartonBoy ──────────────────────────────
// 2 道商業問答，需全對

class _WhartonExam extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFail;
  const _WhartonExam({required this.onSuccess, required this.onFail});

  @override
  State<_WhartonExam> createState() => _WhartonExamState();
}

class _WhartonExamState extends State<_WhartonExam> {
  static const _questions = [
    _Q('什麼是「槓桿收購」的精髓？', ['借錢買，讓別人的錢為你工作', '先存夠錢再購買', '向朋友借錢', '等待最佳時機'], 0),
    _Q('選擇最川普風格的商業策略：', ['低調穩健，細水長流', '把名字貼滿每棟建築，BRAND = 一切', '專注產品品質', '建立長期信任關係'], 1),
  ];
  int _cur = 0, _correct = 0;
  int? _selected;
  bool _showResult = false, _done = false;

  void _pick(int i) {
    if (_selected != null) return;
    setState(() {
      _selected = i;
      _showResult = true;
      if (i == _questions[_cur].ans) _correct++;
    });
  }

  void _next() {
    if (_cur >= _questions.length - 1) {
      setState(() => _done = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _correct == _questions.length ? widget.onSuccess() : widget.onFail();
      });
    } else {
      setState(() { _cur++; _selected = null; _showResult = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return Material(color: Colors.black.withValues(alpha: 0.92),
      child: Center(child: _resultBanner(_correct == _questions.length,
          _correct == _questions.length ? '✓ 錄取！沃頓之子！' : '✗ 落榜！重頭來過！')));
    final q = _questions[_cur];
    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _GateHeader(emoji: '🎓', title: '沃頓入學面試', subtitle: '需全部答對才能入學'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('問題 ${_cur + 1} / ${_questions.length}',
                style: _mono(size: 9, color: Colors.white38, weight: FontWeight.normal)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: _kGold.withValues(alpha: 0.3))),
              child: Text(q.text, style: _mono(size: 11, color: Colors.white, weight: FontWeight.normal))),
            const SizedBox(height: 12),
            ...List.generate(q.options.length, (i) {
              Color bc = _kGold.withValues(alpha: 0.25);
              if (_showResult && _selected == i) bc = i == q.ans ? const Color(0xFF00FF88) : _kRed;
              else if (_showResult && i == q.ans) bc = const Color(0xFF00FF88);
              return GestureDetector(
                onTap: () => _pick(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(color: bc, width: 1.5)),
                  child: Text(q.options[i],
                      style: _mono(size: 9, color: Colors.white, weight: FontWeight.normal)),
                ),
              );
            }),
            if (_showResult) GestureDetector(
              onTap: _next,
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                color: _kRed, child: Text(_cur < _questions.length - 1 ? '下一題 ▶' : '查看結果 ▶',
                    textAlign: TextAlign.center, style: _mono(size: 11, color: _kGold)),
              ),
            ),
          ]),
        ),
      ])),
    );
  }
}
class _Q { final String text; final List<String> options; final int ans;
  const _Q(this.text, this.options, this.ans); }

// ─── 4 & 5. 談判滑塊 → daddysApprentice / manhattanMogul ────────
// 拖動滑塊停在利潤區，2/3 回合成功

class _SliderDealGame extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFail;
  final bool hard;
  const _SliderDealGame({required this.onSuccess, required this.onFail, required this.hard});

  @override
  State<_SliderDealGame> createState() => _SliderDealGameState();
}

class _SliderDealGameState extends State<_SliderDealGame> {
  final _random = Random();
  int _round = 0, _wins = 0;
  double _value = 0.5;
  double _zoneStart = 0.4, _zoneEnd = 0.6;
  bool _locked = false, _done = false;
  String _feedback = '';

  @override
  void initState() { super.initState(); _newZone(); }

  void _newZone() {
    final width = widget.hard ? 0.12 : 0.22;
    _zoneStart = 0.05 + _random.nextDouble() * (0.9 - width);
    _zoneEnd = _zoneStart + width;
    _value = 0.5;
    _locked = false;
    _feedback = '';
  }

  void _lock() {
    if (_locked || _done) return;
    final hit = _value >= _zoneStart && _value <= _zoneEnd;
    setState(() {
      _locked = true;
      _round++;
      if (hit) { _wins++; _feedback = '✓ 成交！DEAL!'; }
      else { _feedback = '✗ 破局！'; }
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_round >= 3) {
        setState(() => _done = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _wins >= 2 ? widget.onSuccess() : widget.onFail();
        });
      } else {
        setState(_newZone);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.hard ? '曼哈頓大交易' : '第一筆地產交易';
    final emoji = widget.hard ? '🏙️' : '💼';
    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(child: Column(children: [
        _GateHeader(emoji: emoji, title: title, subtitle: '拖動滑塊停在綠色區！需 2/3 成交'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('第 ${_round + 1} / 3 回合', style: _mono(size: 10)),
            Text('成交 $_wins', style: _mono(size: 10, color: const Color(0xFF00FF88))),
          ]),
        ),
        const Spacer(),
        if (!_done) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            // 滑塊軌道
            LayoutBuilder(builder: (_, box) {
              final w = box.maxWidth;
              return Stack(children: [
                Container(height: 32,
                  decoration: BoxDecoration(color: const Color(0xFF111111),
                      border: Border.all(color: Colors.white12))),
                Positioned(
                  left: _zoneStart * w, width: (_zoneEnd - _zoneStart) * w,
                  top: 0, bottom: 0,
                  child: Container(color: const Color(0xFF00AA44).withValues(alpha: 0.5)),
                ),
                Positioned(
                  left: (_value * (w - 20)).clamp(0, w - 20), top: 4, bottom: 4,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (d) {
                      if (_locked) return;
                      setState(() => _value = ((_value * w + d.delta.dx) / w).clamp(0.0, 1.0));
                    },
                    child: Container(width: 20,
                      decoration: BoxDecoration(color: _kGold, borderRadius: BorderRadius.circular(2))),
                  ),
                ),
              ]);
            }),
            const SizedBox(height: 16),
            Text(_feedback, style: _mono(size: 13,
                color: _feedback.startsWith('✓') ? const Color(0xFF00FF88) : _kRed)),
            const SizedBox(height: 24),
            if (!_locked) GestureDetector(
              onTap: _lock,
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: _kRed, border: Border.all(color: _kGold, width: 2)),
                child: Text('🤝 拍板！DEAL!', textAlign: TextAlign.center,
                    style: _mono(size: 14, color: _kGold)),
              ),
            ),
          ]),
        ),
        if (_done) _resultBanner(_wins >= 2, _wins >= 2 ? '✓ 天才交易者！' : '✗ 全部破局！重頭來過！'),
        const Spacer(),
      ])),
    );
  }
}

// ─── 6. 快速建設 → casinoKing ──────────────────────────────────
// 8 秒內點擊 25 次「建造！」

class _ConstructionTapGame extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFail;
  const _ConstructionTapGame({required this.onSuccess, required this.onFail});

  @override
  State<_ConstructionTapGame> createState() => _ConstructionTapGameState();
}

class _ConstructionTapGameState extends State<_ConstructionTapGame>
    with SingleTickerProviderStateMixin {
  static const int _goal = 25;
  static const int _seconds = 8;
  int _taps = 0, _timeLeft = _seconds;
  bool _done = false;
  late final AnimationController _bounce;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) { t.cancel(); _finish(); }
    });
  }

  @override
  void dispose() { _bounce.dispose(); _timer?.cancel(); super.dispose(); }

  void _tap() {
    if (_done) return;
    _bounce.forward(from: 0);
    setState(() => _taps++);
    if (_taps >= _goal) _finish();
  }

  void _finish() {
    if (_done) return;
    _timer?.cancel();
    setState(() => _done = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _taps >= _goal ? widget.onSuccess() : widget.onFail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_taps / _goal).clamp(0.0, 1.0);
    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(child: Column(children: [
        _GateHeader(emoji: '🔨', title: '川普大廈封頂', subtitle: '8 秒內瘋狂點擊 $_goal 次！'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$_taps / $_goal 次', style: _mono(size: 11, color: _kGold)),
            Text('${_timeLeft}s', style: _mono(size: 11, color: _timeLeft <= 3 ? _kRed : _kGold)),
          ]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LinearProgressIndicator(value: progress, minHeight: 10,
              backgroundColor: const Color(0xFF222222),
              valueColor: AlwaysStoppedAnimation(_kGold)),
        ),
        const Spacer(),
        if (!_done)
          AnimatedBuilder(
            animation: _bounce,
            builder: (_, __) => Transform.scale(
              scale: 1.0 - _bounce.value * 0.06,
              child: GestureDetector(
                onTap: _tap,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kRed,
                    border: Border.all(color: _kGold, width: 3),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('🏗️', style: TextStyle(fontSize: 40)),
                    Text('建造！', style: _mono(size: 14, color: _kGold)),
                  ]),
                ),
              ),
            ),
          )
        else
          _resultBanner(_taps >= _goal, _taps >= _goal ? '✓ 封頂！TRUMP TOWER 完工！' : '✗ 太慢了！重頭來過！'),
        const Spacer(),
      ])),
    );
  }
}

// ─── 7. 賭場輪盤 → tvStar ────────────────────────────────────────
// 旋轉輪盤停止後點擊，停在金色區算贏，3 輪 2 勝

class _CasinoWheelGame extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFail;
  const _CasinoWheelGame({required this.onSuccess, required this.onFail});

  @override
  State<_CasinoWheelGame> createState() => _CasinoWheelGameState();
}

class _CasinoWheelGameState extends State<_CasinoWheelGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  int _round = 0, _wins = 0;
  bool _spinning = false, _done = false;
  String _feedback = '';
  double _finalAngle = 0;

  static const _goldZones = [0.0, 0.25, 0.5, 0.75]; // 輪盤 4 個金色區（每 90°）
  static const _zoneWidth = 0.08; // 每個金色區寬度

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
  }

  @override
  void dispose() { _spinCtrl.dispose(); super.dispose(); }

  void _spin() {
    if (_spinning || _done) return;
    setState(() { _spinning = true; _feedback = ''; });
    final rotations = 3 + Random().nextDouble() * 3;
    _spinCtrl.animateTo(1.0, duration: const Duration(milliseconds: 2200),
        curve: Curves.easeOut).then((_) {
      if (!mounted) return;
      _finalAngle = (rotations % 1.0);
      final hit = _goldZones.any((z) {
        final diff = ((_finalAngle - z).abs());
        return diff < _zoneWidth || diff > (1 - _zoneWidth);
      });
      setState(() {
        _spinning = false;
        _round++;
        if (hit) { _wins++; _feedback = '✓ 大獎！'; }
        else { _feedback = '✗ 沒中！'; }
      });
      if (_round >= 3) {
        setState(() => _done = true);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _wins >= 2 ? widget.onSuccess() : widget.onFail();
        });
      } else {
        _spinCtrl.value = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(child: Column(children: [
        _GateHeader(emoji: '🎰', title: '泰姬瑪哈賭場試運營', subtitle: '停在金色區算贏！3 輪 2 勝'),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('第 ${_round + 1}/3 輪  贏 $_wins', style: _mono(size: 10)),
        ]),
        const Spacer(),
        if (!_done) ...[
          AnimatedBuilder(
            animation: _spinCtrl,
            builder: (_, __) {
              final angle = _spinCtrl.value * 2 * pi * 5;
              return Transform.rotate(
                angle: angle,
                child: SizedBox(
                  width: 180, height: 180,
                  child: CustomPaint(painter: _WheelPainter()),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(_feedback, style: _mono(size: 16,
              color: _feedback.startsWith('✓') ? const Color(0xFF00FF88) : _kRed)),
          const SizedBox(height: 16),
          if (!_spinning) GestureDetector(
            onTap: _spin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              decoration: BoxDecoration(color: _kRed, border: Border.all(color: _kGold, width: 2)),
              child: Text('🎰 轉！', style: _mono(size: 16, color: _kGold)),
            ),
          ),
        ] else
          _resultBanner(_wins >= 2, _wins >= 2 ? '✓ 賭場之王！泰姬瑪哈開業！' : '✗ 輸光了！重頭來過！'),
        const Spacer(),
      ])),
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectorAngle = 2 * pi / 8;
    for (int i = 0; i < 8; i++) {
      final paint = Paint()
        ..color = i % 2 == 0 ? const Color(0xFFFFD700) : const Color(0xFF222222)
        ..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          i * sectorAngle - pi / 2, sectorAngle, true, paint);
    }
    canvas.drawCircle(center, 12, Paint()..color = Colors.white);
    // 指針
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - radius - 8)
        ..lineTo(center.dx - 8, center.dy - radius + 8)
        ..lineTo(center.dx + 8, center.dy - radius + 8)
        ..close(),
      Paint()..color = _kRed,
    );
  }
  @override bool shouldRepaint(_) => true;
}

// ─── 8. You're Fired! → candidate ──────────────────────────────
// 10 秒內點掉 5 個亮起的員工

class _YoureFireGame extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFail;
  const _YoureFireGame({required this.onSuccess, required this.onFail});

  @override
  State<_YoureFireGame> createState() => _YoureFireGameState();
}

class _YoureFireGameState extends State<_YoureFireGame> {
  static const int _goal = 5;
  static const int _seconds = 10;
  static const int _slots = 9;
  final _random = Random();
  int _fired = 0, _timeLeft = _seconds;
  bool _done = false;
  final List<bool> _active = List.filled(_slots, false);
  Timer? _countdown;
  Timer? _spawn;

  @override
  void initState() {
    super.initState();
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) { t.cancel(); _finish(); }
    });
    _spawn = Timer.periodic(const Duration(milliseconds: 1200), (_) => _activateRandom());
  }

  @override
  void dispose() { _countdown?.cancel(); _spawn?.cancel(); super.dispose(); }

  void _activateRandom() {
    if (_done || !mounted) return;
    setState(() {
      final off = List.generate(_slots, (i) => i).where((i) => !_active[i]).toList();
      if (off.isEmpty) return;
      _active[off[_random.nextInt(off.length)]] = true;
    });
  }

  void _fire(int i) {
    if (!_active[i] || _done) return;
    setState(() {
      _active[i] = false;
      _fired++;
    });
    if (_fired >= _goal) _finish();
  }

  void _finish() {
    if (_done) return;
    _countdown?.cancel(); _spawn?.cancel();
    setState(() => _done = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fired >= _goal ? widget.onSuccess() : widget.onFail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(child: Column(children: [
        _GateHeader(emoji: '🔥', title: 'You\'re Fired!', subtitle: '10 秒內開除 $_goal 名員工！'),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text('已開除 $_fired / $_goal', style: _mono(size: 10, color: _kGold)),
          Text('${_timeLeft}s', style: _mono(size: 10, color: _timeLeft <= 3 ? _kRed : _kGold)),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: _done
              ? Center(child: _resultBanner(_fired >= _goal,
                  _fired >= _goal ? '✓ 天才老闆！You\'re ALL Fired!' : '✗ 太慢了！重頭來過！'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: _slots,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _fire(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _active[i] ? _kRed.withValues(alpha: 0.8) : const Color(0xFF1A1A1A),
                        border: Border.all(color: _active[i] ? _kGold : Colors.white12, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(_active[i] ? '👔' : '💀',
                            style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                ),
        ),
      ])),
    );
  }
}
