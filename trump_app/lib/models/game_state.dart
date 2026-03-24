import 'dart:async';
import 'package:flutter/foundation.dart';
import '../character/character_state.dart';

/// 遊戲核心狀態 — 6 大屬性 + 成長階段管理
class GameState extends ChangeNotifier {
  // ── 6 大屬性 ────────────────────────────────────────────
  double _wealth = 500; // 💰 財富（無上限，可歸零）
  double _fame = 10; // 📺 知名度（0–100,000+）
  double _hunger = 60; // 🍟 飢餓（0–100，低→需餵食）
  double _ego = 40; // 😤 自我膨脹（0–100）
  double _energy = 70; // ⚡ 精力（0–100）
  double _support = 20; // 🗳️ 支持率（0–100）

  int _stageIndex = 0;
  int _bankruptcyCount = 0;
  late final Timer _tickTimer;
  int _tweetStormCount = 0; // 連推計數
  List<String> _unlockedBuildings = [];
  List<String> _completedEvents = [];
  String _currentSpeech = '我是最棒的！TREMENDOUS!';
  CharacterState _characterState = CharacterState.idle;
  String? _pendingEventKey; // UI 層待顯示的劇情事件
  bool _hiddenEndingUnlocked = false;
  CharacterStage? _pendingStageGate; // 待解鎖的階段關卡

  GameState() {
    // 每 10 秒自動 tick（被動衰減 + 建築收益）
    _tickTimer = Timer.periodic(const Duration(seconds: 10), (_) => dailyTick());
  }

  // ── Getters ─────────────────────────────────────────────
  double get wealth => _wealth;
  double get fame => _fame;
  double get hunger => _hunger;
  double get ego => _ego;
  double get energy => _energy;
  double get support => _support;

  int get stageIndex => _stageIndex;
  CharacterStage get stage => CharacterStage.values[_stageIndex];
  int get bankruptcyCount => _bankruptcyCount;
  List<String> get completedEvents => List.unmodifiable(_completedEvents);
  List<String> get unlockedBuildings => List.unmodifiable(_unlockedBuildings);
  String get currentSpeech => _currentSpeech;
  CharacterState get characterState => _characterState;
  String? get pendingEventKey => _pendingEventKey;
  bool get hiddenEndingUnlocked => _hiddenEndingUnlocked;
  CharacterStage? get pendingStageGate => _pendingStageGate;

  /// UI 層顯示完事件後呼叫，清除待辦事件
  void acknowledgeEvent() {
    _pendingEventKey = null;
    notifyListeners();
  }

  /// 玩家點擊升級按鈕 → 彈出對應關卡小遊戲
  /// candidate → thePresident 已由 election_2016 事件把關，直接升級
  void requestStageAdvance() {
    if (!canAdvanceStage) return;
    final next = CharacterStage.values[_stageIndex + 1];
    if (next == CharacterStage.thePresident) {
      advanceStage(); // election_2016 已在 canAdvanceStage 條件中
      return;
    }
    _pendingStageGate = next;
    notifyListeners();
  }

  /// 關卡小遊戲完成後呼叫
  void acknowledgeStageGate() {
    _pendingStageGate = null;
    notifyListeners();
  }

  /// 重置遊戲回 0 歲（任何小遊戲失敗觸發）
  void resetGame() {
    _wealth = 500;
    _fame = 10;
    _hunger = 60;
    _ego = 40;
    _energy = 70;
    _support = 20;
    _stageIndex = 0;
    _bankruptcyCount = 0;
    _tweetStormCount = 0;
    _unlockedBuildings.clear();
    _completedEvents.clear();
    _currentSpeech = '重新開始！我會更偉大！TREMENDOUS!';
    _characterState = CharacterState.idle;
    _pendingEventKey = null;
    _pendingStageGate = null;
    _hiddenEndingUnlocked = false;
    notifyListeners();
  }

  // 是否可進行交易（精力充足）
  bool get canDeal => _energy >= 20;

  // 是否達成各階段解鎖條件
  bool get canAdvanceStage {
    if (_stageIndex >= CharacterStage.values.length - 1) return false;
    return _meetsUnlockCondition(CharacterStage.values[_stageIndex + 1]);
  }

