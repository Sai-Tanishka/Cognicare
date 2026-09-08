import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openCaregiverDashboard() {
  final host = defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : '127.0.0.1';

  return launchUrl(
    Uri.parse('http://$host:8081'),
    mode: LaunchMode.externalApplication,
  );
}