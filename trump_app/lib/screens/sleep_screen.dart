import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/character_state.dart';

/// 💤 強制睡眠 — 克服抵抗值才能讓川普入睡
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  static const _maxResistance = 100.0;
  double _resistance = 100.0; // 抵抗值（點擊降低）
  double _sleepProgress = 0.0;
  bool _sleeping = false;
  bool _done = false;
  Timer? _sleepTimer;
  Timer? _resistTimer;

  void _pressDown() {
    if (_done || _sleeping) return;
    HapticFeedback.lightImpact();
    setState(() {
      _resistance = (_resistance - 15).clamp(0, _maxResistance);
    });
    if (_resistance <= 0) _startSleep();
  }

  void _startSleep() {
    setState(() { _sleeping = true; });
    _sleepTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _sleepProgress = (_sleepProgress + 0.05).clamp(0.0, 1.0);
      });
      if (_sleepProgress >= 1.0) {
        t.cancel();
        context.read<GameState>().forceSleep();
        setState(() { _done = true; _sleeping = false; });
      }
    });
    // 不睡覺時抵抗回升
    _resistTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (!mounted || _sleeping) { t.cancel(); return; }
      setState(() {
        _resistance = (_resistance + 5).clamp(0, _maxResistance);
      });
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _resistTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D2A),
      child: Column(
        children: [
          _buildHeader(context),
          _buildSleepScene(),
          const SizedBox(height: 16),
          _buildResistBar(),
          const SizedBox(height: 8),
          _buildSleepProgress(),
          _buildRecovery(),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: GestureDetector(
              onTap: _done ? null : _pressDown,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: _done ? Colors.grey.shade700 : const Color(0xFF6644EE),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _done ? null : const [
                    BoxShadow(color: Color(0x606644EE), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    _done
                        ? '😴 川普睡著了！'
                        : _sleeping
                            ? '💤 正在入睡...'
                            : _resistance > 50
                                ? '💤 點擊強制睡覺！（抵抗中）'
                                : '💤 再按幾下！快睡了！',
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
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
          const Text('睡覺時間！💤', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFEDE0FF), borderRadius: BorderRadius.circular(20)),
            child: const Text('全屬性回復', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6644EE))),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepScene() {
    final gs = context.watch<GameState>();
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/characters/${gs.stage.pngName}.png',
            height: 180,
            errorBuilder: (_, __, ___) => const Text('😴', style: TextStyle(fontSize: 80)),
          ),
          if (_sleeping || _done) ...[
            Positioned(
              right: 80, top: 30,
              child: Text('Z', style: TextStyle(color: const Color(0xFF8866FF), fontSize: 28, fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: const Color(0xFF8866FF).withValues(alpha: 0.5), blurRadius: 8)])),
            ),
            Positioned(
              right: 60, top: 10,
              child: Text('Z', style: TextStyle(color: const Color(0xFF6644DD), fontSize: 20, fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: const Color(0xFF6644DD).withValues(alpha: 0.5), blurRadius: 8)])),
            ),
            Positioned(
              right: 44, top: 0,
              child: Text('z', style: TextStyle(color: const Color(0xFF4422BB), fontSize: 14, fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: const Color(0xFF4422BB).withValues(alpha: 0.5), blurRadius: 6)])),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResistBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('抵抗值', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              Text('${_resistance.toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: LinearProgressIndicator(
              value: _resistance / _maxResistance,
              backgroundColor: const Color(0xFF2A1050),
              color: const Color(0xFF8866FF),
              minHeight: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('入睡進度', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              Text('${(_sleepProgress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: LinearProgressIndicator(
              value: _sleepProgress,
              backgroundColor: const Color(0xFF1A1050),
              color: const Color(0xFF4422BB),
              minHeight: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecovery() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Expanded(child: _RecoveryChip(emoji: '🍟', label: 'HUNGER', desc: '+10')),
          const SizedBox(width: 8),
          Expanded(child: _RecoveryChip(emoji: '⚡', label: 'ENERGY', desc: '+40')),
          const SizedBox(width: 8),
          Expanded(child: _RecoveryChip(emoji: '😤', label: 'EGO', desc: '−5')),
        ],
      ),
    );
  }
}

class _RecoveryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String desc;

  const _RecoveryChip({required this.emoji, required this.label, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1050),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w600)),
          Text(desc, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
