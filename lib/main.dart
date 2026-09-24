import 'package:flutter/material.dart';

import 'screens/caregiver_dashboard.dart';
import 'screens/login.dart';
import 'services/translation_service.dart';
import 'widgets/language_selector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TranslationService.instance.init();
  runApp(const CognicareApp());
}

class CognicareApp extends StatefulWidget {
  const CognicareApp({super.key});

  @override
  State<CognicareApp> createState() => _CognicareAppState();
}

class _CognicareAppState extends State<CognicareApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cognicare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF376B5C)),
        useMaterial3: true,
      ),
      home: const RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String _tagline = 'Cognitive Care & Support';
  String _question = 'Are you a Patient or Caregiver?';
  String _patientTitle = 'Patient';
  String _patientSubtitle = 'Access your activities and progress';
  String _caregiverTitle = 'Caregiver';
  String _caregiverSubtitle = 'Monitor and manage patient care';
  String _footer = 'Your care. Your connection. Your Cognicare.';

  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    TranslationService.instance.addListener(_onLanguageChanged);
    _translateTexts();
  }

  @override
  void dispose() {
    TranslationService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _translateTexts();
  }

  Future<void> _translateTexts() async {
    final lang = TranslationService.instance.currentLanguage;
    if (lang.code == 'en') {
      if (mounted) {
        setState(() {
          _tagline = 'Cognitive Care & Support';
          _question = 'Are you a Patient or Caregiver?';
          _patientTitle = 'Patient';
          _patientSubtitle = 'Access your activities and progress';
          _caregiverTitle = 'Caregiver';
          _caregiverSubtitle = 'Monitor and manage patient care';
          _footer = 'Your care. Your connection. Your Cognicare.';
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isTranslating = true);
    }

    try {
      final tService = TranslationService.instance;
      final results = await Future.wait([
        tService.translate('Cognitive Care & Support', targetLang: lang.code),
        tService.translate('Are you a Patient or Caregiver?', targetLang: lang.code),
        tService.translate('Patient', targetLang: lang.code),
        tService.translate('Access your activities and progress', targetLang: lang.code),
        tService.translate('Caregiver', targetLang: lang.code),
        tService.translate('Monitor and manage patient care', targetLang: lang.code),
        tService.translate('Your care. Your connection. Your Cognicare.', targetLang: lang.code),
      ]);

      if (mounted) {
        setState(() {
          _tagline = results[0];
          _question = results[1];
          _patientTitle = results[2];
          _patientSubtitle = results[3];
          _caregiverTitle = results[4];
          _caregiverSubtitle = results[5];
          _footer = results[6];
          _isTranslating = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isTranslating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = TranslationService.instance.currentLanguage;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ActionChip(
              avatar: const Icon(Icons.language_rounded, size: 18, color: Color(0xFF376B5C)),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF376B5C), width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${currentLang.nativeName} (${currentLang.name})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF173B35),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down_rounded, size: 20, color: Color(0xFF376B5C)),
                ],
              ),
              onPressed: () => showLanguageSelectorSheet(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF376B5C),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Cognicare',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF376B5C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _tagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 45),
                if (_isTranslating)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF376B5C)),
                    ),
                  ),
                Text(
                  _question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 30),
                _RoleCard(
                  icon: Icons.person_rounded,
                  title: _patientTitle,
                  subtitle: _patientSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _RoleCard(
                  icon: Icons.people_alt_rounded,
                  title: _caregiverTitle,
                  subtitle: _caregiverSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CaregiverDashboardPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  _footer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDE7E2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F0EC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF376B5C), size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
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
