import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/character_state.dart';

/// 🟧 噴古銅色 — 點擊噴霧罐，tap 次數決定 EGO 加成
class TanSprayScreen extends StatefulWidget {
  const TanSprayScreen({super.key});

  @override
  State<TanSprayScreen> createState() => _TanSprayScreenState();
}

class _TanSprayScreenState extends State<TanSprayScreen>
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  static const _maxTaps = 20;
  bool _done = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _shakeAnim = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _spray() {
    if (_done) return;
    HapticFeedback.lightImpact();
    _shakeCtrl.forward(from: 0);
    setState(() {
      _tapCount++;
      if (_tapCount >= _maxTaps) _done = true;
    });
    if (_done) {
      context.read<GameState>().sprayTan(_tapCount);
    }
  }

  double get _progress => _tapCount / _maxTaps;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF5E8),
      child: Column(
        children: [
          _buildHeader(context),
          _buildCharArea(),
          const SizedBox(height: 20),
          // 噴霧 + 計數
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 噴霧罐
                GestureDetector(
                  onTap: _spray,
                  child: AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(_shakeAnim.value, 0),
                      child: child,
                    ),
                    child: Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE85000),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE85000).withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🟧', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 8),
                          Text(
                            'SPRAY',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // 計數顯示
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_tapCount',
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE85000),
                        ),
                      ),
                      Text(
                        '/ $_maxTaps 次',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: const Color(0xFFFFDDCC),
                          color: const Color(0xFFE85000),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _done ? '✅ 完美橙色！EGO +${(_tapCount * 2).clamp(0, 20)}' : '點擊罐子噴色！',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _done ? const Color(0xFFE85000) : const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: GestureDetector(
              onTap: _done ? null : _spray,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: _done ? Colors.grey : const Color(0xFFE85000),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _done ? null : const [
                    BoxShadow(color: Color(0x50E85000), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    _done ? '🟧 完成！ORANGE AND PROUD!' : '🟧 幫川普噴！',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
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
          const Text('噴古銅色！🟧', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFFFE8D0), borderRadius: BorderRadius.circular(20)),
            child: const Text('EGO +10', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFE85000))),
          ),
        ],
      ),
    );
  }

  Widget _buildCharArea() {
    final gs = context.watch<GameState>();
    return SizedBox(
      height: 180,
      child: Center(
        child: Image.asset(
          'assets/characters/${gs.stage.pngName}.png',
          height: 160,
          errorBuilder: (_, __, ___) => const Text('🟧', style: TextStyle(fontSize: 80)),
        ),
      ),
    );
  }
}
