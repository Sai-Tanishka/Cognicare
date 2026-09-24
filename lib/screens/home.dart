import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'activities.dart';
import 'mood.dart';
import 'notifications.dart';
import 'profile.dart';
import 'progress.dart';
import 'remainders.dart';
import 'voice_assistant.dart';
import '../database/local_database.dart';
import '../main.dart';
import '../services/auth_storage.dart';
import '../services/people_api.dart';
import '../services/progress_events.dart';
import '../services/screen_time_service.dart';
import '../services/translation_service.dart';
import '../widgets/language_selector.dart';
import '../widgets/screen_time_indicator.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _currentIndex = 0;
  String _homeLabel = 'Home';
  String _gamesLabel = 'Games';
  String _progressLabel = 'Progress';
  String _profileLabel = 'Profile';

  final List<Widget> _pages = const [
    _HomeContent(),
    ActivitiesPage(),
    ProgressPage(),
    ProfilePage(),
  ];

  bool _isLimitDialogShowing = false;

  @override
  void initState() {
    super.initState();
    TranslationService.instance.addListener(_updateNavLabels);
    _updateNavLabels();
    _initScreenTime();
  }

  void _initScreenTime() {
    final screenTime = ScreenTimeService.instance;
    screenTime.init().then((_) {
      if (mounted) {
        if (screenTime.isLimitReached) {
          _handleScreenTimeLimitReached();
        } else {
          screenTime.onWarning = _handleScreenTimeWarning;
          screenTime.onLimitReached = _handleScreenTimeLimitReached;
          screenTime.startTracking();
        }
      }
    });
  }

  void _handleScreenTimeWarning(int minutesRemaining) {
    if (!mounted) return;
    final is15 = minutesRemaining == 15;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              is15 ? Icons.access_time_rounded : Icons.warning_amber_rounded,
              color: is15 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444),
            ),
            const SizedBox(width: 8),
            Text(
              is15 ? '15 Minutes Remaining' : '5 Minutes Remaining',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          is15
              ? "You have used 45 minutes of screen time today. You have 15 minutes left before your 1-hour healthy limit.\n\nPlease wrap up your current game or activity soon."
              : "Attention: You have 5 minutes of screen time left.\n\nCognicare will automatically log you out when the 1-hour limit is reached for your cognitive rest.",
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF376B5C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScreenTimeLimitReached() async {
    if (!mounted || _isLimitDialogShowing) return;
    _isLimitDialogShowing = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.bedtime_rounded, color: Color(0xFF376B5C), size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Daily Screen Time Completed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF376B5C).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.spa_rounded, color: Color(0xFF376B5C), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '1 Hour Maximum Limit Reached',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173B35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'You have reached your 1-hour healthy screen time limit for today. Taking regular rest periods is essential to protect your memory, reduce eye strain, and keep your mind fresh.',
                style: TextStyle(fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 10),
              const Text(
                'You are being safely logged out now. Please return tomorrow for your brain exercises!',
                style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                await AuthStorage.clearPatientSession();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF376B5C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Rest Now & Log Out'),
            ),
          ],
        ),
      ),
    );

    await AuthStorage.clearPatientSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    ScreenTimeService.instance.stopTracking();
    ScreenTimeService.instance.onWarning = null;
    ScreenTimeService.instance.onLimitReached = null;
    TranslationService.instance.removeListener(_updateNavLabels);
    super.dispose();
  }

  Future<void> _updateNavLabels() async {
    final t = TranslationService.instance;
    final lang = t.currentLanguage.code;
    if (lang == 'en') {
      if (mounted) {
        setState(() {
          _homeLabel = 'Home';
          _gamesLabel = 'Games';
          _progressLabel = 'Progress';
          _profileLabel = 'Profile';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _homeLabel = t.getCached('Home');
        _gamesLabel = t.getCached('Games');
        _progressLabel = t.getCached('Progress');
        _profileLabel = t.getCached('Profile');
      });
    }

    try {
      final results = await Future.wait([
        t.translate('Home', targetLang: lang),
        t.translate('Games', targetLang: lang),
        t.translate('Progress', targetLang: lang),
        t.translate('Profile', targetLang: lang),
      ]);
      if (mounted) {
        setState(() {
          _homeLabel = results[0];
          _gamesLabel = results[1];
          _progressLabel = results[2];
          _profileLabel = results[3];
        });
      }
    } catch (_) {}
  }

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
    // Ensure the active tab gets the latest progress data immediately
    ProgressEvents.instance.notifyGameCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.psychology_rounded, color: Color(0xFF376B5C), size: 28),
            SizedBox(width: 8),
            Text(
              'Cognicare',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B35),
              ),
            ),
          ],
        ),
        actions: [
          const ScreenTimeBadge(),
          const LanguageSelectorButton(),
          IconButton(
            onPressed: _openNotifications,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF173B35),
              size: 26,
            ),
          ),
          const SizedBox(width: 6),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: _homeLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.psychology_rounded),
            label: _gamesLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_rounded),
            label: _progressLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: _profileLabel,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME CONTENT
