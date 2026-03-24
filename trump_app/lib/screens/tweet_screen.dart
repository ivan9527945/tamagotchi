import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../character/character_state.dart';

/// 🐦 推文風暴！— 撰寫川普風格推文，系統評分
class TweetScreen extends StatefulWidget {
  const TweetScreen({super.key});

  @override
  State<TweetScreen> createState() => _TweetScreenState();
}

class _TweetScreenState extends State<TweetScreen> {
  final _controller = TextEditingController();
  int? _lastScore;
  bool _posted = false;

  static const _rules = [
    (emoji: '🔠', rule: '全大寫字母', detail: '+20分'),
    (emoji: '❗', rule: '感嘆號數量', detail: '每個+1分'),
    (emoji: '😠', rule: '使用貶義綽號', detail: '+15分/個'),
    (emoji: '🏆', rule: 'SAD! / TREMENDOUS', detail: '+15分'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _post() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final gs = context.read<GameState>();
    final score = gs.postTweet(text);
    setState(() {
      _lastScore = score;
      _posted = true;
    });
  }

  void _reset() {
    setState(() {
      _lastScore = null;
      _posted = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F4FF),
      child: Column(
        children: [
          _buildHeader(context),
          _buildCharArea(),
          // 評分規則列
          _buildRulesBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInputArea(),
                  if (_lastScore != null) _buildScoreResult(),
                  const SizedBox(height: 16),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
              child: const Row(children: [
                Icon(Icons.arrow_back_ios, size: 14),
                Text('返回', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const Text('🐦 推文風暴！', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE8F4FF), borderRadius: BorderRadius.circular(20)),
            child: Text(
              _lastScore != null ? '${_lastScore}分' : 'TWEET',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1DA1F2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharArea() {
    final gs = context.watch<GameState>();
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/characters/${gs.stage.pngName}.png',
              height: 150,
              errorBuilder: (_, __, ___) => const Text('🐦', style: TextStyle(fontSize: 80)),
            ),
          ),
          if (gs.egoOverload)
            Positioned(
              top: 10, right: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3333),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('EGO OVERLOAD!', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRulesBar() {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFF9F1C),
      const Color(0xFFFFD60A),
      const Color(0xFF2EC4B6),
    ];
    return Container(
      color: const Color(0xFFDEEEFF),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: List.generate(_rules.length, (i) {
          final r = _rules[i];
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors[i],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 14)),
                  Text(r.rule, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                  Text(r.detail, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 8)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputArea() {
    final charCount = _controller.text.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          // Input card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFAA00), width: 2.5),
              boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 12, offset: Offset(0, 4))],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  maxLength: 280,
                  maxLines: 4,
                  enabled: !_posted,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'FAKE NEWS! CNN is the WORST! We will MAKE AMERICA GREAT AGAIN! SAD!',
                    hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$charCount / 280',
                      style: TextStyle(
                        fontSize: 11,
                        color: charCount > 260 ? Colors.red : const Color(0xFF888888),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Post button
          GestureDetector(
            onTap: _posted ? _reset : _post,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: _posted ? const Color(0xFF22AA44) : const Color(0xFF1DA1F2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0x40FF3333), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Center(
                child: Text(
                  _posted ? '✅ 已發推！再發一條' : '🐦 發推！',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreResult() {
    final score = _lastScore!;
    final Color scoreColor;
    final String scoreLabel;
    if (score >= 80) { scoreColor = const Color(0xFFFFD700); scoreLabel = '川普本人！TREMENDOUS!'; }
    else if (score >= 50) { scoreColor = const Color(0xFF1DA1F2); scoreLabel = '很有川普味！'; }
    else if (score >= 20) { scoreColor = const Color(0xFFFF8833); scoreLabel = '還行，多用大寫！'; }
    else { scoreColor = const Color(0xFF888888); scoreLabel = 'LOW ENERGY! SAD!'; }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scoreColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scoreColor, width: 2),
        ),
        child: Row(
          children: [
            Text('$score', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: scoreColor)),
            const Text(' 分', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                scoreLabel,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: scoreColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
