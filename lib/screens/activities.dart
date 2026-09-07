import 'package:flutter/material.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  void _showGameMessage(BuildContext context, String gameName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$gameName selected'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        title: const Text(
          'Activities',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Train Your Mind',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose an activity and give your brain a workout.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                  children: [
                    // MEMORY MATCH
                    _activityCard(
                      context,
                      Icons.psychology_rounded,
                      'Memory Match',
                      'Match the pairs',
                      const Color(0xFFE4EFEA),
                      () {
                        _showGameMessage(context, 'Memory Match');
                      },
                    ),

                    // PATTERN RECALL
                    _activityCard(
                      context,
                      Icons.grid_view_rounded,
                      'Pattern Recall',
                      'Remember the pattern',
                      const Color(0xFFE8E4F1),
                      () {
                        _showGameMessage(context, 'Pattern Recall');
                      },
                    ),

                    // ODD ONE OUT
                    _activityCard(
                      context,
                      Icons.visibility_rounded,
                      'Odd One Out',
                      'Find what\'s different',
                      const Color(0xFFF1E8D8),
                      () {
                        _showGameMessage(context, 'Odd One Out');
                      },
                    ),

                    // NUMBER SEQUENCE
                    _activityCard(
                      context,
                      Icons.pin_rounded,
                      'Number Sequence',
                      'Recall the order',
                      const Color(0xFFE5E9F0),
                      () {
                        _showGameMessage(context, 'Number Sequence');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconBackground,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 35, color: const Color(0xFF376B5C)),
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B35),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 22,
                color: Color(0xFF376B5C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
