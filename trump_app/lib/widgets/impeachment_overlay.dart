import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kGold = Color(0xFFFFD700);
const _kRed  = Color(0xFFCC0000);
const _kNavy = Color(0xFF002868);

TextStyle _mono({double size = 12, Color color = _kGold, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

/// 🔨 第一次彈劾防禦小遊戲
/// 100 位參議員，需要 34 票阻止定罪（1/3 + 1）
/// 玩家快速點擊閃爍的「共和黨」參議員贏得支持
/// 計時 30 秒，時間到強制結算
class ImpeachmentOverlay extends StatefulWidget {
  final void Function(bool blocked) onComplete;
  const ImpeachmentOverlay({super.key, required this.onComplete});

  @override
  State<ImpeachmentOverlay> createState() => _ImpeachmentOverlayState();
}

class _ImpeachmentOverlayState extends State<ImpeachmentOverlay> {
  static const int _totalSeats = 60;     // 顯示 60 個按鈕，代表 100 席
  static const int _targetVotes = 20;    // 需要 20/60 = 約 1/3
  static const int _timeLimit = 30;

  final List<_SenatorState> _senators = List.generate(
    _totalSeats,
    (i) => _SenatorState(
      isRepublican: i < 47, // 前 47 是共和黨
      supportable: i < 47 && i >= 10, // 10–46 可拉攏（37個可點擊）
    ),
  );

  int _votes = 0;
  int _secondsLeft = _timeLimit;
  bool _done = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _finish();
      }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _tapSenator(int i) {
    if (_done || _senators[i].won || !_senators[i].supportable) return;
    setState(() {
      _senators[i].won = true;
      _votes++;
    });
    if (_votes >= _targetVotes) _finish();
  }

  void _finish() {
    if (_done) return;
    _timer?.cancel();
    setState(() => _done = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) widget.onComplete(_votes >= _targetVotes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _votes >= _targetVotes;
    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 標頭
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color: _kNavy,
                child: Row(children: [
                  Text('🔨 第一次彈劾  2019', style: _mono(size: 10)),
                  const Spacer(),
                  _TimerBadge(seconds: _secondsLeft),
                ]),
              ),
              const SizedBox(height: 8),
              // 進度
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('共和黨支持：$_votes / $_targetVotes 票',
                    style: _mono(size: 10, color: _votes >= _targetVotes
                        ? const Color(0xFF00FF88) : _kGold)),
                Text('需要阻止 67 票定罪',
                    style: _mono(size: 8, color: Colors.white54, weight: FontWeight.normal)),
              ]),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: _votes / _targetVotes,
                backgroundColor: const Color(0xFF222222),
                valueColor: AlwaysStoppedAnimation(_votes >= _targetVotes
                    ? const Color(0xFF00FF88) : _kGold),
              ),
              const SizedBox(height: 12),
              // 說明
              Text('點擊閃爍的共和黨參議員爭取支持！',
                  style: _mono(size: 9, color: Colors.white54, weight: FontWeight.normal)),
              const SizedBox(height: 8),
              // 參議員格子
              Expanded(
                child: _done
                    ? _ResultPanel(blocked: blocked, votes: _votes, target: _targetVotes)
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 10, crossAxisSpacing: 4, mainAxisSpacing: 4,
                        ),
                        itemCount: _totalSeats,
                        itemBuilder: (_, i) => _SenatorTile(
                          state: _senators[i],
                          onTap: () => _tapSenator(i),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SenatorTile extends StatefulWidget {
  final _SenatorState state;
  final VoidCallback onTap;
  const _SenatorTile({super.key, required this.state, required this.onTap});

  @override
  State<_SenatorTile> createState() => _SenatorTileState();
}

class _SenatorTileState extends State<_SenatorTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    if (widget.state.supportable && !widget.state.won) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.state.won) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF00FF88).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Center(child: Text('✓', style: TextStyle(fontSize: 10, color: Color(0xFF00FF88)))),
      );
    }
    if (!widget.state.isRepublican) {
      return Container(
        decoration: BoxDecoration(
          color: _kNavy.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Center(child: Text('D', style: TextStyle(fontSize: 9, color: Colors.white30))),
      );
    }
    if (!widget.state.supportable) {
      return Container(
        decoration: BoxDecoration(
          color: _kRed.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Center(child: Text('R', style: TextStyle(fontSize: 9, color: Colors.white30))),
      );
    }
    // 可點擊共和黨席位：閃爍
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _kRed.withValues(alpha: 0.3 + _ctrl.value * 0.5),
            border: Border.all(color: _kGold.withValues(alpha: _ctrl.value), width: 1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Text('R', style: TextStyle(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.6 + _ctrl.value * 0.4),
                fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final bool blocked;
  final int votes;
  final int target;
  const _ResultPanel({required this.blocked, required this.votes, required this.target});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(blocked ? '🛡️ 彈劾阻擋！' : '💔 定罪失敗阻擋',
            style: _mono(size: 24, color: blocked ? const Color(0xFF00FF88) : _kRed),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('獲得 $votes / $target 票',
            style: _mono(size: 14, color: Colors.white)),
        const SizedBox(height: 8),
        Text(blocked
            ? '共和黨忠誠！你無罪釋放！\nSUPPORT 大幅提升！'
            : '票數不足……\n但參議院最終還是無罪裁決。',
            textAlign: TextAlign.center,
            style: _mono(size: 9, color: Colors.white70, weight: FontWeight.normal)),
      ]),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final int seconds;
  const _TimerBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final color = seconds > 10 ? _kGold : _kRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Text('${seconds}s', style: _mono(size: 11, color: color)),
    );
  }
}

class _SenatorState {
  final bool isRepublican;
  final bool supportable;
  bool won = false;
  _SenatorState({required this.isRepublican, required this.supportable});
}
