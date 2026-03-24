import 'package:flutter/material.dart';

/// 所有可能的角色動畫狀態（保留供 Rive State Machine 使用）
enum CharacterState {
  idle,
  happy,
  eating,
  sleeping,
  angry,
  sad,
  tweeting,
  fired,
  celebrating,
  crisis,
}

/// 遊戲成長階段 → 對應 .riv 檔案名稱
enum CharacterStage {
  babyDonald,       // 0–5 歲
  queensKid,        // 6–12 歲
  militaryCadet,    // 13–18 歲
  whartonBoy,       // 18–22 歲
  daddysApprentice, // 22–30 歲
  manhattanMogul,   // 30–45 歲
  casinoKing,       // 45–55 歲
  tvStar,           // 55–60 歲
  candidate,        // 60–70 歲
  thePresident,     // 70+ 歲
}

extension CharacterStageExt on CharacterStage {
  String get rivePath => 'assets/rive/$name.riv';
  String get fallbackPng => 'assets/characters/$pngName.png';
  /// 各階段角色場景圖（來自 Pencil 設計稿 image nodeId）
  String get stageImagePath => 'assets/stages/$pngName.png';

  String get pngName => switch (this) {
    CharacterStage.babyDonald       => 'baby_donald',
    CharacterStage.queensKid        => 'queens_kid',
    CharacterStage.militaryCadet    => 'military_cadet',
    CharacterStage.whartonBoy       => 'wharton_boy',
    CharacterStage.daddysApprentice => 'daddys_apprentice',
    CharacterStage.manhattanMogul   => 'manhattan_mogul',
    CharacterStage.casinoKing       => 'casino_king',
    CharacterStage.tvStar           => 'tv_star',
    CharacterStage.candidate        => 'candidate',
    CharacterStage.thePresident     => 'the_president',
  };

  String get displayName => switch (this) {
    CharacterStage.babyDonald       => '🍼 Baby Donald',
    CharacterStage.queensKid        => '👦 Queens Kid',
    CharacterStage.militaryCadet    => '🎖️ Military Cadet',
    CharacterStage.whartonBoy       => '🎓 Wharton Boy',
    CharacterStage.daddysApprentice => '💼 Daddy\'s Apprentice',
    CharacterStage.manhattanMogul   => '🏙️ Manhattan Mogul',
    CharacterStage.casinoKing       => '🎰 Casino King',
    CharacterStage.tvStar           => '📺 TV Star',
    CharacterStage.candidate        => '🇺🇸 Candidate',
    CharacterStage.thePresident     => '👑 THE PRESIDENT',
  };

  String get ageRange => switch (this) {
    CharacterStage.babyDonald       => '0 – 5 歲',
    CharacterStage.queensKid        => '6 – 12 歲',
    CharacterStage.militaryCadet    => '13 – 18 歲',
    CharacterStage.whartonBoy       => '18 – 22 歲',
    CharacterStage.daddysApprentice => '22 – 30 歲',
    CharacterStage.manhattanMogul   => '30 – 45 歲',
    CharacterStage.casinoKing       => '45 – 55 歲',
    CharacterStage.tvStar           => '55 – 60 歲',
    CharacterStage.candidate        => '60 – 70 歲',
    CharacterStage.thePresident     => '70+ 歲',
  };

  String get description => switch (this) {
    CharacterStage.babyDonald       => '搖搖擺擺學走路的小唐納',
    CharacterStage.queensKid        => '皇后區活蹦亂跳的頑皮少年',
    CharacterStage.militaryCadet    => '紐約軍校正步踏步的精實學員',
    CharacterStage.whartonBoy       => '華頓商學院埋頭苦讀的優等生',
    CharacterStage.daddysApprentice => '跟著老爸學做生意的傳承接班人',
    CharacterStage.manhattanMogul   => '曼哈頓叼雪茄的地產大亨',
    CharacterStage.casinoKing       => '大西洋城擲骰子的賭場之王',
    CharacterStage.tvStar           => '《誰是接班人》魅力無限的電視明星',
    CharacterStage.candidate        => '高舉旗幟震驚全美的選戰黑馬',
    CharacterStage.thePresident     => '自由世界最偉大的總統',
  };

  Color get bgColor => switch (this) {
    CharacterStage.babyDonald       => const Color(0xFFFFB3C1),
    CharacterStage.queensKid        => const Color(0xFF90D5FF),
    CharacterStage.militaryCadet    => const Color(0xFF6B7A5C),
    CharacterStage.whartonBoy       => const Color(0xFF8B6F3E),
    CharacterStage.daddysApprentice => const Color(0xFF4A6FA5),
    CharacterStage.manhattanMogul   => const Color(0xFF2C2C2C),
    CharacterStage.casinoKing       => const Color(0xFF8B1A1A),
    CharacterStage.tvStar           => const Color(0xFF1A1A3E),
    CharacterStage.candidate        => const Color(0xFF3C3B6E),
    CharacterStage.thePresident     => const Color(0xFF8B6914),
  };
}
