import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  bool isWeekly = true;

  // Dummy data for now.
  // Backend/game data can be connected later.
  final List<int> weeklyScores = [62, 68, 71, 75, 73, 79, 82];

  final List<String> weeklyDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  final List<int> monthlyScores = [58, 62, 65, 67, 70, 68, 73, 76, 79, 82];

  final List<String> monthlyDays = [
    '1',
    '4',
    '7',
    '10',
    '13',
    '16',
    '19',
    '22',
    '25',
    '28',
  ];

  @override
  Widget build(BuildContext context) {
    final scores = isWeekly ? weeklyScores : monthlyScores;
    final labels = isWeekly ? weeklyDays : monthlyDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        title: const Text(
          'My Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // HEADER
              // ------------------------------------------------

              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Keep practicing to improve your cognitive skills.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // OVERALL PROGRESS
              // ------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  children: [
                    const Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: 130,
                      height: 130,

                      child: Stack(
                        alignment: Alignment.center,

                        children: [
                          SizedBox(
                            width: 130,
                            height: 130,

                            child: CircularProgressIndicator(
                              value: 0.65,
                              strokeWidth: 12,

                              backgroundColor: Colors.white,

                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF376B5C),
                              ),
                            ),
                          ),

                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Text(
                                '65%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),

                              Text(
                                'Overall',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: Color(0xFF376B5C),
                          size: 20,
                        ),

                        SizedBox(width: 6),

                        Text(
                          '8% improvement this month',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF376B5C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // COGNITIVE SKILLS
              // ------------------------------------------------
              const Text(
                'Cognitive Skills',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 14),

              _skillCard('Memory', 0.82, Icons.psychology_rounded),

              const SizedBox(height: 12),

              _skillCard('Attention', 0.74, Icons.center_focus_strong_rounded),

              const SizedBox(height: 12),

              _skillCard(
                'Problem Solving',
                0.68,
                Icons.lightbulb_outline_rounded,
              ),

              const SizedBox(height: 12),

              _skillCard('Recognition', 0.79, Icons.visibility_rounded),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // PROGRESS TREND
              // ------------------------------------------------
              const Text(
                'Progress Trend',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Cognitive Performance',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                'Track your improvement over time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(4),

                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F3F1),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Row(
                            children: [
                              _periodButton('Week', isWeekly, () {
                                setState(() {
                                  isWeekly = true;
                                });
                              }),

                              _periodButton('Month', !isWeekly, () {
                                setState(() {
                                  isWeekly = false;
                                });
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      height: 220,

                      child: _buildProgressChart(scores, labels),
                    ),

                    const SizedBox(height: 10),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),

                        SizedBox(width: 5),

                        Text(
                          'Tap a point to view the score',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // ACTIVITY PERFORMANCE
              // ------------------------------------------------
              const Text(
                'Activity Performance',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 14),

              _performanceCard(
                'Memory Match',
                'Good',
                0.75,
                Icons.psychology_rounded,
                const Color(0xFFE4EFEA),
              ),

              const SizedBox(height: 12),

              _performanceCard(
                'Pattern Recall',
                'Improving',
                0.60,
                Icons.grid_view_rounded,
                const Color(0xFFE8E4F1),
              ),

              const SizedBox(height: 12),

              _performanceCard(
                'Odd One Out',
                'Good',
                0.80,
                Icons.visibility_rounded,
                const Color(0xFFF1E8D8),
              ),

              const SizedBox(height: 12),

              _performanceCard(
                'Number Sequence',
                'Keep Practicing',
                0.45,
                Icons.pin_rounded,
                const Color(0xFFE5E9F0),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // ACTIVITY STATISTICS
              // ------------------------------------------------
              const Text(
                'Activity Statistics',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      Icons.check_circle_outline_rounded,
                      '12',
                      'Activities Completed',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      Icons.track_changes_rounded,
                      '84%',
                      'Average Accuracy',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      Icons.star_outline_rounded,
                      '78',
                      'Average Score',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      Icons.timer_outlined,
                      '24 min',
                      'Practice Time',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // MOOD TREND
              // ------------------------------------------------
              const Text(
                'Mood Trend',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'How you have been feeling',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,

                      children: [
                        _moodItem('Mon', '😊', 'Happy'),

                        _moodItem('Tue', '😌', 'Calm'),

                        _moodItem('Wed', '😊', 'Happy'),

                        _moodItem('Thu', '🙂', 'Okay'),

                        _moodItem('Fri', '😌', 'Calm'),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: const Color(0xFFE4EFEA),
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Row(
                        children: [
                          Icon(
                            Icons.favorite_outline_rounded,
                            color: Color(0xFF376B5C),
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              'Your mood has been mostly positive this week.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF376B5C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // REMINDER ADHERENCE
              // ------------------------------------------------
              const Text(
                'Reminder Adherence',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,

                          child: Stack(
                            alignment: Alignment.center,

                            children: [
                              SizedBox(
                                width: 90,
                                height: 90,

                                child: CircularProgressIndicator(
                                  value: 0.80,
                                  strokeWidth: 9,

                                  backgroundColor: const Color(0xFFE5E5E5),

                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF376B5C),
                                      ),
                                ),
                              ),

                              const Text(
                                '80%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Great consistency!',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),

                              SizedBox(height: 7),

                              Text(
                                'You completed 16 of 20 reminders this week.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _reminderStat(
                            Icons.check_circle_rounded,
                            '16',
                            'Completed',
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _reminderStat(
                            Icons.cancel_outlined,
                            '4',
                            'Missed',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // THIS WEEK
              // ------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,

                      children: [
                        _dayProgress('Mon', true),
                        _dayProgress('Tue', true),
                        _dayProgress('Wed', true),
                        _dayProgress('Thu', true),
                        _dayProgress('Fri', false),
                        _dayProgress('Sat', false),
                        _dayProgress('Sun', false),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // ACHIEVEMENT
              // ------------------------------------------------
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
                      Icons.emoji_events_outlined,
                      color: Color(0xFF376B5C),
                      size: 28,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'You completed 12 activities this week. Keep going!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF376B5C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // INTERACTIVE PROGRESS CHART
  // ==========================================================

  Widget _buildProgressChart(List<int> scores, List<String> labels) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) {
            if (scores.isEmpty) return;

            const leftPadding = 30.0;

            final chartWidth = constraints.maxWidth - leftPadding - 10;

            final step = scores.length == 1
                ? chartWidth
                : chartWidth / (scores.length - 1);

            int nearestIndex = ((details.localPosition.dx - leftPadding) / step)
                .round();

            nearestIndex = nearestIndex.clamp(0, scores.length - 1);

            _showScore(labels[nearestIndex], scores[nearestIndex]);
          },

          child: CustomPaint(
            painter: _ProgressChartPainter(scores: scores, labels: labels),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  void _showScore(String label, int score) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${isWeekly ? 'Day' : 'Date'} $label: Cognitive score $score%',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==========================================================
  // WEEK / MONTH BUTTON
  // ==========================================================

  Widget _periodButton(String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        decoration: BoxDecoration(
          color: selected ? const Color(0xFF376B5C) : Colors.transparent,

          borderRadius: BorderRadius.circular(9),
        ),

        child: Text(
          title,

          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,

            color: selected ? Colors.white : const Color(0xFF376B5C),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // COGNITIVE SKILL CARD
  // ==========================================================

  Widget _skillCard(String title, double progress, IconData icon) {
    final percentage = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: const Color(0xFFE4EFEA),
              borderRadius: BorderRadius.circular(15),
            ),

            child: Icon(icon, color: const Color(0xFF376B5C)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),

                const SizedBox(height: 9),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,

                    backgroundColor: const Color(0xFFE5E5E5),

                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF376B5C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '$percentage%',

            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF376B5C),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ACTIVITY PERFORMANCE CARD
  // ==========================================================

  Widget _performanceCard(
    String title,
    String status,
    double progress,
    IconData icon,
    Color iconBackground,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(15),
            ),

            child: Icon(icon, color: const Color(0xFF376B5C)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  status,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 9),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,

                    backgroundColor: const Color(0xFFE5E5E5),

                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF376B5C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '${(progress * 100).round()}%',

            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF376B5C),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // STAT CARD
  // ==========================================================

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: const Color(0xFFE4EFEA),
              borderRadius: BorderRadius.circular(13),
            ),

            child: Icon(icon, color: const Color(0xFF376B5C), size: 24),
          ),

          const SizedBox(height: 14),

          Text(
            value,

            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B35),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,

            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MOOD ITEM
  // ==========================================================

  Widget _moodItem(String day, String emoji, String mood) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),

        const SizedBox(height: 6),

        Text(day, style: const TextStyle(fontSize: 12, color: Colors.grey)),

        const SizedBox(height: 3),

        Text(
          mood,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF376B5C),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // REMINDER STAT
  // ==========================================================

  Widget _reminderStat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F2),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF376B5C), size: 22),

          const SizedBox(width: 9),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                value,

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              Text(
                label,

                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WEEK DAY PROGRESS
  // ==========================================================

  Widget _dayProgress(String day, bool completed) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,

          decoration: BoxDecoration(
            color: completed
                ? const Color(0xFF376B5C)
                : const Color(0xFFE5E5E5),

            shape: BoxShape.circle,
          ),

          child: completed
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : null,
        ),

        const SizedBox(height: 7),

        Text(day, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// ============================================================
// CUSTOM PROGRESS CHART
// ============================================================

class _ProgressChartPainter extends CustomPainter {
  final List<int> scores;
  final List<String> labels;

  _ProgressChartPainter({required this.scores, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) {
      return;
    }

    const leftPadding = 30.0;
    const rightPadding = 10.0;
    const topPadding = 15.0;
    const bottomPadding = 30.0;

    final chartWidth = size.width - leftPadding - rightPadding;

    final chartHeight = size.height - topPadding - bottomPadding;

    final gridPaint = Paint()
      ..color = const Color(0xFFE7ECE9)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF376B5C)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF376B5C)
      ..style = PaintingStyle.fill;

    final pointRingPaint = Paint()
      ..color = const Color(0xFFE4EFEA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const gridValues = [100, 75, 50, 25, 0];

    // ----------------------------------------------------------
    // GRID
    // ----------------------------------------------------------

    for (final value in gridValues) {
      final y = topPadding + chartHeight * (1 - value / 100);

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: '$value',
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      );

      textPainter.layout();

      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    // ----------------------------------------------------------
    // POINTS
    // ----------------------------------------------------------

    final points = <Offset>[];

    for (int i = 0; i < scores.length; i++) {
      final x = scores.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + chartWidth * i / (scores.length - 1);

      final y = topPadding + chartHeight * (1 - scores[i] / 100);

      points.add(Offset(x, y));
    }

    // ----------------------------------------------------------
    // LINE
    // ----------------------------------------------------------

    final path = Path();

    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, linePaint);

    // ----------------------------------------------------------
    // POINTS + LABELS
    // ----------------------------------------------------------

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 8, pointRingPaint);

      canvas.drawCircle(points[i], 5, pointPaint);

      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      );

      textPainter.layout();

      final labelX = points[i].dx - textPainter.width / 2;

      final labelY = size.height - bottomPadding + 8;

      textPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return oldDelegate.scores != scores || oldDelegate.labels != labels;
  }
}
