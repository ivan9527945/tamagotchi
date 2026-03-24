import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'character_state.dart';

/// 每個成長階段的自動循環動畫
class TrumpAnimatedFallback extends StatelessWidget {
  final CharacterStage stage;
  final double size;

  const TrumpAnimatedFallback({
    super.key,
    required this.stage,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      stage.fallbackPng,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    return SizedBox(
      width: size,
      height: size,
      child: _buildStageAnimation(img),
    );
  }

  Widget _buildStageAnimation(Widget img) {
    return switch (stage) {
      CharacterStage.babyDonald       => _babyDonald(img),
      CharacterStage.queensKid        => _queensKid(img),
      CharacterStage.militaryCadet    => _militaryCadet(img),
      CharacterStage.whartonBoy       => _whartonBoy(img),
      CharacterStage.daddysApprentice => _daddysApprentice(img),
      CharacterStage.manhattanMogul   => _manhattanMogul(img),
      CharacterStage.casinoKing       => _casinoKing(img),
      CharacterStage.tvStar           => _tvStar(img),
      CharacterStage.candidate        => _candidate(img),
      CharacterStage.thePresident     => _thePresident(img),
    };
  }

  // ── 🍼 Baby Donald (0–5歲)
  // 搖搖擺擺學走路，手腳亂揮
  Widget _babyDonald(Widget img) {
    return img
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -6, duration: 500.ms, curve: Curves.easeInOut)
        .scaleX(begin: 1.0, end: 1.04, duration: 500.ms)
        .then()
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.06,
          end: 0.06,
          duration: 700.ms,
          curve: Curves.easeInOut,
        );
  }

  // ── 👦 Queens Kid (6–12歲)
  // 活蹦亂跳，上下跳動
  Widget _queensKid(Widget img) {
    return img
        .animate(onPlay: (c) => c.repeat())
        .moveY(
          begin: 0,
          end: -22,
          duration: 300.ms,
          curve: Curves.easeOut,
        )
        .then()
        .moveY(
          begin: -22,
          end: 0,
          duration: 300.ms,
          curve: Curves.bounceOut,
        )
        .then()
        .moveY(begin: 0, end: 0, duration: 400.ms) // 停頓
        .scaleX(
          begin: 1.0,
          end: 0.92,
          duration: 300.ms,
          curve: Curves.easeOut,
        )
        .then()
        .scaleX(begin: 0.92, end: 1.0, duration: 300.ms);
  }

  // ── 🎖️ Military Cadet (13–18歲)
  // 正步踏步，整齊有力
  Widget _militaryCadet(Widget img) {
    return img
        .animate(onPlay: (c) => c.repeat())
        .moveY(
          begin: 0,
          end: -10,
          duration: 350.ms,
          curve: Curves.easeIn,
        )
        .then()
        .moveY(
          begin: -10,
          end: 0,
          duration: 200.ms,
          curve: Curves.easeIn,
        )
        .then()
        .moveY(begin: 0, end: -10, duration: 350.ms, curve: Curves.easeIn)
        .then()
        .moveY(begin: -10, end: 0, duration: 200.ms, curve: Curves.easeIn)
        .then()
        .moveY(begin: 0, end: 0, duration: 300.ms) // 稍作停頓（立正）
        .rotate(
          begin: 0,
          end: 0.03,
          duration: 350.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .rotate(begin: 0.03, end: -0.03, duration: 700.ms)
        .then()
        .rotate(begin: -0.03, end: 0, duration: 350.ms);
  }

  // ── 🎓 Wharton Boy (18–22歲)
  // 沉思讀書，輕輕前後晃動
  Widget _whartonBoy(Widget img) {
    return img
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.04,
          end: 0.02,
          duration: 1800.ms,
          curve: Curves.easeInOut,
        )
        .moveY(
          begin: 0,
          end: -4,
          duration: 1800.ms,
          curve: Curves.easeInOut,
        );
  }

  // ── 💼 Daddy's Apprentice (22–30歲)
  // 商談手勢，自信點頭
  Widget _daddysApprentice(Widget img) {
    return img
        .animate(onPlay: (c) => c.repeat())
        .moveY(begin: 0, end: -8, duration: 600.ms, curve: Curves.easeOut)
        .then()
        .moveY(begin: -8, end: 0, duration: 400.ms, curve: Curves.easeIn)
        .then()
        .moveY(begin: 0, end: -4, duration: 400.ms, curve: Curves.easeOut)
        .then()
        .moveY(begin: -4, end: 0, duration: 300.ms, curve: Curves.easeIn)
        .then()
        .moveY(begin: 0, end: 0, duration: 500.ms) // 停頓
        .rotate(
          begin: 0,
          end: 0.04,
          duration: 600.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .rotate(begin: 0.04, end: 0, duration: 600.ms);
  }

  // ── 🏙️ Manhattan Mogul (30–45歲)
  // 霸氣站姿，威風左右掃視
  Widget _manhattanMogul(Widget img) {
    return img
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.05,
          end: 0.05,
          duration: 2000.ms,
          curve: Curves.easeInOut,
        )
        .moveY(
          begin: 0,
          end: -5,
          duration: 2000.ms,
          curve: Curves.easeInOut,
        )
        .shimmer(
          color: const Color(0xFFFFD700),
          duration: 2000.ms,
        );
  }

  // ── 🎰 Casino King (45–55歲)
  // 甩骰子感，左右大幅晃動
  Widget _casinoKing(Widget img) {
    return img
        .animate(onPlay: (c) => c.repeat())
        .rotate(
          begin: -0.08,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        )
        .then()
        .rotate(
          begin: 0,
          end: 0.08,
          duration: 300.ms,
          curve: Curves.easeIn,
        )
        .then()
        .rotate(
          begin: 0.08,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        )
        .then()
        .rotate(begin: 0, end: 0, duration: 600.ms) // 停頓
        .moveY(
          begin: 0,
          end: -12,
          duration: 300.ms,
          curve: Curves.easeOut,
        )
        .then()
        .moveY(
          begin: -12,
          end: 0,
          duration: 400.ms,
          curve: Curves.bounceOut,
        );
  }

  // ── 📺 TV Star (55–60歲)
  // 面向鏡頭揮手，散發魅力
  Widget _tvStar(Widget img) {
    return img
        .animate(onPlay: (c) => c.repeat())
        .moveX(begin: 0, end: -10, duration: 400.ms, curve: Curves.easeInOut)
        .rotate(begin: 0, end: -0.06, duration: 400.ms)
        .then()
        .moveX(begin: -10, end: 10, duration: 500.ms, curve: Curves.easeInOut)
        .rotate(begin: -0.06, end: 0.06, duration: 500.ms)
        .then()
        .moveX(begin: 10, end: 0, duration: 400.ms, curve: Curves.easeInOut)
        .rotate(begin: 0.06, end: 0, duration: 400.ms)
        .then()
        .moveX(begin: 0, end: 0, duration: 400.ms) // 停頓
        .shimmer(
          color: Colors.white,
          duration: 800.ms,
        );
  }

  // ── 🇺🇸 Candidate (60–70歲)
  // 競選揮手拜票，大動作
  Widget _candidate(Widget img) {
    return img
        .animate(onPlay: (c) => c.repeat())
        .moveY(begin: 0, end: -18, duration: 250.ms, curve: Curves.easeOut)
        .rotate(begin: 0, end: 0.1, duration: 250.ms)
        .then()
        .moveY(begin: -18, end: 0, duration: 350.ms, curve: Curves.bounceOut)
        .rotate(begin: 0.1, end: 0, duration: 350.ms)
        .then()
        .moveY(begin: 0, end: -12, duration: 220.ms, curve: Curves.easeOut)
        .rotate(begin: 0, end: -0.08, duration: 220.ms)
        .then()
        .moveY(begin: -12, end: 0, duration: 300.ms, curve: Curves.bounceOut)
        .rotate(begin: -0.08, end: 0, duration: 300.ms)
        .then()
        .moveY(begin: 0, end: 0, duration: 500.ms) // 停頓
        .shimmer(
          color: const Color(0xFFB22234), // 美國紅
          duration: 500.ms,
        );
  }

  // ── 👑 THE PRESIDENT (70+歲)
  // 總統式莊重揮手，黃金光芒
  Widget _thePresident(Widget img) {
    return img
        .animate(onPlay: (c) => c.repeat())
        .moveY(begin: 0, end: -10, duration: 800.ms, curve: Curves.easeInOut)
        .rotate(begin: -0.04, end: 0.04, duration: 800.ms)
        .then()
        .moveY(begin: -10, end: 0, duration: 800.ms, curve: Curves.easeInOut)
        .rotate(begin: 0.04, end: -0.04, duration: 800.ms)
        .then()
        .moveY(begin: 0, end: 0, duration: 600.ms) // 停頓（莊重感）
        .shimmer(
          color: const Color(0xFFFFD700),
          duration: 1200.ms,
        )
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.04, 1.04),
          duration: 800.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.04, 1.04),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.easeInOut,
        );
  }
}
