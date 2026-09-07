import 'package:flutter/material.dart';

import '../games/memory_match/memory_match_screen.dart';
import '../games/pattern_recall/pattern_recall_screen.dart';
import '../games/odd_one_out/odd_one_out_screen.dart';
import '../games/number_sequence/number_sequence_screen.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  static const List<Map<String, dynamic>> games = [
    {
      'title': 'Memory Match',
      'description': 'Match the cards and test your memory.',
      'icon': Icons.grid_view_rounded,
      'difficulty': 'Easy',
      'progress': 75,
      'status': 'Good Progress',
    },
    {
      'title': 'Pattern Recall',
      'description': 'Remember the pattern and find it again.',
      'icon': Icons.pattern_rounded,
      'difficulty': 'Medium',
      'progress': 60,
      'status': 'Improving',
    },
    {
      'title': 'Number Sequence',
      'description': 'Find the missing number in the sequence.',
      'icon': Icons.format_list_numbered_rounded,
      'difficulty': 'Medium',
      'progress': 45,
      'status': 'Keep Practicing',
    },
    {
      'title': 'Odd One Out',
      'description': 'Find the item that is different.',
      'icon': Icons.visibility_outlined,
      'difficulty': 'Easy',
      'progress': 80,
      'status': 'Good Progress',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF173B35)),
        ),
        title: const Text(
          'Games',
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
              const Text(
                "Let's Play!",
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Choose a game and give your brain a little workout.',
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
              ),

              const SizedBox(height: 24),

              _buildTodayProgress(),

              const SizedBox(height: 28),

              const Text(
                'Choose a Game',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 14),

              ...games.map(
                (game) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildGameCard(context, game),
                ),
              ),

              const SizedBox(height: 5),

              _buildInfoCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayProgress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EFEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF376B5C),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '3 games completed today',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Text(
            '3 / 5',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF376B5C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    final int progress = game['progress'] as int;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  game['icon'] as IconData,
                  color: const Color(0xFF376B5C),
                  size: 29,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game['title'] as String,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      game['description'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EFEA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            game['difficulty'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF376B5C),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          game['status'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Text(
                'Progress',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE8EDEB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF376B5C),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                '$progress%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF376B5C),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () {
                final gameTitle = game['title'] as String;

                Widget? gameScreen;

                switch (gameTitle) {
                  case 'Memory Match':
                    gameScreen = const MemoryMatchScreen();
                    break;

                  case 'Pattern Recall':
                    gameScreen = const PatternRecallScreen();
                    break;

                  case 'Odd One Out':
                    gameScreen = const OddOneOutScreen();
                    break;

                  case 'Number Sequence':
                    gameScreen = const NumberSequenceScreen();
                    break;
                }

                if (gameScreen != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => gameScreen!,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 21),
              label: const Text(
                'Start Game',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF376B5C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE7E2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF376B5C),
            size: 25,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'Playing regularly can help you stay engaged and practice different cognitive skills.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF173B35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
