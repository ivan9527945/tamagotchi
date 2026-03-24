import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/character_state.dart';

/// 💇 整髮小遊戲 — 節奏點擊三個髮區，失敗 EGO -20
class GroomScreen extends StatefulWidget {
  const GroomScreen({super.key});

  @override
  State<GroomScreen> createState() => _GroomScreenState();
}

class _GroomScreenState extends State<GroomScreen> {
  static const _totalBeats = 20;
  static const _beatIntervalMs = 800;

  int _completedBeats = 0;
  int _activeZone = -1; // 0/1/2 or -1
  bool _started = false;
  bool _failed = false;
  bool _finished = false;
  Timer? _beatTimer;
  Timer? _zoneTimer;

  void _start() {
    setState(() { _started = true; _completedBeats = 0; _failed = false; _finished = false; });
    _nextBeat();
  }

  void _nextBeat() {
    if (_completedBeats >= _totalBeats) {
      _finish(success: true);
      return;
    }
    final zone = _completedBeats % 3;
    setState(() => _activeZone = zone);
    _zoneTimer = Timer(const Duration(milliseconds: _beatIntervalMs), () {
      if (mounted && _activeZone == zone) {
        // 玩家沒點 → 失敗
        _finish(success: false);
      }
    });
  }

  void _tapZone(int zone) {
    if (!_started || _failed || _finished) return;
    if (_activeZone == zone) {
      HapticFeedback.lightImpact();
      _zoneTimer?.cancel();
      setState(() {
        _completedBeats++;
        _activeZone = -1;
      });
      _beatTimer = Timer(const Duration(milliseconds: 200), _nextBeat);
    } else if (_activeZone != -1) {
      _finish(success: false);
    }
  }

  void _finish({required bool success}) {
    _zoneTimer?.cancel();
    _beatTimer?.cancel();
    setState(() {
      _failed = !success;
      _finished = true;
      _activeZone = -1;
    });
    if (success) {
      context.read<GameState>().groomSuccess();
    } else {
      context.read<GameState>().groomFail();
    }
  }

  @override
  void dispose() {
    _beatTimer?.cancel();
    _zoneTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF5FB),
      child: Column(
        children: [
          _buildHeader(context),
          _buildCharArea(),
          // 警告橫幅
          Container(
            width: double.infinity,
            color: const Color(0xFFFF3366),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: const Text(
              '⚠️ 失敗 = 自我 −20！繼續點擊！',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          // 點擊區域
          _buildTapZones(),
          const SizedBox(height: 16),
          // 進度條
          _buildBeatBar(),
          const Spacer(),
          // 按鈕
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _GroomButton(
              started: _started,
              finished: _finished,
              failed: _failed,
              onStart: _start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xD0FFFFFF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
              child: const Row(children: [
                Icon(Icons.arrow_back_ios, size: 14),
                Text('返回', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const Text('整髮時間！💇', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFFFE0F0), borderRadius: BorderRadius.circular(20)),
            child: Text(
              _finished ? (_failed ? 'FAILED!' : 'DONE!') : 'GROOMING',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFF3388)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharArea() {
    return SizedBox(
      height: 160,
      child: Center(
        child: context.watch<GameState>().stage.pngName != ''
            ? Image.asset('assets/characters/${context.read<GameState>().stage.pngName}.png', height: 140,
                errorBuilder: (_, __, ___) => const Text('💇', style: TextStyle(fontSize: 80)))
            : const Text('💇', style: TextStyle(fontSize: 80)),
      ),
    );
  }

  Widget _buildTapZones() {
    final zones = [
      (size: 90.0, color: const Color(0xFFFFD0E8), border: const Color(0xFFFF66AA)),
      (size: 110.0, color: const Color(0xFFFF66AA), border: const Color(0xFFFF3388)),
      (size: 90.0, color: const Color(0xFFFFD0E8), border: const Color(0xFFFF66AA)),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = _activeZone == i;
        return GestureDetector(
          onTap: () => _tapZone(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: zones[i].size + (active ? 10 : 0),
            height: zones[i].size + (active ? 10 : 0),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: active ? zones[i].border : zones[i].color,
              shape: BoxShape.circle,
              border: Border.all(color: zones[i].border, width: active ? 5 : 4),
              boxShadow: active
                  ? [BoxShadow(color: zones[i].border.withValues(alpha: 0.6), blurRadius: 20)]
                  : null,
            ),
            child: Center(
              child: Text(
                i == 0 ? '💛' : i == 1 ? '✂️' : '💛',
                style: TextStyle(fontSize: active ? 28 : 22),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBeatBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('進度', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              Text('$_completedBeats / $_totalBeats', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: LinearProgressIndicator(
              value: _completedBeats / _totalBeats,
              backgroundColor: const Color(0xFFFFD0E8),
              color: const Color(0xFFFF66AA),
              minHeight: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroomButton extends StatelessWidget {
  final bool started;
  final bool finished;
  final bool failed;
  final VoidCallback onStart;

  const _GroomButton({required this.started, required this.finished, required this.failed, required this.onStart});

  @override
  Widget build(BuildContext context) {
    String label;
    if (!started) label = '💇 開始整髮！';
    else if (finished && !failed) label = '✅ 完美！再來一次';
    else if (finished && failed) label = '💀 失敗了！再試一次';
    else label = '整髮中...';

    return GestureDetector(
      onTap: finished || !started ? onStart : null,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: failed ? const Color(0xFFFF3366) : const Color(0xFFFF66AA),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x50FF66AA), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