  // ── 屬性互動邏輯 ─────────────────────────────────────────
  /// EGO 過高時自動觸發推文（每次更新由 UI 層輪詢）
  bool get egoOverload => _ego >= 90;
  /// EGO 過低時抑鬱
  bool get egoDepressed => _ego <= 10;

  // ── 日常養護行動 ─────────────────────────────────────────

  /// 🍔 喂食（Big Mac / Diet Coke / KFC / 披薩）
  void feed(String foodName) {
    _hunger = (_hunger + 25).clamp(0, 100);
    _energy = (_energy + 10).clamp(0, 100);
    _setSpeech(_foodSpeech(foodName));
    _characterState = CharacterState.eating;
    _applyEgoFameInteraction();
    notifyListeners();
    _resetStateAfter(const Duration(seconds: 2));
  }

  /// 💇 整髮（節奏點擊小遊戲成功）
  void groomSuccess() {
    _ego = (_ego + 15).clamp(0, 100);
    _setSpeech('完美！我的頭髮無與倫比！');
    _characterState = CharacterState.happy;
    notifyListeners();
    _resetStateAfter(const Duration(seconds: 2));
  }

  /// 💇 整髮失敗
  void groomFail() {
    _ego = (_ego - 20).clamp(0, 100);
    _setSpeech('SAD! 今天頭髮很糟糕！');
    _characterState = CharacterState.angry;
    notifyListeners();
    _resetStateAfter(const Duration(seconds: 2));
  }

  /// 🟧 噴古銅色（點擊噴霧罐）
  void sprayTan(int tapCount) {
    final boost = (tapCount * 2.0).clamp(0, 10);
    _ego = (_ego + boost).clamp(0, 100);
    _setSpeech('完美的橙色！像金牌一樣！');
    _characterState = CharacterState.happy;
    notifyListeners();
    _resetStateAfter(const Duration(seconds: 2));
  }

  /// 🛃 徵收關稅
  void imposeTariff() {
    _wealth += 1000 + (_stageIndex * 500);
    _support = (_support + 3).clamp(0, 100);
    _ego = (_ego + 5).clamp(0, 100);
    _setSpeech('關稅！關稅！讓美國再次偉大！TREMENDOUS!');
    _characterState = CharacterState.celebrating;
    notifyListeners();
    _resetStateAfter(const Duration(seconds: 2));
  }

  /// 📺 看 Fox News
  void watchFoxNews() {
    _energy = (_energy + 30).clamp(0, 100);
    _ego = (_ego + 15).clamp(0, 100); // 危險！
    _wealth += 300; // 商業靈感
    _setSpeech('FAKE NEWS 無所不在！只有 Fox 說真話！');
    _characterState = CharacterState.celebrating;
    _applyEgoFameInteraction();
    notifyListeners();
    _resetStateAfter(const Duration(seconds: 2));
  }

  /// 💤 強制睡眠（抵抗值歸零後執行）
  void forceSleep() {
    _hunger = (_hunger + 10).clamp(0, 100);
    _energy = (_energy + 40).clamp(0, 100);
    _ego = (_ego - 5).clamp(0, 100); // 睡覺讓 EGO 稍降
    _setSpeech('我只睡 4 小時。精力充沛！');
    _characterState = CharacterState.sleeping;
    notifyListeners();
    _resetStateAfter(const Duration(seconds: 3));
  }

  // ── 社群媒體系統 ─────────────────────────────────────────

  /// 🐦 發推文，返回川普指數分數 (0–100)
  int postTweet(String text) {
    int score = _scoreTweet(text);
    double fameBoost = score * 50.0;

    _fame = _fame + fameBoost;
    _wealth += score * 20.0; // 品牌業配收益
    _ego = (_ego + score * 0.3).clamp(0, 100);
    _tweetStormCount++;

    if (_tweetStormCount >= 3) {
      // Twitter Storm！
      _fame += 5000;
      _support = (_support + 5).clamp(0, 100);
      _tweetStormCount = 0;
      _setSpeech('TWITTER STORM! 全美都在看我！');
    } else {
      _setSpeech('TREMENDOUS tweet! 粉絲們會瘋狂的！');
    }

    _characterState = CharacterState.tweeting;
    _applyEgoFameInteraction();
    notifyListeners();
    _resetStateAfter(const Duration(seconds: 2));
    return score;
  }

