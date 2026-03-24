import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/character_state.dart';

/// 🗺️ 人生事件地圖 — 顯示30+歷史事件，可完成解鎖
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  static const _events = [
    _Event(key: 'learn_from_dad', stage: CharacterStage.babyDonald, emoji: '🏠', title: '父親的第一課',
        year: '1950s', desc: '弗雷德教你如何與政府打交道，獲得「交易啟蒙」技能',
        rewards: {'wealth': 100, 'ego': 10}, unlockStage: CharacterStage.daddysApprentice),
    _Event(key: 'military_academy', stage: CharacterStage.militaryCadet, emoji: '🎖️', title: '軍事學院入學',
        year: '1959', desc: '強制管教，解鎖「紀律」屬性',
        rewards: {'ego': 15, 'energy': 10}, unlockStage: null),
    _Event(key: 'wharton_grad', stage: CharacterStage.whartonBoy, emoji: '🎓', title: '沃頓畢業',
        year: '1968', desc: '「我是沃頓最頂尖的畢業生」成就解鎖',
        rewards: {'fame': 200, 'ego': 20}, unlockStage: null),
    _Event(key: 'trump_tower', stage: CharacterStage.manhattanMogul, emoji: '🗼', title: '川普大廈開幕',
        year: '1983', desc: '建設完成慶祝動畫，WEALTH ×2，FAME +10,000',
        rewards: {'wealth': 50000, 'fame': 10000}, unlockStage: null),
    _Event(key: 'taj_mahal', stage: CharacterStage.casinoKing, emoji: '🎰', title: '泰姬瑪哈開業',
        year: '1990', desc: '「世界第八大奇觀」，耗盡資金但聲望暴漲',
        rewards: {'fame': 20000, 'wealth': -50000}, unlockStage: null),
    _Event(key: 'bankruptcy', stage: CharacterStage.casinoKing, emoji: '💸', title: '破產危機',
        year: '1991', desc: '限時談判任務，成功重組 or 宣告破產',
        rewards: {'fame': 5000}, unlockStage: null),
    _Event(key: 'apprentice', stage: CharacterStage.tvStar, emoji: '📺', title: 'The Apprentice 試播',
        year: '2004', desc: '錄製節目小遊戲，FAME 爆炸性成長',
        rewards: {'fame': 50000}, unlockStage: null),
    _Event(key: 'you_re_fired', stage: CharacterStage.tvStar, emoji: '🔥', title: 'You\'re Fired! 首次說出',
        year: '2004', desc: '全服成就通知，口頭禪解鎖',
        rewards: {'fame': 10000, 'ego': 15}, unlockStage: null),
    _Event(key: 'escalator', stage: CharacterStage.candidate, emoji: '🛗', title: '搭手扶梯宣布參選',
        year: '2015-06-16', desc: '動畫重現名場面，正式踏上政治之路',
        rewards: {'support': 10, 'fame': 30000}, unlockStage: null),
    _Event(key: 'election_2016', stage: CharacterStage.candidate, emoji: '🌙', title: '選舉夜 2016',
        year: '2016-11-08', desc: '緊張倒數，選舉人票實時累積，306 vs 232',
        rewards: {'support': 40, 'fame': 100000}, unlockStage: CharacterStage.thePresident),
    _Event(key: 'impeachment_1', stage: CharacterStage.thePresident, emoji: '🔨', title: '第一次彈劾',
        year: '2019', desc: '找夠多參議員支持的防禦小遊戲',
        rewards: {'support': -10, 'fame': 5000}, unlockStage: null),
    _Event(key: 'jan6', stage: CharacterStage.thePresident, emoji: '🏛️', title: '國會山莊事件',
        year: '2021-01-06', desc: '高風險危機，影響最終結局分支',
        rewards: {'support': -20, 'ego': -10}, unlockStage: null),
    _Event(key: 'twitter_ban', stage: CharacterStage.thePresident, emoji: '🚫', title: 'Twitter 封號',
        year: '2021', desc: '突發危機，需在24小時內移往Truth Social',
        rewards: {'fame': -5000, 'ego': -15}, unlockStage: null),
    _Event(key: 'conviction', stage: CharacterStage.thePresident, emoji: '⚖️', title: '重罪定罪',
        year: '2024', desc: '史上首位被定罪前總統，EGO危機與SUPPORT大考驗',
        rewards: {'support': -15, 'ego': 20}, unlockStage: null),
    _Event(key: 'election_2024', stage: CharacterStage.thePresident, emoji: '🏆', title: '2024再度當選',
        year: '2024-11-05', desc: '隱藏結局，312 vs 226選舉人票勝利動畫',
        rewards: {'support': 50, 'fame': 200000}, unlockStage: null),
  ];

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return Container(
      color: const Color(0xFFF0F8FF),
      child: Column(
        children: [
          _buildHeader(context, gs),
          _buildProgressSection(gs),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              itemCount: _events.length,
              itemBuilder: (context, i) {
                final ev = _events[i];
                final completed = gs.completedEvents.contains(ev.key);
                final available = _isAvailable(ev, gs);
                return _EventCard(
                  event: ev,
                  completed: completed,
                  available: available,
                  onTap: available && !completed
                      ? () => gs.completeEvent(ev.key, ev.rewards)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameState gs) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('人生軌跡', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
              Text('${gs.stage.displayName} | ${gs.stage.ageRange}', style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFE8F4FF), borderRadius: BorderRadius.circular(20)),
            child: Text(
              '${gs.completedEvents.length} / ${_events.length} 完成',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1DA1F2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(GameState gs) {
    final completed = gs.completedEvents.length;
    final total = _events.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('人生進度', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
              Text('$completed / $total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              backgroundColor: const Color(0xFFCCE8FF),
              color: const Color(0xFF1DA1F2),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  bool _isAvailable(_Event ev, GameState gs) {
    // 事件所在階段 ≤ 當前階段才可用
    return ev.stage.index <= gs.stage.index;
  }
}

class _Event {
  final String key;
  final CharacterStage stage;
  final String emoji;
  final String title;
  final String year;
  final String desc;
  final Map<String, double> rewards;
  final CharacterStage? unlockStage;

  const _Event({
    required this.key,
    required this.stage,
    required this.emoji,
    required this.title,
    required this.year,
    required this.desc,
    required this.rewards,
    this.unlockStage,
  });
}

class _EventCard extends StatelessWidget {
  final _Event event;
  final bool completed;
  final bool available;
  final VoidCallback? onTap;

  const _EventCard({
    required this.event,
    required this.completed,
    required this.available,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    if (completed) { bgColor = const Color(0xFFF0FFF4); borderColor = const Color(0xFF22C55E); }
    else if (available) { bgColor = const Color(0xFFFFFBEB); borderColor = const Color(0xFFFFAA00); }
    else { bgColor = const Color(0xFFF9FAFB); borderColor = Colors.transparent; }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: available || completed ? 2 : 0),
          boxShadow: available || completed
              ? [BoxShadow(color: borderColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))]
              : null,
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: completed
                    ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                    : available
                        ? const Color(0xFFFFAA00).withValues(alpha: 0.15)
                        : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  completed ? '✅' : event.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: available || completed ? const Color(0xFF1A1A1A) : const Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                      Text(
                        event.year,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF888888), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.desc,
                    style: TextStyle(
                      fontSize: 11,
                      color: available || completed ? const Color(0xFF555555) : const Color(0xFFBBBBBB),
                    ),
                  ),
                  if ((available || completed) && event.rewards.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: event.rewards.entries.map((e) {
                        final positive = e.value >= 0;
                        return Text(
                          '${positive ? '+' : ''}${e.value.toInt()} ${e.key}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: positive ? const Color(0xFF22C55E) : const Color(0xFFFF4444),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            if (available && !completed)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.chevron_right, color: Color(0xFFFFAA00)),
              ),
          ],
        ),
      ),
    );
  }
}
