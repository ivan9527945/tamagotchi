import 'package:flutter/material.dart';

/// YMCA 舞蹈動畫 Widget
///
/// 循環播放 12 幀海湖莊園宴會廳像素風格動畫。
/// [loop]    : 是否無限循環（預設 true）
/// [fps]     : 每秒幾幀（預設 8）
/// [onDone]  : 非循環模式播完後的回調
class YmcaDanceWidget extends StatefulWidget {
  final bool loop;
  final int fps;
  final VoidCallback? onDone;

  const YmcaDanceWidget({
    super.key,
    this.loop = true,
    this.fps = 8,
    this.onDone,
  });

  @override
  State<YmcaDanceWidget> createState() => _YmcaDanceWidgetState();
}

class _YmcaDanceWidgetState extends State<YmcaDanceWidget> {
  static const _frames = [
    'assets/dance/dance_01.png',
    'assets/dance/dance_02.png',
    'assets/dance/dance_03.png',
    'assets/dance/dance_04.png',
    'assets/dance/dance_05.png',
    'assets/dance/dance_06.png',
    'assets/dance/dance_07.png',
    'assets/dance/dance_08.png',
    'assets/dance/dance_09.png',
    'assets/dance/dance_10.png',
    'assets/dance/dance_11.png',
    'assets/dance/dance_12.png',
  ];

  int _frameIndex = 0;
  late final Duration _frameDuration;

  @override
  void initState() {
    super.initState();
    _frameDuration = Duration(milliseconds: (1000 / widget.fps).round());
    _scheduleNext();
  }

  void _scheduleNext() {
    Future.delayed(_frameDuration, () {
      if (!mounted) return;
      final next = _frameIndex + 1;
      if (next >= _frames.length) {
        if (widget.loop) {
          setState(() => _frameIndex = 0);
          _scheduleNext();
        } else {
          widget.onDone?.call();
        }
      } else {
        setState(() => _frameIndex = next);
        _scheduleNext();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _frames[_frameIndex],
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none, // 保持像素風格鋸齒邊
    );
  }
}
