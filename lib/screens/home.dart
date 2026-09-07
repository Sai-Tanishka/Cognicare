import 'package:flutter/material.dart';

import 'activities.dart';
import 'mood.dart';
import 'notifications.dart';
import 'profile.dart';
import 'progress.dart';
import 'remainders.dart';
import 'voice_assistant.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeContent(),
    ActivitiesPage(),
    ProgressPage(),
    ProfilePage(),
  ];

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        title: const Text(
          'Cognicare',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openNotifications,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF173B35),
              size: 28,
            ),
          ),
        ],
      ),

      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF376B5C),
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_rounded),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME CONTENT
// ============================================================

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // GREETING
            // ------------------------------------------------

            const Text(
              'Good Morning!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B35),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Let’s take care of your mind today.',
              style: TextStyle(fontSize: 17, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // ------------------------------------------------
            // PATIENT CARD
            // ------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE4EFEA),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 38,
                      color: Color(0xFF376B5C),
                    ),
                  ),

                  const SizedBox(width: 16),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Patient',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173B35),
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Ready for today?',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ------------------------------------------------
            // TODAY'S PROGRESS
            // ------------------------------------------------
            const Text(
              'Today’s Progress',
              style: TextStyle(
                fontSize: 22,
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
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Daily Goal',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        '40%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF376B5C),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: const LinearProgressIndicator(
                      value: 0.4,
                      minHeight: 12,
                      backgroundColor: Color(0xFFE5E5E5),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF376B5C),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Keep going! You are doing well.',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ------------------------------------------------
            // ACTIONS
            // ------------------------------------------------
            const Text(
              'What would you like to do?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B35),
              ),
            ),

            const SizedBox(height: 14),

            // GAMES
            _buildActionCard(
              context,
              icon: Icons.psychology_rounded,
              title: 'Games',
              subtitle: 'Train your memory',
              color: const Color(0xFFE4EFEA),
              onTap: () {
                _openPage(context, const ActivitiesPage());
              },
            ),

            const SizedBox(height: 14),

            // REMINDERS
            _buildActionCard(
              context,
              icon: Icons.alarm_rounded,
              title: 'Reminders',
              subtitle: 'Check your reminders',
              color: const Color(0xFFF1E8D8),
              onTap: () {
                _openPage(context, const RemindersPage());
              },
            ),

            const SizedBox(height: 14),

            // MOOD
            _buildActionCard(
              context,
              icon: Icons.sentiment_satisfied_alt_rounded,
              title: 'How are you feeling?',
              subtitle: 'Track your mood',
              color: const Color(0xFFE8E4F1),
              onTap: () {
                _openPage(context, const MoodPage());
              },
            ),

            const SizedBox(height: 14),

            // VOICE ASSISTANT
            _buildActionCard(
              context,
              icon: Icons.mic_rounded,
              title: 'Voice Assistant',
              subtitle: 'Talk to Cognicare',
              color: const Color(0xFFE5E9F0),
              onTap: () {
                _openPage(context, const VoiceAssistantPage());
              },
            ),

            const SizedBox(height: 22),

            // ------------------------------------------------
            // SUPPORT CARD
            // ------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE4EFEA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFF376B5C),
                    size: 25,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Take your time. Small steps every day can make a difference.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF173B35),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
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
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(icon, size: 31, color: const Color(0xFF376B5C)),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B35),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Color(0xFF376B5C),
            ),
          ],
        ),
      ),
    );
  }
}