  // ── 交易系統 ─────────────────────────────────────────────

  /// 完成交易（The Art of the Deal）
  void completeDeal(double dealValue, bool succeeded) {
    if (succeeded) {
      _wealth += dealValue;
      _ego = (_ego + 10).clamp(0, 100);
      _setSpeech('DEAL! 我是有史以來最好的交易者！');
    } else {
      _wealth = (_wealth - dealValue * 0.1).clamp(0, double.infinity);
      _ego = (_ego - 15).clamp(0, 100);
      _setSpeech('這次不划算，但我從不真正輸！');
    }
    _energy = (_energy - 15).clamp(0, 100);
    _applyWealthCrisis();
    notifyListeners();
  }

  /// ⛳ 打高爾夫（放鬆 + 人脈）
  void playGolf() {
    _energy = (_energy + 20).clamp(0, 100);
    _ego = (_ego + 10).clamp(0, 100);
    _support = (_support + 8).clamp(0, 100);
    _wealth += 200 + (_stageIndex * 100); // 球場人脈帶來商機
    _setSpeech('高爾夫！我的球技是歷屆總統中最好的！');
    _characterState = CharacterState.happy;
    notifyListeners();
    _resetStateAfter(const Duration(seconds: 2));
  }

  /// 🤝 談判（財富 + 名氣，消耗精力）
  void negotiate() {
    if (_energy < 10) {
      _setSpeech('太累了！我需要休息才能談判！');
      notifyListeners();
      return;
    }
    final gain = 2000.0 + (_stageIndex * 800);
    _wealth += gain;
    _fame = _fame + 300 * (_stageIndex + 1);
    _ego = (_ego + 8).clamp(0, 100);
    _energy = (_energy - 15).clamp(0, 100);
    _support = (_support + 5).clamp(0, 100);
    _setSpeech('這是有史以來最偉大的交易！ART OF THE DEAL!');
    _characterState = CharacterState.celebrating;
    _applyEgoFameInteraction();
    notifyListeners();
    _resetStateAfter(const Duration(seconds: 2));
  }

  // ── 建設系統 ─────────────────────────────────────────────

  void buildStructure(String buildingKey, double cost) {
    if (_wealth >= cost) {
      _wealth -= cost;
      _unlockedBuildings.add(buildingKey);
      _setSpeech('又一個偉大的建築！最棒的！');
      notifyListeners();
    }
  }

  // ── 事件完成 ─────────────────────────────────────────────

  void completeEvent(String eventKey, Map<String, double> rewards) {
    if (_completedEvents.contains(eventKey)) return;
    _completedEvents.add(eventKey);
    rewards.forEach((stat, val) => _applyStat(stat, val));

    // ── 特殊事件邏輯 ──────────────────────────────────────
    switch (eventKey) {
      case 'trump_tower_opening':
        _wealth *= 2; // WEALTH ×2
      case 'election_2016':
        _setSpeech('306 對 232！所有人都沒想到！MAKE AMERICA GREAT AGAIN!');
        _characterState = CharacterState.celebrating;
        _resetStateAfter(const Duration(seconds: 4));
      case 'election_2024':
        _hiddenEndingUnlocked = true;
        _setSpeech('312 對 226！史上最偉大的勝利！FOUR MORE YEARS!');
        _characterState = CharacterState.celebrating;
        _resetStateAfter(const Duration(seconds: 4));
    }

    _checkStageAdvance();
    notifyListeners();
  }

  /// Twitter 封號：直接縮減 fame 倍率（不走 completeEvent rewards 機制）
  void applyFameMultiplier(double multiplier) {
    _fame *= multiplier;
    notifyListeners();
  }

  // ── 成長階段 ─────────────────────────────────────────────

  void advanceStage() {
    if (canAdvanceStage) {
      _stageIndex++;
      _setSpeech(_stageSpeech(stage));
      notifyListeners();
    }
  }

  // ── 每日 tick（放置遊戲）────────────────────────────────

