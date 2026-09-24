import 'package:flutter/material.dart';
import '../widgets/language_selector.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  String? selectedMood;

  final List<Map<String, dynamic>> moods = [
    {'name': 'Happy', 'emoji': '😊', 'color': Color(0xFFFFF1C7)},
    {'name': 'Calm', 'emoji': '😌', 'color': Color(0xFFE4EFEA)},
    {'name': 'Okay', 'emoji': '🙂', 'color': Color(0xFFE8EDF5)},
    {'name': 'Sad', 'emoji': '😔', 'color': Color(0xFFE5E3F2)},
    {'name': 'Anxious', 'emoji': '😟', 'color': Color(0xFFF6E5E0)},
  ];

  final List<Map<String, dynamic>> moodHistory = [
    {'day': 'Mon', 'mood': 'Happy', 'emoji': '😊', 'score': 5},
    {'day': 'Tue', 'mood': 'Calm', 'emoji': '😌', 'score': 4},
    {'day': 'Wed', 'mood': 'Okay', 'emoji': '🙂', 'score': 3},
    {'day': 'Thu', 'mood': 'Happy', 'emoji': '😊', 'score': 5},
    {'day': 'Fri', 'mood': 'Calm', 'emoji': '😌', 'score': 4},
    {'day': 'Sat', 'mood': 'Happy', 'emoji': '😊', 'score': 5},
    {'day': 'Sun', 'mood': 'Okay', 'emoji': '🙂', 'score': 3},
  ];

  void selectMood(String mood) {
    setState(() {
      selectedMood = mood;
    });
  }

  void saveMood() {
    if (selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood first.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Your $selectedMood mood has been recorded.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF173B35)),
        ),
        title: const TrText(
          'My Mood',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
        actions: const [
          LanguageSelectorButton(),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // INTRODUCTION
              // =================================================
              const TrText(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 8),

              const TrText(
                'Take a moment to tell us how you feel.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),

              const SizedBox(height: 22),

              // =================================================
              // MOOD SELECTION
              // =================================================
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                ),
                itemBuilder: (context, index) {
                  final mood = moods[index];
                  final bool isSelected = selectedMood == mood['name'];

                  return GestureDetector(
                    onTap: () {
                      selectMood(mood['name'] as String);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: mood['color'] as Color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF376B5C)
                              : Colors.transparent,
                          width: isSelected ? 3 : 0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mood['emoji'] as String,
                            style: const TextStyle(fontSize: 35),
                          ),
                          const SizedBox(height: 7),
                          TrText(
                            mood['name'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF376B5C)
                                  : const Color(0xFF173B35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // =================================================
              // SAVE BUTTON
              // =================================================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: saveMood,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const TrText(
                    'Save My Mood',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF376B5C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // TODAY'S MOOD
              // =================================================
              const TrText(
                "Today's Mood",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE4EFEA),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          selectedMood == null
                              ? '🙂'
                              : _getEmoji(selectedMood!),
                          style: const TextStyle(fontSize: 35),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TrText(
                            selectedMood ?? 'Not recorded yet',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173B35),
                            ),
                          ),

                          const SizedBox(height: 5),

                          TrText(
                            selectedMood == null
                                ? 'Choose a mood above.'
                                : 'Thank you for sharing how you feel.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // MOOD TREND
              // =================================================
              const TrText(
                'Mood Trend',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 8),

              const TrText(
                'Your mood during the past week.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: CustomPaint(
                        painter: _MoodChartPainter(moodHistory),
                        child: Container(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: moodHistory.map((item) {
                        return TrText(
                          item['day'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // WEEKLY SUMMARY
              // =================================================
              const TrText(
                'Weekly Summary',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      Icons.sentiment_satisfied_alt_rounded,
                      'Positive Days',
                      '5',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _summaryCard(
                      Icons.favorite_border_rounded,
                      'Mood Score',
                      '4.1 / 5',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFF376B5C),
                      size: 30,
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: TrText(
                        'You have been feeling positive most days this week. Keep following your daily routine!',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF173B35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // EMOJI HELPER
  // ==========================================================

  String _getEmoji(String mood) {
    switch (mood) {
      case 'Happy':
        return '😊';
      case 'Calm':
        return '😌';
      case 'Okay':
        return '🙂';
      case 'Sad':
        return '😔';
      case 'Anxious':
        return '😟';
      default:
        return '🙂';
    }
  }

  // ==========================================================
  // SUMMARY CARD
  // ==========================================================

  Widget _summaryCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF376B5C), size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B35),
            ),
          ),
          const SizedBox(height: 4),
          TrText(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ============================================================
// MOOD CHART
// ============================================================

class _MoodChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  _MoodChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF376B5C)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF376B5C)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..strokeWidth = 1;

    const double leftPadding = 25;
    const double rightPadding = 10;
    const double topPadding = 15;
    const double bottomPadding = 10;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Grid lines
    for (int i = 1; i <= 5; i++) {
      final y = topPadding + chartHeight - ((i - 1) / 4) * chartHeight;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final score = data[i]['score'] as int;
      final x = leftPadding + (i / (data.length - 1)) * chartWidth;
      final y = topPadding + chartHeight - ((score - 1) / 4) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Points
    for (int i = 0; i < data.length; i++) {
      final score = data[i]['score'] as int;
      final x = leftPadding + (i / (data.length - 1)) * chartWidth;
      final y = topPadding + chartHeight - ((score - 1) / 4) * chartHeight;
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MoodChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
