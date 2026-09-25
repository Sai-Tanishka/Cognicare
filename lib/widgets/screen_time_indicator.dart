import 'package:flutter/material.dart';
import '../services/screen_time_service.dart';
import '../services/translation_service.dart';
import 'language_selector.dart';

class ScreenTimeBadge extends StatelessWidget {
  const ScreenTimeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ScreenTimeService.instance,
      builder: (context, _) {
        final service = ScreenTimeService.instance;
        final usedMin = (service.elapsedSeconds / 60).floor();
        final progress = service.progressFraction;

        Color badgeColor;
        Color textColor;
        if (progress >= 0.9) {
          badgeColor = const Color(0xFFFDE8E8);
          textColor = const Color(0xFFC53030);
        } else if (progress >= 0.75) {
          badgeColor = const Color(0xFFFEF3C7);
          textColor = const Color(0xFFB45309);
        } else {
          badgeColor = const Color(0xFFE4EFEA);
          textColor = const Color(0xFF376B5C);
        }

        return InkWell(
          onTap: () => _showScreenTimeDetails(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: textColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: textColor),
                const SizedBox(width: 5),
                Text(
                  '${usedMin}m/60m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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

  void _showScreenTimeDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return AnimatedBuilder(
          animation: ScreenTimeService.instance,
          builder: (ctx, _) {
            final service = ScreenTimeService.instance;
            final usedMin = (service.elapsedSeconds / 60).floor();
            final remainingMin = service.remainingMinutes;
            final progress = service.progressFraction;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4EFEA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.hourglass_bottom_rounded,
                          color: Color(0xFF376B5C),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TrText(
                              'Daily Screen Time Limit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173B35),
                              ),
                            ),
                            SizedBox(height: 2),
                            TrText(
                              'Healthy 1-Hour Maximum per Day',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TrText(
                            'Time Used Today',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$usedMin / 60 mins',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173B35),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const TrText(
                            'Time Remaining',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$remainingMin mins',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: remainingMin <= 5
                                  ? Colors.red
                                  : (remainingMin <= 15 ? Colors.orange : const Color(0xFF376B5C)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 0.9
                            ? Colors.red
                            : (progress >= 0.75 ? Colors.orange : const Color(0xFF376B5C)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2EBE6)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.health_and_safety_outlined,
                            size: 20, color: Color(0xFF376B5C)),
                        SizedBox(width: 10),
                        Expanded(
                          child: TrText(
                            'Limiting screen exposure to 1 hour daily protects your cognitive wellness, memory consolidation, and ocular health.',
                            style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          await service.resetToday();
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  TranslationService.instance.getCached(
                                    'Screen time has been reset for testing.',
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.restart_alt_rounded, size: 16),
                        label: const TrText('Reset Time', style: TextStyle(fontSize: 12)),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await service.addMinutesForTesting(10);
                        },
                        icon: const Icon(Icons.fast_forward_rounded, size: 16),
                        label: const TrText('+10 mins', style: TextStyle(fontSize: 12)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF376B5C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const TrText('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

