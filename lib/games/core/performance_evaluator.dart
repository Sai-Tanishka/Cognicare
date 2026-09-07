/// Calculates a normalized performance score from 0 to 100.
///
/// Performance is based primarily on accuracy, while response time
/// and assistance also contribute to the overall score.
class PerformanceEvaluator {
  static double calculatePerformance({
    required double accuracy,
    required double averageResponseTime,
    required int hintsUsed,
    required int retries,
  }) {
    // Accuracy is the primary indicator of performance.
    final accuracyScore = accuracy.clamp(0, 100) * 0.70;

    // Response time contributes 20%.
    final responseTimeScore =
        _calculateResponseTimeScore(averageResponseTime) * 0.20;

    // Hints and retries contribute 10%.
    final assistanceScore =
        _calculateAssistanceScore(hintsUsed, retries) * 0.10;

    final performance =
        accuracyScore + responseTimeScore + assistanceScore;

    return performance.clamp(0, 100).toDouble();
  }

  /// Converts average response time into a score from 0 to 100.
  ///
  /// The response-time contribution is intentionally limited so that
  /// slower responses do not overpower good accuracy.
  static double _calculateResponseTimeScore(
    double averageResponseTime,
  ) {
    if (averageResponseTime <= 0) {
      return 100;
    }

    if (averageResponseTime <= 3) {
      return 100;
    }

    if (averageResponseTime <= 5) {
      return 85;
    }

    if (averageResponseTime <= 7) {
      return 70;
    }

    if (averageResponseTime <= 9) {
      return 55;
    }

    if (averageResponseTime <= 12) {
      return 40;
    }

    return 25;
  }

  /// Calculates the assistance score.
  ///
  /// Fewer hints and retries result in a higher score.
  static double _calculateAssistanceScore(
    int hintsUsed,
    int retries,
  ) {
    final assistanceCount = hintsUsed + retries;

    if (assistanceCount == 0) {
      return 100;
    }

    if (assistanceCount == 1) {
      return 80;
    }

    if (assistanceCount == 2) {
      return 60;
    }

    if (assistanceCount == 3) {
      return 40;
    }

    if (assistanceCount == 4) {
      return 20;
    }

    return 10;
  }
}