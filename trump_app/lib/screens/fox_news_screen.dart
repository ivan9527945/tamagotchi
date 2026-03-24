import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/character_state.dart';

/// 📺 看 Fox News — ENERGY +30, EGO +15（危險！）
class FoxNewsScreen extends StatefulWidget {
  const FoxNewsScreen({super.key});

  @override
  State<FoxNewsScreen> createState() => _FoxNewsScreenState();
}

class _FoxNewsScreenState extends State<FoxNewsScreen> {
  bool _watching = false;
  bool _done = false;

  static const _headlines = [
    '🔴 BREAKING: The greatest president in history!',
    '📊 Economy BOOMING under his leadership!',
    '🇺🇸 America FIRST is working! Experts agree!',
    '🚀 Markets at ALL TIME HIGH!',
    '🏆 Trump leads polls by TREMENDOUS margin!',
  ];

  int _headlineIndex = 0;

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return Container(
      color: const Color(0xFF0A1628),
      child: Column(
        children: [
          _buildHeader(context),
          _buildScene(gs),
          const SizedBox(height: 8),
          _buildEffects(),
          _buildEgoWarning(gs),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: GestureDetector(
              onTap: _done ? null : _watch,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: _done ? Colors.grey.shade700 : const Color(0xFFCC0000),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _done ? null : const [
                    BoxShadow(color: Color(0x50CC0000), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    _done ? '📺 看完了！精力充沛！' : '📺 看福斯新聞',
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _watch() {
    setState(() { _watching = true; });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<GameState>().watchFoxNews();
        setState(() {
          _done = true;
          _watching = false;
          _headlineIndex = (_headlineIndex + 1) % _headlines.length;
        });
      }
    });
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
          const Text('福斯新聞！📺', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFFFE0E0), borderRadius: BorderRadius.circular(20)),
            child: const Text('ENERGY +30', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFCC0000))),
          ),
        ],
      ),
    );
  }

  Widget _buildScene(GameState gs) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          // 川普坐著
          Positioned(
            left: 20,
            bottom: 0,
            child: Image.asset(
              'assets/characters/${gs.stage.pngName}.png',
              height: 200,
              errorBuilder: (_, __, ___) => const Text('🧍', style: TextStyle(fontSize: 100, color: Colors.white)),
            ),
          ),
          // TV
          Positioned(
            right: 20,
            top: 30,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCC0000), width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      _watching ? '📡 LIVE' : '🦅 FOX NEWS',
                      key: ValueKey(_watching),
                      style: const TextStyle(color: Color(0xFFCC0000), fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _headlines[_headlineIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_watching) ...[
                    const SizedBox(height: 8),
                    const CircularProgressIndicator(color: Color(0xFFCC0000), strokeWidth: 2),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffects() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _EffectCard(label: '⚡ ENERGY', desc: '+30 精力回復', color: const Color(0xFF002868))),
          const SizedBox(width: 10),
          Expanded(child: _EffectCard(label: '😤 EGO', desc: '+15（危險！）', color: const Color(0xFF8B0000))),
        ],
      ),
    );
  }

  Widget _buildEgoWarning(GameState gs) {
    if (gs.ego < 75) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF330000),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Text('⚠️', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EGO 危險！', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800, fontSize: 12)),
                Text('EGO 過高將觸發衝動推文！', style: TextStyle(color: Color(0xFFAA6666), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EffectCard extends StatelessWidget {
  final String label;
  final String desc;
  final Color color;

  const _EffectCard({required this.label, required this.desc, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
        ],
      ),
    );
  }
}
