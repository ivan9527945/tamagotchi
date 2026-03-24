import 'dart:async';
import 'package:flutter/material.dart';
import 'character_state.dart';
import 'trump_animated_fallback.dart';

/// 角色動畫用的幀類型
/// - idle  → IDLE_A ↔ IDLE_B 交替循環（每 480ms）
/// - happy → HAPPY 幀
/// - action→ ACTION 幀（各階段專屬動作）
enum SpriteFrame { idleA, idleB, happy, action }

/// Sprite Sheet 動畫 Widget
///
/// 命名規則（對應從 Pencil 設計稿匯出的 PNG）：
///   assets/characters/{stage_name}_idle_a.png
///   assets/characters/{stage_name}_idle_b.png
///   assets/characters/{stage_name}_happy.png
///   assets/characters/{stage_name}_action.png
///
/// 若檔案不存在，自動 fallback 至 [TrumpAnimatedFallback]（flutter_animate 版本）
class TrumpSpriteAnimation extends StatefulWidget {
  final CharacterStage stage;
  final CharacterState charState;
  final double size;

  const TrumpSpriteAnimation({
    super.key,
    required this.stage,
    this.charState = CharacterState.idle,
    this.size = 240,
  });

  @override
  State<TrumpSpriteAnimation> createState() => _TrumpSpriteAnimationState();
}

class _TrumpSpriteAnimationState extends State<TrumpSpriteAnimation> {
  bool _isFrameA = true;
  Timer? _idleTimer;

  // ── 動畫速度設定 ────────────────────────────────────────────
  static const _idleInterval = Duration(milliseconds: 480); // IDLE_A↔B 切換速度
  static const _switchDuration = Duration(milliseconds: 120); // 幀切換淡入時間

  @override
  void initState() {
    super.initState();
    _startCycle();
  }

  @override
  void didUpdateWidget(TrumpSpriteAnimation old) {
    super.didUpdateWidget(old);
    // 階段或狀態改變時重啟動畫
    if (old.stage != widget.stage || old.charState != widget.charState) {
      _idleTimer?.cancel();
      _isFrameA = true;
      _startCycle();
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  /// 只有 idle 狀態才需要 A↔B 循環計時器
  void _startCycle() {
    if (widget.charState != CharacterState.idle) return;
    _idleTimer = Timer.periodic(_idleInterval, (_) {
      if (mounted) setState(() => _isFrameA = !_isFrameA);
    });
  }

  /// 根據 CharacterState 決定要顯示哪個幀的 PNG 路徑
  String get _assetPath {
    final base = 'assets/characters/${widget.stage.pngName}';
    return switch (widget.charState) {
      // ── IDLE：A/B 交替 ────────────────────────────────────
      CharacterState.idle         => _isFrameA ? '${base}_idle_a.png' : '${base}_idle_b.png',
      // ── HAPPY 幀 ──────────────────────────────────────────
      CharacterState.happy        => '${base}_happy.png',
      CharacterState.celebrating  => '${base}_happy.png',
      // ── ACTION 幀（各階段專屬）────────────────────────────
      CharacterState.eating       => '${base}_action.png',
      CharacterState.tweeting     => '${base}_action.png',
      CharacterState.fired        => '${base}_action.png',
      CharacterState.sleeping     => '${base}_idle_a.png', // 睡眠用原始站姿（加外層遮罩）
      CharacterState.angry        => '${base}_action.png',
      CharacterState.sad          => '${base}_idle_b.png',
      CharacterState.crisis       => '${base}_action.png',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedSwitcher(
        duration: _switchDuration,
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _SpriteImage(
          key: ValueKey(_assetPath),
          path: _assetPath,
          fallback: TrumpAnimatedFallback(stage: widget.stage, size: widget.size),
          size: widget.size,
        ),
      ),
    );
  }
}

/// 單幀圖片，附 fallback 機制
class _SpriteImage extends StatelessWidget {
  final String path;
  final Widget fallback;
  final double size;

  const _SpriteImage({super.key, required this.path, required this.fallback, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        // 嘗試 fallback 至無 suffix 版本（原始單張 PNG）
        final basePath = path.replaceAll(RegExp(r'_(idle_[ab]|happy|action)\.png$'), '.png');
        if (basePath != path) {
          return Image.asset(
            basePath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => fallback,
          );
        }
        return fallback;
      },
    );
  }
}
