import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/character_state.dart';

/// 頂部狀態列（對應設計稿 "sb" 元件）
class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xD0FFFFFF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左：階段名稱 + 年齡
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                gs.stage.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                gs.stage.ageRange,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // 右：6 屬性小圖示
          Row(
            children: [
              _StatChip(emoji: '💰', value: gs.wealth, isLarge: true),
              const SizedBox(width: 6),
              _StatChip(emoji: '😤', value: gs.ego),
              const SizedBox(width: 6),
              _StatChip(emoji: '🗳️', value: gs.support),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final double value;
  final bool isLarge;

  const _StatChip({
    required this.emoji,
    required this.value,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final display = isLarge
        ? (value >= 1000000
            ? '\$${(value / 1000000).toStringAsFixed(1)}M'
            : value >= 1000
                ? '\$${(value / 1000).toStringAsFixed(0)}K'
                : '\$${value.toInt()}')
        : '${value.toInt()}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text(
            display,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部屬性詳細列（展開時顯示）
class StatsDetailRow extends StatelessWidget {
  const StatsDetailRow({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white.withValues(alpha: 0.95),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatBar(label: '🍟 HUNGER', value: gs.hunger, color: const Color(0xFFFF8833))),
              const SizedBox(width: 12),
              Expanded(child: _StatBar(label: '⚡ ENERGY', value: gs.energy, color: const Color(0xFFFFD700))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _StatBar(label: '😤 EGO', value: gs.ego, color: const Color(0xFFFF3366))),
              const SizedBox(width: 12),
              Expanded(child: _StatBar(label: '📺 FAME', value: gs.fame.clamp(0, 100000) / 1000, color: const Color(0xFF1DA1F2))),
            ],
          ),
          const SizedBox(height: 8),
          _StatBar(label: '🗳️ SUPPORT', value: gs.support, color: const Color(0xFF002868)),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final double value; // 0–100
  final Color color;

  const _StatBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
            Text('${value.toInt()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFE5E7EB),
            color: color,
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}
