import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/character_state.dart';

// ── 設計稿色系 ─────────────────────────────────────────────
const _kGold = Color(0xFFFFD700);
const _kRed  = Color(0xFFCC0000);
const _kNavy = Color(0xFF002868);
const _kBg   = Color(0xFF0A0A0A);

TextStyle _mono({double size = 10, Color color = _kGold, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

/// 頂部像素風格狀態列（對應設計稿 Main Screen 上方區塊）
class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return Container(
      color: _kBg,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 階段名稱列 ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gs.stage.pixelName.toUpperCase(),
                style: _mono(size: 11, color: _kGold),
              ),
              Text(
                gs.stage.ageRange.toUpperCase(),
                style: _mono(size: 9, color: const Color(0xFF888888)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ── 6 條像素屬性 ────────────────────────────────────
          _PixelStatRow(label: '💰 WEALTH', value: gs.wealth / 10000, color: _kGold, displayText: _formatWealth(gs.wealth)),
          const SizedBox(height: 3),
          _PixelStatRow(label: '📺 FAME',   value: (gs.fame / 100000).clamp(0.0, 1.0), color: const Color(0xFF1DA1F2)),
          const SizedBox(height: 3),
          _PixelStatRow(label: '😤 EGO',    value: gs.ego / 100,    color: _kRed),
          const SizedBox(height: 3),
          _PixelStatRow(label: '⚡ ENERGY', value: gs.energy / 100, color: _kGold),
          const SizedBox(height: 3),
          _PixelStatRow(label: '🍟 HUNGER', value: gs.hunger / 100, color: const Color(0xFFFF8833)),
          const SizedBox(height: 3),
          _PixelStatRow(label: '🗳️ SUPPORT',value: gs.support / 100, color: _kNavy),
        ],
      ),
    );
  }

  String _formatWealth(double w) {
    if (w >= 1000000) return '\$${(w / 1000000).toStringAsFixed(1)}M';
    if (w >= 1000)    return '\$${(w / 1000).toStringAsFixed(0)}K';
    return '\$${w.toInt()}';
  }
}

/// 單行像素屬性條 — 格式：LABEL ■■■■□□□□□□ VALUE
class _PixelStatRow extends StatelessWidget {
  final String label;
  final double value;   // 0.0 – 1.0
  final Color color;
  final String? displayText;
  static const _blocks = 10;

  const _PixelStatRow({
    required this.label,
    required this.value,
    required this.color,
    this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    final filled = (value.clamp(0.0, 1.0) * _blocks).round();
    final bar = List.generate(_blocks, (i) => i < filled ? '■' : '□').join();

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: _mono(size: 8, color: const Color(0xFF888888))),
        ),
        Text(bar, style: _mono(size: 9, color: color)),
        if (displayText != null) ...[
          const SizedBox(width: 6),
          Text(displayText!, style: _mono(size: 8, color: color)),
        ],
      ],
    );
  }
}

/// 底部詳細屬性列（現在已融入 StatsBar 本體，此 widget 保留供兼容）
class StatsDetailRow extends StatelessWidget {
  const StatsDetailRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // 已整合進 StatsBar
  }
}