  void dailyTick() {
    // 被動衰減
    _hunger = (_hunger - 8).clamp(0, 100);
    _energy = (_energy - 5).clamp(0, 100);
    _ego = (_ego - 2).clamp(0, 100);

    // 建築被動收益
    if (_unlockedBuildings.contains('hotel')) _wealth += 100;
    if (_unlockedBuildings.contains('trump_tower')) {
      _wealth += 500;
      _fame += 500;
      _ego = (_ego + 2).clamp(0, 100);
    }
    if (_unlockedBuildings.contains('casino')) {
      _wealth += 2000;
      // 破產風險
      if (_wealth > 200000) _wealth *= 0.98;
    }
    if (_unlockedBuildings.contains('golf_course')) {
      _energy = (_energy + 20).clamp(0, 100);
    }

    // Fame 帶動 Support
    if (_fame > 10000) _support = (_support + 0.5).clamp(0, 100);

    _applyEgoFameInteraction();
    _applyWealthCrisis();
    _checkStageAdvance();
    notifyListeners();
  }

  // ── 私有輔助 ─────────────────────────────────────────────

  void _setSpeech(String text) {
    _currentSpeech = text;
  }

  /// 動畫幀：N秒後自動回到 idle
  void _resetStateAfter(Duration delay) {
    Future.delayed(delay, () {
      if (!_disposed) {
        _characterState = CharacterState.idle;
        notifyListeners();
      }
    });
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _tickTimer.cancel();
    super.dispose();
  }

  void _applyEgoFameInteraction() {
    // EGO ↑ → FAME ↑（但也帶來訴訟風險，暫以 support 微降模擬）
    if (_ego > 80) {
      _fame += 200;
      _support = (_support - 1).clamp(0, 100);
    }
    if (_fame > 50000) {
      _support = (_support + 0.2).clamp(0, 100);
    }
  }

  void _applyWealthCrisis() {
    if (_wealth <= 0 && !_completedEvents.contains('bankruptcy')) {
      _wealth = 0;
      _bankruptcyCount++;
      _fame += 5000; // 破產反而暴增知名度
      _completedEvents.add('bankruptcy');
      _setSpeech('我從不真正破產！這只是「重組」！');
    }
  }

  void _checkStageAdvance() {
    if (canAdvanceStage) {
      // 提示 UI 層可升級（不自動升級，需玩家確認）
    }
    _checkAllStoryEvents();
  }

  // ── 劇情事件觸發條件總表 ─────────────────────────────────────

  // ── 劇情事件時間軸（嚴格依歷史順序串接）─────────────────────
  //
  //  Candidate 階段
  //    1. gop_debate        → 2015–2016 共和黨辯論   (SUPPORT ≥ 40)
  //    2. election_2016     → 2016.11 選舉夜         (gop_debate ✓ + SUPPORT ≥ 80)
  //
  //  thePresident 階段
  //    3. impeachment_1     → 2019.12 第一次彈劾     (election_2016 ✓)
  //    4. twitter_ban       → 2021.01 Twitter 封號   (impeachment_1 ✓)
  //    5. conviction_2024   → 2024.05 重罪定罪       (twitter_ban ✓)
  //    6. assassination_attempt → 2024.07 暗殺未遂   (conviction_2024 ✓)
  //    7. election_2024     → 2024.11 再度當選       (assassination_attempt ✓ + SUPPORT ≥ 80)

  void _checkAllStoryEvents() {
    if (_pendingEventKey != null) return;

    // 1. 共和黨辯論（Candidate 階段起，SUPPORT 達標）
    _checkInteractiveEvent('gop_debate',
        condition: _stageIndex >= CharacterStage.candidate.index && _support >= 40);

    // 2. 選舉夜 2016（辯論後，SUPPORT 達 80）
    _checkInteractiveEvent('election_2016',
        condition: _stageIndex >= CharacterStage.candidate.index &&
            _completedEvents.contains('gop_debate') && _support >= 80);

    // 3. 第一次彈劾（進入 thePresident 後，選舉 2016 已完成）
    _checkInteractiveEvent('impeachment_1',
        condition: _stageIndex >= CharacterStage.thePresident.index &&
            _completedEvents.contains('election_2016'));

    // 4. Twitter 封號（彈劾後，EGO 飆高到危險值）
    _checkInteractiveEvent('twitter_ban',
        condition: _completedEvents.contains('impeachment_1') && _ego >= 85);

    // 5. 重罪定罪（封號後）
    _checkInteractiveEvent('conviction_2024',
        condition: _completedEvents.contains('twitter_ban'));

    // 6. 暗殺未遂（定罪後）
    _checkInteractiveEvent('assassination_attempt',
        condition: _completedEvents.contains('conviction_2024'));

    // 7. 2024 再度當選（暗殺後，SUPPORT 回升到 80）
    _checkInteractiveEvent('election_2024',
        condition: _completedEvents.contains('assassination_attempt') && _support >= 80);

    // 8. 第三次世界大戰？（再度當選後，特殊結局事件）
    _checkInteractiveEvent('ww3',
        condition: _completedEvents.contains('election_2024'));
  }

