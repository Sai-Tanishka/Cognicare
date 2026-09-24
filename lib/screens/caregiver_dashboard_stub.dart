import 'package:flutter/material.dart';

/// The caregiver dashboard is a web application and is embedded only when
/// Cognicare is running in a browser.
class CaregiverDashboardPage extends StatelessWidget {
  const CaregiverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('The caregiver dashboard is available in Cognicare Web.'),
      ),
    );
  }
}
