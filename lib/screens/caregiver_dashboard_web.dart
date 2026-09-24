import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Hosts the existing Expo caregiver app inside the current Flutter browser
/// tab. The Expo server must be running on port 8081.
class CaregiverDashboardPage extends StatefulWidget {
  const CaregiverDashboardPage({super.key});

  @override
  State<CaregiverDashboardPage> createState() => _CaregiverDashboardPageState();
}

class _CaregiverDashboardPageState extends State<CaregiverDashboardPage> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'caregiver-dashboard-${DateTime.now().microsecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      final frame = web.HTMLIFrameElement()
        ..src = 'http://127.0.0.1:8081'
        ..title = 'Cognicare caregiver dashboard';
      frame.style
        ..border = '0'
        ..width = '100%'
        ..height = '100%';
      return frame;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: HtmlElementView(viewType: _viewType),
    );
  }
}
