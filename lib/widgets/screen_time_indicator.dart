import 'package:flutter/material.dart';
import '../services/screen_time_service.dart';
import 'language_selector.dart';

/// ScreenTimeBadge is an AppBar action badge that displays real-time screen time usage
/// and lets patients or caregivers inspect daily progress and test the alerts.
class ScreenTimeBadge extends StatelessWidget {
  const ScreenTimeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ScreenTimeService.instance,
      builder: (context, _) {
        final service = ScreenTimeService.instance;
        final mins = service.secondsToday ~/ 60;

        Color bgColor;
        Color borderColor;
        Color textColor;
        IconData iconData;

        if (mins >= 55) {
          bgColor = const Color(0xFFFEE2E2);
          borderColor = const Color(0xFFEF4444);
          textColor = const Color(0xFFB91C1C);
          iconData = Icons.hourglass_bottom_rounded;
        } else if (mins >= 45) {
          bgColor = const Color(0xFFFEF3C7);
          borderColor = const Color(0xFFF59E0B);
          textColor = const Color(0xFFB45309);
          iconData = Icons.hourglass_top_rounded;
        } else {
          bgColor = const Color(0xFFE8F3EE);
          borderColor = const Color(0xFF376B5C).withValues(alpha: 0.3);
          textColor = const Color(0xFF173B35);
          iconData = Icons.timer_outlined;
        }

        return InkWell(
          onTap: () => _showScreenTimeSheet(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, size: 16, color: textColor),
                const SizedBox(width: 5),
                Text(
                  '${mins}m/60m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showScreenTimeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return AnimatedBuilder(
          animation: ScreenTimeService.instance,
          builder: (context, _) {
            final service = ScreenTimeService.instance;
            final mins = service.secondsToday ~/ 60;
            final remainingMins = (ScreenTimeService.maxDailySeconds - service.secondsToday) ~/ 60;
            final progress = service.progress;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF376B5C).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.timer_rounded,
                            color: Color(0xFF376B5C),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TrText(
                                'Daily Screen Time',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                remainingMins > 0
                                    ? '$remainingMins minutes remaining today'
                                    : '1-hour limit reached',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: remainingMins > 5 ? Colors.grey.shade700 : Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF376B5C).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF376B5C),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 0.91
                              ? const Color(0xFFEF4444)
                              : progress >= 0.75
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF376B5C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$mins mins used',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const Text(
                          '60 mins maximum',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF173B35)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.spa_rounded, color: Color(0xFF376B5C), size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: TrText(
                              'Screen time is capped at 1 hour daily to prevent mental fatigue, protect memory, and ensure restful cognitive recovery.',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF24463E), height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Test controls for judges / demonstration
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Demo / Testing Tools:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    service.addMinutesForTesting(10);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    side: BorderSide(color: Colors.blueGrey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('+10 Mins', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    service.addMinutesForTesting(30);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    side: BorderSide(color: Colors.blueGrey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('+30 Mins', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    service.resetToday();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  child: const Text('Reset', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
