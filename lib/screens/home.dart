import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'activities.dart';
import 'daily_task_screen.dart';
import 'mood.dart';
import 'notifications.dart';
import 'profile.dart';
import 'progress.dart';
import 'remainders.dart';
import 'voice_assistant.dart';
import '../database/local_database.dart';
import '../main.dart';
import '../services/auth_storage.dart';
import '../services/daily_tasks_api.dart';
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

  @override
  void initState() {
    super.initState();
    TranslationService.instance.addListener(_updateNavLabels);
    _updateNavLabels();
    _initScreenTime();
  }

  Future<void> _initScreenTime() async {
    await ScreenTimeService.instance.init();
    if (!mounted) return;
    ScreenTimeService.instance.startTracking(
      onWarningCallback: _handleScreenTimeWarning,
      onLimitReachedCallback: _handleScreenTimeLimitReached,
    );
  }

  @override
  void dispose() {
    ScreenTimeService.instance.stopTracking();
    TranslationService.instance.removeListener(_updateNavLabels);
    super.dispose();
  }

  void _handleScreenTimeWarning(int minutesRemaining) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(
              Icons.access_time_filled_rounded,
              color: minutesRemaining <= 5 ? Colors.red : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TrText(
                minutesRemaining <= 5
                    ? 'Screen Time Warning (5 Mins)'
                    : 'Screen Time Notice (15 Mins)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: minutesRemaining <= 5 ? Colors.red.shade900 : const Color(0xFF173B35),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationService.instance.getCached(
                minutesRemaining <= 5
                    ? 'You have only 5 minutes of screen time remaining for today. Cognicare will log out automatically at the 1-hour mark to let your mind rest.'
                    : 'You have used 45 minutes of screen time today. You have 15 minutes remaining before the 1-hour healthy limit.',
              ),
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            const TrText(
              'Taking regular breaks helps keep your memory and focus sharp.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF376B5C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const TrText('Understood'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScreenTimeLimitReached() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.bedtime_rounded, color: Color(0xFF376B5C), size: 30),
            SizedBox(width: 10),
            Expanded(
              child: TrText(
                'Daily Screen Time Limit (1 Hour)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TrText(
              'You have completed your maximum allowed 1 hour of screen time for today.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const TrText(
              'Resting your eyes and taking a break from screens is vital for healthy brain recovery and memory retention. You are now logged out for today.',
              style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.35),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE4EFEA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.thumb_up_alt_rounded, color: Color(0xFF376B5C), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: TrText(
                      'Great job exercising your mind today! See you tomorrow.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF376B5C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const TrText('Log Out & Rest'),
          ),
        ],
      ),
    );

    await AuthStorage.clearPatientSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
      (_) => false,
    );
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
          const SizedBox(width: 4),
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
  Map<String, dynamic>? _todayTask;

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
        'Today\'s Daily Task',
        'Start Task',
        'Upload a video',
        'Upload a photo',
        'Record voice note',
        'Task Submitted!',
        'Your today\'s task has been submitted successfully.',
        'View Submission',
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

    // Load today's Daily SPT task
    try {
      final patientId = await AuthStorage.getPatientId();
      if (patientId != null) {
        final task = await DailyTasksApi.getTodayTask(patientId);
        if (mounted) {
          setState(() {
            _todayTask = task;
          });
        }
      }
    } catch (_) {}

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
            // TODAY'S DAILY TASK (DAILY SPT)
            // ------------------------------------------------
            _buildDailyTaskCard(context),

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

  Widget _buildDailyTaskCard(BuildContext context) {
    if (_todayTask == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2EBE6)),
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
              child: const Icon(Icons.assignment_outlined, color: Color(0xFF376B5C), size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrText(
                    'Today\'s Daily Task',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B35),
                    ),
                  ),
                  SizedBox(height: 3),
                  TrText(
                    'Preparing your meaningful daily activity...',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final task = _todayTask!;
    final title = task['title'] ?? 'Today\'s Task';
    final description = task['description'] ?? '';
    final duration = task['estimated_duration'] ?? '5 mins';
    final submissionType = (task['submission_type'] ?? 'PHOTO').toString().toUpperCase();
    final status = (task['status'] ?? 'ASSIGNED').toString().toUpperCase();
    final isSubmitted = status == 'SUBMITTED' || status == 'APPROVED' || status == 'REVIEWED';
    final isApproved = status == 'APPROVED';
    final needsRetry = status == 'NEEDS_RETRY';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isApproved
              ? const Color(0xFF86EFAC)
              : (needsRetry ? const Color(0xFFFED7AA) : const Color(0xFFE2EBE6)),
          width: isApproved || needsRetry ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isApproved
                  ? const Color(0xFFF0FDF4)
                  : (needsRetry
                      ? const Color(0xFFFFF7ED)
                      : (isSubmitted ? const Color(0xFFE4EFEA) : const Color(0xFFF8F7F2))),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isApproved
                          ? Icons.check_circle_rounded
                          : (isSubmitted
                              ? Icons.task_alt_rounded
                              : Icons.assignment_turned_in_rounded),
                      color: isApproved || isSubmitted
                          ? const Color(0xFF376B5C)
                          : const Color(0xFF173B35),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    const TrText(
                      'Today\'s Daily Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFFDCFCE7)
                        : (needsRetry
                            ? const Color(0xFFFFEDD5)
                            : (isSubmitted ? const Color(0xFFCCE3D8) : const Color(0xFFE4EFEA))),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isApproved
                        ? 'Approved'
                        : (needsRetry
                            ? 'Needs Retry'
                            : (isSubmitted ? 'Submitted' : 'Assigned')),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isApproved
                          ? const Color(0xFF15803D)
                          : (needsRetry
                              ? const Color(0xFFC2410C)
                              : const Color(0xFF376B5C)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.35),
                ),
                const SizedBox(height: 14),

                // Info Badges Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4EFEA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF376B5C)),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF376B5C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1E8D8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            submissionType == 'VIDEO'
                                ? Icons.videocam_rounded
                                : (submissionType == 'AUDIO'
                                    ? Icons.mic_rounded
                                    : Icons.photo_camera_rounded),
                            size: 14,
                            color: const Color(0xFF8A642B),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            submissionType == 'VIDEO'
                                ? 'Upload a video'
                                : (submissionType == 'AUDIO'
                                    ? 'Record voice note'
                                    : 'Upload a photo'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8A642B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // If already submitted: show confirmation banner
                if (isSubmitted) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isApproved ? const Color(0xFFF0FDF4) : const Color(0xFFE4EFEA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isApproved ? Icons.verified_rounded : Icons.check_circle_rounded,
                          color: const Color(0xFF376B5C),
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TrText(
                                'Task Submitted!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),
                              TrText(
                                'Your today\'s task has been submitted successfully.',
                                style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _openPage(
                          context,
                          DailyTaskScreen(
                            task: task,
                            onTaskCompleted: _loadData,
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 20),
                      label: const TrText('View Submission'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF376B5C),
                        side: const BorderSide(color: Color(0xFF376B5C)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else ...[
                  // Not submitted yet or needs retry: Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _openPage(
                          context,
                          DailyTaskScreen(
                            task: task,
                            onTaskCompleted: _loadData,
                          ),
                        );
                      },
                      icon: Icon(
                        needsRetry ? Icons.replay_rounded : Icons.play_arrow_rounded,
                        size: 24,
                      ),
                      label: TrText(
                        needsRetry ? 'Try Task Again' : 'Start Task',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: needsRetry
                            ? const Color(0xFFEA580C)
                            : const Color(0xFF376B5C),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