// ============================================================

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String patientName = 'Patient';
  double todayProgress = 0.0;
  int activitiesCompletedToday = 0;
  int dailyGoalTarget = 10;

  @override
  void initState() {
    super.initState();
    ProgressEvents.instance.addListener(_loadData);
    _loadData();
    _prefetchHomeTranslations();
  }

  void _prefetchHomeTranslations() {
    final t = TranslationService.instance;
    final lang = t.currentLanguage.code;
    if (lang != 'en') {
      t.translateList([
        'Home',
        'Games',
        'Progress',
        'Profile',
        'Good Morning!',
        'Let’s take care of your mind today.',
        'Ready for today?',
        'Today’s Progress',
        'Daily Goal',
        'activities completed',
        'What would you like to do?',
        'Train your memory',
        'Reminders',
        'Check your reminders',
        'How are you feeling?',
        'Track your mood',
        'Voice Assistant',
        'Talk to Cognicare',
      ], targetLang: lang);
    }
  }

  @override
  void dispose() {
    ProgressEvents.instance.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final profile = await AuthStorage.getPatientProfile();
    if (profile != null && profile['name'] != null) {
      if (mounted) {
        setState(() {
          patientName = profile['name'] as String;
        });
      }
    }

    int localCompletedToday = 0;
    try {
      final attempts = await LocalDatabase.getAllGameAttempts();
      final today = DateTime.now();
      localCompletedToday = attempts.where((attempt) {
        final value = attempt['completed_at'] as String?;
        final date = value == null ? null : DateTime.tryParse(value);
        return date != null &&
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
      }).length;
    } catch (_) {}

    try {
      final patientId = await AuthStorage.getPatientId();
      if (patientId != null) {
        final daily = await PeopleApi.getPatientDailyProgress(patientId);
        final dp = (daily['daily_goal_percentage'] as num?)?.toDouble() ?? 0.0;
        final acts = (daily['activities_completed_today'] as num?)?.toInt() ?? 0;
        final target = (daily['daily_goal_target'] as num?)?.toInt() ?? 10;

        final finalActs = math.max(acts, localCompletedToday);
        final calcPct = math.min(100.0, (finalActs / target) * 100.0);
        final finalProgress = math.max(dp, calcPct);

        if (mounted) {
          setState(() {
            todayProgress = finalProgress;
            activitiesCompletedToday = finalActs;
            dailyGoalTarget = target;
          });
        }
      } else if (localCompletedToday > 0 && mounted) {
        final target = dailyGoalTarget > 0 ? dailyGoalTarget : 10;
        final calcPct = math.min(100.0, (localCompletedToday / target) * 100.0);
        setState(() {
          todayProgress = calcPct;
          activitiesCompletedToday = localCompletedToday;
        });
      }
    } catch (_) {
      if (localCompletedToday > 0 && mounted) {
        final target = dailyGoalTarget > 0 ? dailyGoalTarget : 10;
        final calcPct = math.min(100.0, (localCompletedToday / target) * 100.0);
        setState(() {
          todayProgress = calcPct;
          activitiesCompletedToday = localCompletedToday;
        });
      }
    }
  }

  void _openPage(BuildContext context, Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    if (mounted) {
      _loadData();
    }
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

            const TrText(
              'Good Morning!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B35),
              ),
            ),

            const SizedBox(height: 6),

            const TrText(
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

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $patientName',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173B35),
                          ),
                        ),

                        const SizedBox(height: 5),

                        const TrText(
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
            const TrText(
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
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TrText(
                            'Daily Goal',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '$activitiesCompletedToday of $dailyGoalTarget ',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const TrText(
                                'activities completed',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Text(
                        '${todayProgress.round()}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF376B5C),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: LinearProgressIndicator(
                      value: (todayProgress / 100.0).clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: const Color(0xFFE5E5E5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF376B5C),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TrText(
                    activitiesCompletedToday == 0
                        ? 'Start your first activity today!'
                        : (activitiesCompletedToday >= dailyGoalTarget
                            ? 'Daily goal completed! Excellent work.'
                            : 'Keep going! $activitiesCompletedToday of $dailyGoalTarget completed.'),
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ------------------------------------------------
            // ACTIONS
            // ------------------------------------------------
            const TrText(
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
                    child: TrText(
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
                  TrText(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B35),
                    ),
                  ),

                  const SizedBox(height: 4),

                  TrText(
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
