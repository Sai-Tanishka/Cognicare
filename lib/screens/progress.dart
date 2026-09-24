import 'package:flutter/material.dart';

import '../database/local_database.dart';
import '../services/auth_storage.dart';
import '../services/people_api.dart';
import '../services/progress_events.dart';
import '../services/translation_service.dart';
import '../widgets/language_selector.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  bool isWeekly = true;
  bool isLoading = true;

  double overallProgress = 0.0;
  int activitiesCompleted = 0;
  int activitiesToday = 0;
  int dailyGoalTarget = 10;
  double dailyGoalPercentage = 0.0;
  int totalScore = 0;
  double averageAccuracy = 0.0;
  int averageScore = 0;
  String practiceTime = '0 min';

  double memoryProgress = 0.0;
  double attentionProgress = 0.0;
  double problemSolvingProgress = 0.0;
  double recognitionProgress = 0.0;

  double memoryMatchScore = 0.0;
  String memoryMatchStatus = 'Not played yet';

  double patternRecallScore = 0.0;
  String patternRecallStatus = 'Not played yet';

  double oddOneOutScore = 0.0;
  String oddOneOutStatus = 'Not played yet';

  double numberSequenceScore = 0.0;
  String numberSequenceStatus = 'Not played yet';

  Map<String, bool> weekStatus = {
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
    'Sat': false,
    'Sun': false,
  };

  int remindersCompleted = 0;
  int remindersTotal = 0;
  double reminderPercentage = 0.0;

  Map<String, dynamic>? caregiverInfo;

  List<int> weeklyScores = [0, 0, 0, 0, 0, 0, 0];

  final List<String> weeklyDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  List<int> monthlyScores = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

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
  void initState() {
    super.initState();
    ProgressEvents.instance.addListener(_loadProgress);
    TranslationService.instance.addListener(_onLanguageChange);
    _loadProgress();
  }

  void _onLanguageChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ProgressEvents.instance.removeListener(_loadProgress);
    TranslationService.instance.removeListener(_onLanguageChange);
    super.dispose();
  }

  Future<void> _loadProgress() async {
    try {
      final patientId = await AuthStorage.getPatientId();
      if (patientId != null) {
        final dailyData = await PeopleApi.getPatientDailyProgress(patientId);
        final double op =
            (dailyData['overall_progress'] as num?)?.toDouble() ?? 0.0;
        final int ac =
            (dailyData['total_activities_completed'] as num?)?.toInt() ?? 0;
        final int actsToday =
            (dailyData['activities_completed_today'] as num?)?.toInt() ?? 0;
        final int target =
            (dailyData['daily_goal_target'] as num?)?.toInt() ?? 10;
        final double dp =
            (dailyData['daily_goal_percentage'] as num?)?.toDouble() ?? 0.0;
        final int ts = (dailyData['total_score'] as num?)?.toInt() ?? 0;
        final double acc =
            (dailyData['overall_accuracy'] as num?)?.toDouble() ?? 0.0;

        final rawGames = (dailyData['games_breakdown'] as List?) ?? [];
        final Map<String, Map<String, dynamic>> gamesMap = {};
        for (final item in rawGames) {
          if (item is Map<String, dynamic> && item['name'] != null) {
            gamesMap[item['name'].toString()] = item;
          }
        }

        final rawWeek =
            (dailyData['week_status'] as Map<String, dynamic>?) ?? {};
        final Map<String, bool> parsedWeek = {};
        for (final key in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
          parsedWeek[key] = (rawWeek[key] as bool?) ?? false;
        }

        final rem =
            (dailyData['reminder_adherence'] as Map<String, dynamic>?) ?? {};
        final remComp = (rem['completed'] as num?)?.toInt() ?? 0;
        final remTot = (rem['total'] as num?)?.toInt() ?? 0;
        final remPct = (rem['percentage'] as num?)?.toDouble() ?? 0.0;

        final cg = dailyData['caregiver'] as Map<String, dynamic>?;

        // Memory Match
        final mm = gamesMap['Memory Match'];
        final mmAttempts = (mm?['attempts'] as num?)?.toInt() ?? 0;
        final mmAcc = (mm?['average_accuracy'] as num?)?.toDouble() ?? 0.0;

        // Pattern Recall
        final pr = gamesMap['Pattern Recall'];
        final prAttempts = (pr?['attempts'] as num?)?.toInt() ?? 0;
        final prAcc = (pr?['average_accuracy'] as num?)?.toDouble() ?? 0.0;

        // Odd One Out
        final ooo = gamesMap['Odd One Out'];
        final oooAttempts = (ooo?['attempts'] as num?)?.toInt() ?? 0;
        final oooAcc = (ooo?['average_accuracy'] as num?)?.toDouble() ?? 0.0;

        // Number Sequence
        final ns = gamesMap['Number Sequence'];
        final nsAttempts = (ns?['attempts'] as num?)?.toInt() ?? 0;
        final nsAcc = (ns?['average_accuracy'] as num?)?.toDouble() ?? 0.0;

        List<Map<String, dynamic>> attempts = [];
        try {
          attempts = await LocalDatabase.getAllGameAttempts();
        } catch (_) {}

        if (mounted) {
          setState(() {
            overallProgress = op / 100.0;
            activitiesCompleted = ac;
            activitiesToday = actsToday;
            dailyGoalTarget = target;
            dailyGoalPercentage = dp;
            totalScore = ts;
            averageAccuracy = acc;
            averageScore = ac > 0 ? (ts / ac).round() : 0;
            practiceTime = '${ac * 3} min';

            // Real game performance (0% and 'Not played yet' if not played)
            memoryMatchScore =
                mmAttempts > 0 ? (mmAcc / 100.0).clamp(0.0, 1.0) : 0.0;
            memoryMatchStatus = mmAttempts > 0
                ? '$mmAttempts ${mmAttempts == 1 ? 'attempt' : 'attempts'}'
                : 'Not played yet';

            patternRecallScore =
                prAttempts > 0 ? (prAcc / 100.0).clamp(0.0, 1.0) : 0.0;
            patternRecallStatus = prAttempts > 0
                ? '$prAttempts ${prAttempts == 1 ? 'attempt' : 'attempts'}'
                : 'Not played yet';

            oddOneOutScore =
                oooAttempts > 0 ? (oooAcc / 100.0).clamp(0.0, 1.0) : 0.0;
            oddOneOutStatus = oooAttempts > 0
                ? '$oooAttempts ${oooAttempts == 1 ? 'attempt' : 'attempts'}'
                : 'Not played yet';

            numberSequenceScore =
                nsAttempts > 0 ? (nsAcc / 100.0).clamp(0.0, 1.0) : 0.0;
            numberSequenceStatus = nsAttempts > 0
                ? '$nsAttempts ${nsAttempts == 1 ? 'attempt' : 'attempts'}'
                : 'Not played yet';

            // Real Cognitive Skills (0% if none played)
            int memCount = 0;
            double memSum = 0;
            if (mmAttempts > 0) {
              memSum += mmAcc;
              memCount++;
            }
            if (prAttempts > 0) {
              memSum += prAcc;
              memCount++;
            }
            memoryProgress =
                memCount > 0 ? (memSum / memCount / 100.0).clamp(0.0, 1.0) : 0.0;

            attentionProgress =
                oooAttempts > 0 ? (oooAcc / 100.0).clamp(0.0, 1.0) : 0.0;

            problemSolvingProgress =
                nsAttempts > 0 ? (nsAcc / 100.0).clamp(0.0, 1.0) : 0.0;

            int recCount = 0;
            double recSum = 0;
            if (oooAttempts > 0) {
              recSum += oooAcc;
              recCount++;
            }
            if (prAttempts > 0) {
              recSum += prAcc;
              recCount++;
            }
            recognitionProgress =
                recCount > 0 ? (recSum / recCount / 100.0).clamp(0.0, 1.0) : 0.0;

            weekStatus = parsedWeek;
            remindersCompleted = remComp;
            remindersTotal = remTot;
            reminderPercentage = remPct;
            caregiverInfo = cg;

            if (attempts.isNotEmpty) {
              final recent = attempts
                  .take(7)
                  .map((e) {
                    final accVal = (e['accuracy'] as num?)?.toDouble() ?? 0.0;
                    return accVal.round().clamp(0, 100);
                  })
                  .toList();
              while (recent.length < 7) {
                recent.insert(0, 0);
              }
              weeklyScores = recent;
            } else if (ac > 0) {
              final dayKeys = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              weeklyScores = dayKeys.map((d) {
                return (parsedWeek[d] == true) ? acc.round().clamp(0, 100) : 0;
              }).toList();
            } else {
              weeklyScores = [0, 0, 0, 0, 0, 0, 0];
            }
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tService = TranslationService.instance;
    final scores = isWeekly ? weeklyScores : monthlyScores;
    final labels = isWeekly
        ? weeklyDays.map((d) => tService.getCached(d)).toList()
        : monthlyDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        title: const TrText(
          'My Progress',
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
              // ------------------------------------------------
              // HEADER
              // ------------------------------------------------

              const TrText(
                'Your Progress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 8),

              const TrText(
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
                    const TrText(
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
                              value: overallProgress.clamp(0.0, 1.0),
                              strokeWidth: 12,
                              backgroundColor: Colors.white,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF376B5C),
                              ),
                            ),
                          ),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(overallProgress * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),
                              TrText(
                                activitiesCompleted == 0
                                    ? 'Starting Out'
                                    : 'Overall',
                                style: const TextStyle(
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          activitiesCompleted > 0
                              ? Icons.trending_up_rounded
                              : Icons.info_outline_rounded,
                          color: const Color(0xFF376B5C),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        TrText(
                          activitiesCompleted > 0
                              ? '$activitiesCompleted activities completed'
                              : 'No activities completed yet',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF376B5C),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const TrText(
                                "Today's Daily Goal",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),
                              Text(
                                '${dailyGoalPercentage.round()}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF376B5C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (dailyGoalPercentage / 100.0).clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE5E5E5),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF376B5C),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TrText(
                            '$activitiesToday of $dailyGoalTarget activities completed today',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (caregiverInfo != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E8E0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.health_and_safety_rounded,
                              size: 18,
                              color: Color(0xFF376B5C),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TrText(
                                'Caregiver: ${caregiverInfo!['name']} (${caregiverInfo!['email'] ?? 'Connected'})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF173B35),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // COGNITIVE SKILLS
              // ------------------------------------------------
              const TrText(
                'Cognitive Skills',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 14),

              _skillCard('Memory', memoryProgress, Icons.psychology_rounded),

              const SizedBox(height: 12),

              _skillCard(
                'Attention',
                attentionProgress,
                Icons.center_focus_strong_rounded,
              ),

              const SizedBox(height: 12),

              _skillCard(
                'Problem Solving',
                problemSolvingProgress,
                Icons.lightbulb_outline_rounded,
              ),

              const SizedBox(height: 12),

              _skillCard(
                'Recognition',
                recognitionProgress,
                Icons.visibility_rounded,
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // PROGRESS TREND
              // ------------------------------------------------
              const TrText(
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
                              TrText(
                                'Cognitive Performance',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),

                              SizedBox(height: 4),

                              TrText(
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

                        TrText(
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
              const TrText(
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
                memoryMatchStatus,
                memoryMatchScore,
                Icons.psychology_rounded,
                const Color(0xFFE4EFEA),
              ),

              const SizedBox(height: 12),

              _performanceCard(
                'Pattern Recall',
                patternRecallStatus,
                patternRecallScore,
                Icons.grid_view_rounded,
                const Color(0xFFE8E4F1),
              ),

              const SizedBox(height: 12),

              _performanceCard(
                'Odd One Out',
                oddOneOutStatus,
                oddOneOutScore,
                Icons.visibility_rounded,
                const Color(0xFFF1E8D8),
              ),

              const SizedBox(height: 12),

              _performanceCard(
                'Number Sequence',
                numberSequenceStatus,
                numberSequenceScore,
                Icons.pin_rounded,
                const Color(0xFFE5E9F0),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // ACTIVITY STATISTICS
              // ------------------------------------------------
              const TrText(
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
                      '$activitiesCompleted',
                      'Activities Completed',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      Icons.track_changes_rounded,
                      '${averageAccuracy.round()}%',
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
                      '$averageScore',
                      'Average Score',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      Icons.timer_outlined,
                      practiceTime,
                      'Practice Time',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // MOOD TREND
              // ------------------------------------------------
              const TrText(
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
                    const TrText(
                      'How you have been feeling',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
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
                            child: TrText(
                              'Mood entries will appear here as you log daily feelings and reflections.',
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
              const TrText(
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
                                  value: remindersTotal > 0
                                      ? (reminderPercentage / 100.0).clamp(0.0, 1.0)
                                      : 0.0,
                                  strokeWidth: 9,
                                  backgroundColor: const Color(0xFFE5E5E5),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF376B5C),
                                  ),
                                ),
                              ),
                              Text(
                                '${reminderPercentage.round()}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TrText(
                                remindersTotal > 0 ? 'Reminder Adherence' : 'No Reminders Today',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),
                              const SizedBox(height: 7),
                              TrText(
                                remindersTotal > 0
                                    ? 'You completed $remindersCompleted of $remindersTotal reminders today.'
                                    : 'No reminders have been scheduled for today.',
                                style: const TextStyle(
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
                            '$remindersCompleted',
                            'Completed',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _reminderStat(
                            Icons.cancel_outlined,
                            '${(remindersTotal - remindersCompleted).clamp(0, 999)}',
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
                    const TrText(
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
                        _dayProgress('Mon', weekStatus['Mon'] ?? false),
                        _dayProgress('Tue', weekStatus['Tue'] ?? false),
                        _dayProgress('Wed', weekStatus['Wed'] ?? false),
                        _dayProgress('Thu', weekStatus['Thu'] ?? false),
                        _dayProgress('Fri', weekStatus['Fri'] ?? false),
                        _dayProgress('Sat', weekStatus['Sat'] ?? false),
                        _dayProgress('Sun', weekStatus['Sun'] ?? false),
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
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_outlined,
                      color: Color(0xFF376B5C),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TrText(
                        activitiesCompleted > 0
                            ? 'You completed $activitiesCompleted ${activitiesCompleted == 1 ? 'activity' : 'activities'} so far. Keep going!'
                            : 'Start your first activity to begin tracking your achievements!',
                        style: const TextStyle(
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

        child: TrText(
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
                TrText(
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
                TrText(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),

                const SizedBox(height: 5),

                TrText(
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

          TrText(
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

              TrText(
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

        TrText(day, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

      final clamped = scores[i].clamp(0, 100);
      final y = (topPadding + chartHeight * (1.0 - clamped / 100.0))
          .clamp(topPadding, topPadding + chartHeight);

      points.add(Offset(x, y));
    }

    // ----------------------------------------------------------
    // LINE (clipped to chart area)
    // ----------------------------------------------------------

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

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

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return oldDelegate.scores != scores || oldDelegate.labels != labels;
  }
}