  void _checkInteractiveEvent(String key, {required bool condition}) {
    if (_pendingEventKey != null) return;
    if (_completedEvents.contains(key)) return;
    if (!condition) return;
    _pendingEventKey = key;
  }

  bool _meetsUnlockCondition(CharacterStage next) {
    switch (next) {
      case CharacterStage.queensKid:
        return _wealth >= 100;
      case CharacterStage.militaryCadet:
        return _ego >= 50;
      case CharacterStage.whartonBoy:
        return _fame >= 60;
      case CharacterStage.daddysApprentice:
        return _wealth >= 500 && _ego >= 60;
      case CharacterStage.manhattanMogul:
        return _wealth >= 10000;
      case CharacterStage.casinoKing:
        return _wealth >= 50000;
      case CharacterStage.tvStar:
        return _fame >= 50000;
      case CharacterStage.candidate:
        return _support >= 60;
      case CharacterStage.thePresident:
        return _support >= 80 && _completedEvents.contains('election_2016');
      default:
        return false;
    }
  }

  void _applyStat(String stat, double val) {
    switch (stat) {
      case 'wealth':
        _wealth = (_wealth + val).clamp(0, double.infinity);
      case 'fame':
        _fame = (_fame + val).clamp(0, double.infinity);
      case 'hunger':
        _hunger = (_hunger + val).clamp(0, 100);
      case 'ego':
        _ego = (_ego + val).clamp(0, 100);
      case 'energy':
        _energy = (_energy + val).clamp(0, 100);
      case 'support':
        _support = (_support + val).clamp(0, 100);
    }
  }

  int _scoreTweet(String text) {
    int score = 0;
    if (text == text.toUpperCase()) score += 20; // 全大寫
    score += (text.split('!').length - 1).clamp(0, 20); // 感嘆號數
    final nicknames = ['Sleepy', 'Crooked', 'Pocahontas', 'Mini', 'Fake', 'Nasty'];
    for (final n in nicknames) {
      if (text.contains(n)) score += 15;
    }
    if (text.contains('SAD!') || text.contains('TREMENDOUS')) score += 15;
    if (text.length <= 280) score += 10;
    return score.clamp(0, 100);
  }

  String _foodSpeech(String food) {
    final map = {
      'BigMac': '又一個完美的 Big Mac！我可以每天吃！',
      'DietCoke': 'Diet Coke！健康又美味！',
      'KFC': 'KFC 炸雞！全世界最好的食物！',
      'Pizza': '紐約披薩！TREMENDOUS!',
    };
    return map[food] ?? '太棒了！美食！';
  }

  String _stageSpeech(CharacterStage s) {
    switch (s) {
      case CharacterStage.babyDonald:
        return '我是最聰明的嬰兒！';
      case CharacterStage.queensKid:
        return '皇后區沒有人比我厲害！';
      case CharacterStage.militaryCadet:
        return '紀律是成功的基礎！';
      case CharacterStage.whartonBoy:
        return '我是沃頓最頂尖的畢業生！';
      case CharacterStage.daddysApprentice:
        return '老爸說得對，交易就是一切！';
      case CharacterStage.manhattanMogul:
        return '曼哈頓！我來了！';
      case CharacterStage.casinoKing:
        return '世界第八大奇觀！就是我的賭場！';
      case CharacterStage.tvStar:
        return 'You\'re Fired! 全美都愛我！';
      case CharacterStage.candidate:
        return 'Make America Great Again!';
      case CharacterStage.thePresident:
        return 'I am THE PRESIDENT. The greatest ever!';
    }
  }
}
