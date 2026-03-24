import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'character_state.dart';
import 'trump_animated_fallback.dart';

/// 川普角色 Widget（Rive 0.14.x API）
///
/// - assets/rive/{stage}.riv 存在時：播放 Rive State Machine 動畫
/// - 不存在或載入失敗：使用 flutter_animate 各時期自動動畫
class TrumpCharacterWidget extends StatefulWidget {
  final CharacterStage stage;
  final double size;

  const TrumpCharacterWidget({
    super.key,
    required this.stage,
    this.size = 240,
  });

  @override
  State<TrumpCharacterWidget> createState() => _TrumpCharacterWidgetState();
}

class _TrumpCharacterWidgetState extends State<TrumpCharacterWidget> {
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _failed = false;

  static const _smName = 'TrumpMachine';

  @override
  void initState() {
    super.initState();
    _loadRive();
  }

  @override
  void didUpdateWidget(TrumpCharacterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage != widget.stage) {
      _disposeRive();
      _loadRive();
    }
  }

  Future<void> _loadRive() async {
    try {
      final file = await rive.File.asset(
        widget.stage.rivePath,
        riveFactory: rive.Factory.rive,
      );
      if (file == null || !mounted) return;

      final controller = rive.RiveWidgetController(
        file,
        stateMachineSelector: const rive.StateMachineNamed(_smName),
      );

      setState(() {
        _riveFile = file;
        _controller = controller;
        _failed = false;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _disposeRive() {
    _controller?.dispose();
    _riveFile?.dispose();
    _controller = null;
    _riveFile = null;
  }

  @override
  void dispose() {
    _disposeRive();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final controller = _controller;
    if (controller != null && !_failed) {
      return rive.RiveWidget(
        controller: controller,
        fit: rive.Fit.contain,
      );
    }
    // .riv 不存在或載入失敗 → 各時期自動動畫
    return TrumpAnimatedFallback(
      stage: widget.stage,
      size: widget.size,
    );
  }
}
