import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kGold = Color(0xFFFFD700);
const _kRed  = Color(0xFFCC0000);
const _kNavy = Color(0xFF002868);

TextStyle _mono({double size = 12, Color color = _kGold, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color, fontWeight: weight);

/// 🎤 共和黨辯論 小遊戲
/// 3 道川普風格選擇題，最「Trump-like」的答案得最高分
/// 最終分數決定 SUPPORT 增益幅度
class GopDebateOverlay extends StatefulWidget {
  /// score 0–3 (正確答案數)
  final void Function(int score) onComplete;
  const GopDebateOverlay({super.key, required this.onComplete});

  @override
  State<GopDebateOverlay> createState() => _GopDebateOverlayState();
}

class _GopDebateOverlayState extends State<GopDebateOverlay> {
  static const _questions = [
    _Question(
      q: '主持人問：「您的移民政策\n具體是什麼？」',
      options: [
        '提出詳細的政策計畫',
        '「他們帶來了犯罪！我要蓋一道牆！」',
        '「問得好，讓我想想……」',
        '「移民問題非常複雜，需要全面討論」',
      ],
      correctIndex: 1,
      explanation: '越具體越不是川普！直接攻擊才是王道！',
    ),
    _Question(
      q: '對手攻擊你的商業失敗，你怎麼回？',
      options: [
        '「我承認我犯了一些錯誤……」',
        '「我的商業成就是有史以來最好的！」',
        '「我破產了幾次但每次都更強！」',
        '「讓我解釋一下……」',
      ],
      correctIndex: 2,
      explanation: '承認破產但宣稱「更強了」，最川普！',
    ),
    _Question(
      q: '有人問你外交政策，\n你完全不熟這個話題……',
      options: [
        '「我需要更多時間研究」',
        '「讓我諮詢我的顧問」',
        '「我比所有將軍都了解 ISIS！BELIEVE ME!」',
        '「這是個非常好的問題……」',
      ],
      correctIndex: 2,
      explanation: '知識？不需要！自信！BELIEVE ME!',
    ),
  ];

  int _current = 0;
  int _score = 0;
  int? _selected;
  bool _showResult = false;
  bool _done = false;

  void _pick(int idx) {
    if (_selected != null) return;
    final correct = idx == _questions[_current].correctIndex;
    setState(() {
      _selected = idx;
      _showResult = true;
      if (correct) _score++;
    });
  }

  void _next() {
    if (_current >= _questions.length - 1) {
      setState(() => _done = true);
    } else {
      setState(() {
        _current++;
        _selected = null;
        _showResult = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _done ? _ResultPanel(score: _score, onDone: () => widget.onComplete(_score))
              : _QuestionPanel(
                  question: _questions[_current],
                  index: _current,
                  total: _questions.length,
                  selected: _selected,
                  showResult: _showResult,
                  onPick: _pick,
                  onNext: _next,
                ),
        ),
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  final _Question question;
  final int index;
  final int total;
  final int? selected;
  final bool showResult;
  final void Function(int) onPick;
  final VoidCallback onNext;
  const _QuestionPanel({
    required this.question, required this.index, required this.total,
    required this.selected, required this.showResult,
    required this.onPick, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題欄
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: _kNavy,
          child: Row(children: [
            Text('🎤 共和黨辯論', style: _mono(size: 11)),
            const Spacer(),
            Text('問題 ${index + 1}/$total',
                style: _mono(size: 9, color: Colors.white54, weight: FontWeight.normal)),
          ]),
        ),
        const SizedBox(height: 20),
        // 問題
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: _kGold.withValues(alpha: 0.4)),
            color: _kGold.withValues(alpha: 0.04),
          ),
          child: Text(question.q,
              style: _mono(size: 12, color: Colors.white, weight: FontWeight.normal)),
        ),
        const SizedBox(height: 16),
        // 選項
        ...List.generate(question.options.length, (i) {
          Color borderColor = _kGold.withValues(alpha: 0.3);
          Color bg = Colors.transparent;
          if (showResult && selected == i) {
            borderColor = i == question.correctIndex ? const Color(0xFF00FF88) : _kRed;
            bg = borderColor.withValues(alpha: 0.1);
          } else if (showResult && i == question.correctIndex) {
            borderColor = const Color(0xFF00FF88);
          }
          return GestureDetector(
            onTap: () => onPick(i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 1.5),
                color: bg,
              ),
              child: Text(question.options[i],
                  style: _mono(size: 9, color: Colors.white, weight: FontWeight.normal)),
            ),
          );
        }),
        // 解釋 + 下一題
        if (showResult) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            color: _kGold.withValues(alpha: 0.08),
            child: Text('💡 ${question.explanation}',
                style: _mono(size: 9, color: _kGold, weight: FontWeight.normal)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onNext,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: _kRed,
              child: Text(
                  index < 2 ? '下一題 ▶' : '查看結果 ▶',
                  textAlign: TextAlign.center,
                  style: _mono(size: 11, color: _kGold)),
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final int score;
  final VoidCallback onDone;
  const _ResultPanel({required this.score, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final (title, desc) = switch (score) {
      3 => ('🏆 PERFECT TRUMP!', '你就是唐納・川普！\nSUPPORT 大幅提升！'),
      2 => ('👍 TREMENDOUS!', '川普風格十足！\nSUPPORT 顯著提升！'),
      1 => ('😤 OKAY...', '還需要練習！\nSUPPORT 小幅提升'),
      _ => ('😴 SAD!', '完全不像川普！\nSUPPORT 微幅提升'),
    };
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(title, style: _mono(size: 24, color: _kGold), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('$score / 3 正確', style: _mono(size: 16, color: Colors.white)),
        const SizedBox(height: 8),
        Text(desc,
            textAlign: TextAlign.center,
            style: _mono(size: 10, color: Colors.white70, weight: FontWeight.normal)),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: onDone,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(color: _kRed, border: Border.all(color: _kGold, width: 2)),
            child: Text('繼續! ▶', style: _mono(size: 12, color: _kGold)),
          ),
        ),
      ]),
    );
  }
}

class _Question {
  final String q;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  const _Question({required this.q, required this.options, required this.correctIndex, required this.explanation});
}
