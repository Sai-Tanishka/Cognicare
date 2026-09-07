import 'package:flutter/material.dart';

import 'screens/login.dart';

void main() {
  runApp(const CognicareApp());
}

class CognicareApp extends StatelessWidget {
  const CognicareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cognicare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF376B5C)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
