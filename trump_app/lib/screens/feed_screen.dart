import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/character_state.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String? _lastFed;

  static const _foods = [
    (key: 'BigMac', emoji: '🍔', name: 'Big Mac', hungerUp: 25, energyUp: 10,
        color: Color(0xFFFFF0E0), border: Color(0xFFFF8833)),
    (key: 'DietCoke', emoji: '🥤', name: 'Diet Coke', hungerUp: 10, energyUp: 5,
        color: Color(0xFFF0F0FF), border: Color(0xFFCC0000)),
    (key: 'KFC', emoji: '🍗', name: 'KFC', hungerUp: 30, energyUp: 15,
        color: Color(0xFFFFF5E0), border: Color(0xFFCC3300)),
    (key: 'Pizza', emoji: '🍕', name: 'Pizza', hungerUp: 20, energyUp: 8,
        color: Color(0xFFFFF0F0), border: Color(0xFFFF4444)),
  ];

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return Container(
      color: const Color(0xFFFFF8F0),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          // 角色區
          _buildCharArea(gs),
          // 食物格
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.3,
                      children: _foods.map((f) => _FoodCard(
                        food: f,
                        selected: _lastFed == f.key,
                        onTap: () {
                          gs.feed(f.key);
                          setState(() => _lastFed = f.key);
                        },
                      )).toList(),
                    ),
                  ),
                  // 效果列
                  _buildEffectBar(gs),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // 餵食按鈕
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _FeedButton(
              onTap: _lastFed == null ? null : () {
                if (_lastFed != null) gs.feed(_lastFed!);
              },
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_ios, size: 14),
                  Text('返回', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const Text(
            '餵食時間！🍔',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('HUNGRY!', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFF8833))),
          ),
        ],
      ),
    );
  }

  Widget _buildCharArea(GameState gs) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Image.asset(
          'assets/characters/${gs.stage.pngName}.png',
          height: 160,
          errorBuilder: (_, __, ___) => const Text('🍔', style: TextStyle(fontSize: 80)),
        ),
      ),
    );
  }

  Widget _buildEffectBar(GameState gs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(child: _EffectChip(label: '🍟 飢餓', value: gs.hunger, color: const Color(0xFFFF8833))),
          const SizedBox(width: 10),
          Expanded(child: _EffectChip(label: '⚡ 精力', value: gs.energy, color: const Color(0xFFFFD700))),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final dynamic food;
  final bool selected;
  final VoidCallback onTap;

  const _FoodCard({required this.food, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: food.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? food.border : food.border.withValues(alpha: 0.5),
            width: selected ? 3 : 2,
          ),
          boxShadow: selected
              ? [BoxShadow(color: food.border.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(food.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(food.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Text(
              '+${food.hungerUp} HUNGER  +${food.energyUp} ENERGY',
              style: const TextStyle(fontSize: 9, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EffectChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _EffectChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white,
              color: color,
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _FeedButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey : const Color(0xFFFF8833),
          borderRadius: BorderRadius.circular(24),
          boxShadow: onTap == null ? null : [
            const BoxShadow(color: Color(0x40FF8833), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: const Center(
          child: Text(
            '🍔  餵川普！',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}
