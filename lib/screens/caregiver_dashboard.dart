import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/people_api.dart';
import '../services/translation_service.dart';
import '../widgets/language_selector.dart';

class CaregiverDashboardPage extends StatefulWidget {
  const CaregiverDashboardPage({super.key});

  @override
  State<CaregiverDashboardPage> createState() => _CaregiverDashboardPageState();
}

class _CaregiverDashboardPageState extends State<CaregiverDashboardPage> {
  bool _isLoading = true;
  bool _isLoggingIn = false;
  String? _errorMessage;

  String? _caregiverId;
  Map<String, dynamic>? _caregiverProfile;
  Map<String, dynamic>? _connectedCaregiver;
  List<Map<String, dynamic>> _patients = [];
  int _selectedPatientIndex = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isRegisterMode = false;

  final TextEditingController _regCgNameController = TextEditingController();
  final TextEditingController _regCgEmailController = TextEditingController();
  final TextEditingController _regCgPasswordController = TextEditingController();
  final TextEditingController _regCgPhoneController = TextEditingController();
  final TextEditingController _regCgRelController =
      TextEditingController(text: 'Primary caregiver');

  final TextEditingController _regPtNameController = TextEditingController();
  final TextEditingController _regPtEmailController = TextEditingController();
  final TextEditingController _regPtPasswordController = TextEditingController();
  final TextEditingController _regPtAgeController = TextEditingController();
  final TextEditingController _regPtDiagnosisController = TextEditingController();

  @override
  void initState() {
    super.initState();
    TranslationService.instance.addListener(_onLanguageChange);
    _initializeCaregiver();
  }

  void _onLanguageChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    TranslationService.instance.removeListener(_onLanguageChange);
    _emailController.dispose();
    _passwordController.dispose();
    _regCgNameController.dispose();
    _regCgEmailController.dispose();
    _regCgPasswordController.dispose();
    _regCgPhoneController.dispose();
    _regCgRelController.dispose();
    _regPtNameController.dispose();
    _regPtEmailController.dispose();
    _regPtPasswordController.dispose();
    _regPtAgeController.dispose();
    _regPtDiagnosisController.dispose();
    super.dispose();
  }

  Future<void> _initializeCaregiver() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loggedInCaregiverId = await AuthStorage.getCaregiverId();
      if (loggedInCaregiverId != null) {
        _caregiverId = loggedInCaregiverId;
        _caregiverProfile = await AuthStorage.getCaregiverProfile();
        await _fetchCaregiverPatients(_caregiverId!);
        return;
      }

      // Check if current logged-in patient has an attached caregiver
      final patientId = await AuthStorage.getPatientId();
      if (patientId != null) {
        try {
          final patientProfile = await PeopleApi.getPatientProfile(patientId);
          if (patientProfile['caregiver'] != null) {
            _connectedCaregiver =
                patientProfile['caregiver'] as Map<String, dynamic>;
            final cgEmail = _connectedCaregiver!['email'] as String?;
            if (cgEmail != null && cgEmail.isNotEmpty) {
              _emailController.text = cgEmail;
            }
          }
        } catch (_) {}
      }

      // Also check local cached patient profile
      if (_connectedCaregiver == null) {
        final cachedPatient = await AuthStorage.getPatientProfile();
        if (cachedPatient != null && cachedPatient['caregiver'] != null) {
          _connectedCaregiver =
              cachedPatient['caregiver'] as Map<String, dynamic>;
          final cgEmail = _connectedCaregiver!['email'] as String?;
          if (cgEmail != null && cgEmail.isNotEmpty) {
            _emailController.text = cgEmail;
          }
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCaregiverPatients(String caregiverId) async {
    try {
      final res =
          await PeopleApi.getCaregiverPatientsDailyProgress(caregiverId);
      if (mounted) {
        setState(() {
          _caregiverProfile =
              res['caregiver'] as Map<String, dynamic>? ?? _caregiverProfile;
          final pts = (res['patients'] as List?) ?? [];
          _patients =
              pts.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _selectedPatientIndex = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load patients data: $e';
        });
      }
    }
  }

  Future<void> _handleCaregiverLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationService.instance.getCached('Please enter both email and password.'))),
      );
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      final cgId = await PeopleApi.loginCaregiver(email, password);
      _caregiverId = cgId;
      _caregiverProfile = await AuthStorage.getCaregiverProfile();
      await _fetchCaregiverPatients(cgId);
    } catch (e) {
      String msg = e.toString().replaceAll('Exception:', '').trim();
      if (msg.contains('string_too_short')) {
        msg = 'Invalid password. Tip: Default password is your name (e.g. ramu).';
      }
      if (mounted) {
        setState(() {
          _errorMessage = msg;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleQuickAccess(String email) async {
    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      final cgId = await PeopleApi.quickAccessCaregiver(email);
      _caregiverId = cgId;
      _caregiverProfile = await AuthStorage.getCaregiverProfile();
      await _fetchCaregiverPatients(cgId);
    } catch (e) {
      String msg = e.toString().replaceAll('Exception:', '').trim();
      if (mounted) {
        setState(() {
          _errorMessage = msg;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
          _isLoading = false;
        });
      }
    }
  }

  void _showResetPasswordDialog() {
    final resetEmailCtrl = TextEditingController(text: _emailController.text);
    final resetPwdCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const TrText(
          'Set / Reset Caregiver Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TrText(
              'Set a new password for your caregiver account:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailCtrl,
              decoration: InputDecoration(
                labelText: TranslationService.instance.getCached('Caregiver Email'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: resetPwdCtrl,
              decoration: InputDecoration(
                labelText: TranslationService.instance.getCached('New Password'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const TrText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final em = resetEmailCtrl.text.trim();
              final np = resetPwdCtrl.text.trim();
              if (em.isEmpty || np.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await PeopleApi.resetCaregiverPassword(em, np);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(TranslationService.instance.getCached('Password updated successfully! You can now sign in.')),
                    ),
                  );
                  _emailController.text = em;
                  _passwordController.text = np;
                }
              } catch (err) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating password: $err')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF376B5C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const TrText('Save Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegisterCaregiverWithPatient() async {
    final cgName = _regCgNameController.text.trim();
    final cgEmail = _regCgEmailController.text.trim();
    final cgPassword = _regCgPasswordController.text;
    final cgPhone = _regCgPhoneController.text.trim();
    final cgRel = _regCgRelController.text.trim();

    final ptName = _regPtNameController.text.trim();
    final ptEmail = _regPtEmailController.text.trim();
    final ptPassword = _regPtPasswordController.text;
    final ptAgeStr = _regPtAgeController.text.trim();
    final ptDiagnosis = _regPtDiagnosisController.text.trim();

    if (cgName.isEmpty || cgEmail.isEmpty || cgPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            TranslationService.instance.getCached(
              'Please provide caregiver name, email and password.',
            ),
          ),
        ),
      );
      return;
    }

    if (ptName.isEmpty || ptEmail.isEmpty || ptPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            TranslationService.instance.getCached(
              'Please provide patient name, login email and login password.',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      final res = await PeopleApi.registerCaregiverWithPatient(
        caregiverName: cgName,
        caregiverEmail: cgEmail,
        caregiverPassword: cgPassword,
        caregiverPhone: cgPhone.isNotEmpty ? cgPhone : null,
        caregiverRelationship: cgRel.isNotEmpty ? cgRel : 'Primary caregiver',
        patientName: ptName,
        patientEmail: ptEmail,
        patientPassword: ptPassword,
        patientAge: int.tryParse(ptAgeStr),
        patientDiagnosis: ptDiagnosis.isNotEmpty ? ptDiagnosis : null,
      );

      final cg = res['caregiver'] as Map<String, dynamic>;
      _caregiverId = cg['id'] as String;
      _caregiverProfile = cg;
      await _fetchCaregiverPatients(_caregiverId!);

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF376B5C)),
                SizedBox(width: 8),
                TrText(
                  'Account Created!',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF173B35)),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caregiver $cgName has been registered successfully.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EFEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TrText(
                        'Patient Login Credentials:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF173B35),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('• Patient Name: $ptName', style: const TextStyle(fontSize: 13)),
                      Text('• Login Email: $ptEmail',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const TrText(
                        'Your patient can now sign in immediately from the Patient Login screen using these credentials.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
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
                child: const TrText('Continue to Dashboard'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  void _showRegisterPatientDialog() {
    final ptNameCtrl = TextEditingController();
    final ptEmailCtrl = TextEditingController();
    final ptPwdCtrl = TextEditingController();
    final ptAgeCtrl = TextEditingController();
    final ptDiagCtrl = TextEditingController();
    final ptRelCtrl = TextEditingController(text: 'Primary caregiver');
    bool isSaving = false;
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_add_rounded, color: Color(0xFF376B5C)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: TrText(
                  'Register New Patient',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TrText(
                    'Provide details and create login credentials for your patient so they can sign in to Cognicare.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  if (dialogError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        dialogError!,
                        style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: ptNameCtrl,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Patient Full Name *'),
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ptAgeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: TranslationService.instance.getCached('Age'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: ptRelCtrl,
                          decoration: InputDecoration(
                            labelText: TranslationService.instance.getCached('Relationship'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ptDiagCtrl,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Condition / Stage'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const TrText(
                    'Patient Login Credentials',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF173B35)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ptEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Patient Login Email *'),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ptPwdCtrl,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Patient Login Password *'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const TrText('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final pName = ptNameCtrl.text.trim();
                      final pEmail = ptEmailCtrl.text.trim();
                      final pPwd = ptPwdCtrl.text;
                      final pAge = int.tryParse(ptAgeCtrl.text.trim());
                      final pDiag = ptDiagCtrl.text.trim();
                      final pRel = ptRelCtrl.text.trim();

                      if (pName.isEmpty || pEmail.isEmpty || pPwd.isEmpty) {
                        setDialogState(() {
                          dialogError = 'Please provide patient name, login email and password.';
                        });
                        return;
                      }

                      setDialogState(() {
                        isSaving = true;
                        dialogError = null;
                      });

                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(ctx);

                      try {
                        await PeopleApi.caregiverCreatePatient(
                          caregiverId: _caregiverId!,
                          patientName: pName,
                          patientEmail: pEmail,
                          patientPassword: pPwd,
                          patientAge: pAge,
                          patientDiagnosis: pDiag.isNotEmpty ? pDiag : null,
                          relationshipType: pRel.isNotEmpty ? pRel : 'Primary caregiver',
                        );

                        if (ctx.mounted) {
                          navigator.pop();
                        }
                        if (!mounted) return;
                        await _fetchCaregiverPatients(_caregiverId!);
                        if (!mounted) return;
                        if (_patients.isNotEmpty) {
                          setState(() {
                            _selectedPatientIndex = _patients.length - 1;
                          });
                        }
                        messenger.showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF376B5C),
                            content: Text(
                              'Patient $pName registered successfully! Login email: $pEmail',
                            ),
                          ),
                        );
                      } catch (err) {
                        setDialogState(() {
                          isSaving = false;
                          dialogError = err.toString().replaceFirst('Exception: ', '');
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF376B5C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const TrText('Register Patient'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logoutCaregiver() async {
    await AuthStorage.clearCaregiverSession();
    if (mounted) {
      setState(() {
        _caregiverId = null;
        _caregiverProfile = null;
        _patients = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        title: const TrText(
          'Caregiver Portal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
        actions: [
          const LanguageSelectorButton(),
          if (_caregiverId != null)
            IconButton(
              icon: const Icon(Icons.person_add_rounded, color: Color(0xFF173B35)),
              tooltip: TranslationService.instance.getCached('Register New Patient'),
              onPressed: _showRegisterPatientDialog,
            ),
          if (_caregiverId != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF173B35)),
              tooltip: TranslationService.instance.getCached('Refresh'),
              onPressed: () {
                if (_caregiverId != null) {
                  _fetchCaregiverPatients(_caregiverId!);
                }
              },
            ),
          if (_caregiverId != null)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFF173B35)),
              tooltip: TranslationService.instance.getCached('Sign Out'),
              onPressed: _logoutCaregiver,
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF376B5C)),
              )
            : _caregiverId == null
                ? _buildCaregiverLoginForm()
                : _buildCaregiverDashboard(),
      ),
    );
  }

  // ==========================================================
  // CAREGIVER LOGIN / REGISTER VIEW
  // ==========================================================
  Widget _buildCaregiverLoginForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _isRegisterMode ? 520 : 440),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _isRegisterMode
                ? _buildCaregiverRegisterView()
                : _buildCaregiverSignInView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCaregiverSignInView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE4EFEA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              size: 40,
              color: Color(0xFF376B5C),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: TrText(
            'Caregiver Access',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B35),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: TrText(
            'Sign in to monitor patient daily progress and activities.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        if (_errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(fontSize: 13, color: Colors.red.shade700),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // --------------------------------------------------
        // QUICK ACCESS CARD (IF CONNECTED CAREGIVER DETECTED)
        // --------------------------------------------------
        if (_connectedCaregiver != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE4EFEA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF376B5C).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFF376B5C),
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    TrText(
                      'Connected Caregiver',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${_connectedCaregiver!['name']} (${_connectedCaregiver!['email']})',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoggingIn
                        ? null
                        : () => _handleQuickAccess(
                              _connectedCaregiver!['email'],
                            ),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const TrText(
                          'Direct Access as',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' ${_connectedCaregiver!['name']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF376B5C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TrText(
                  'OR SIGN IN WITH PASSWORD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 18),
        ],

        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Caregiver Email'),
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Password'),
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TrText(
              'Default: your name (e.g. ramu)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            TextButton(
              onPressed: _showResetPasswordDialog,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const TrText(
                'Set / Reset Password',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF376B5C),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoggingIn ? null : _handleCaregiverLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF376B5C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoggingIn
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const TrText(
                    'Sign In to Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TrText(
                'New caregiver?',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegisterMode = true;
                    _errorMessage = null;
                  });
                },
                child: const TrText(
                  'Register Caregiver & Patient',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF376B5C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaregiverRegisterView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE4EFEA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 38,
              color: Color(0xFF376B5C),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Center(
          child: TrText(
            'Register Caregiver & Patient',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B35),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: TrText(
            'Create your caregiver account and set up login credentials for your patient.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),
        if (_errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(fontSize: 13, color: Colors.red.shade700),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ---------------- CAREGIVER DETAILS ----------------
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE4EFEA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                size: 16,
                color: Color(0xFF376B5C),
              ),
            ),
            const SizedBox(width: 8),
            const TrText(
              'Caregiver Information',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B35),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regCgNameController,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Caregiver Full Name *'),
            prefixIcon: const Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regCgEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Caregiver Email *'),
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regCgPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Caregiver Password *'),
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _regCgPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: TranslationService.instance.getCached('Phone Number'),
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _regCgRelController,
                decoration: InputDecoration(
                  labelText: TranslationService.instance.getCached('Relationship'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),
        const Divider(),
        const SizedBox(height: 14),

        // ---------------- PATIENT DETAILS ----------------
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE4EFEA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 16,
                color: Color(0xFF376B5C),
              ),
            ),
            const SizedBox(width: 8),
            const TrText(
              'Patient Details & Login Credentials',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B35),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const TrText(
          'Your patient will use this email and password to sign in.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regPtNameController,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Patient Full Name *'),
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _regPtAgeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: TranslationService.instance.getCached('Age'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _regPtDiagnosisController,
                decoration: InputDecoration(
                  labelText: TranslationService.instance.getCached('Condition / Stage'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regPtEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Patient Login Email *'),
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regPtPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Patient Login Password *'),
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoggingIn ? null : _handleRegisterCaregiverWithPatient,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF376B5C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoggingIn
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const TrText(
                    'Register Caregiver & Patient',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TrText(
                'Already have a caregiver account?',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegisterMode = false;
                    _errorMessage = null;
                  });
                },
                child: const TrText(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF376B5C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // CAREGIVER DASHBOARD VIEW
  // ==========================================================
  Widget _buildCaregiverDashboard() {
    final caregiverName = _caregiverProfile?['name'] ?? 'Caregiver';
    final caregiverEmail = _caregiverProfile?['email'] ?? '';

    if (_patients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people_outline_rounded,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TrText(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B35),
                    ),
                  ),
                  Text(
                    ', $caregiverName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B35),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const TrText(
                'No patients are currently linked to your caregiver account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showRegisterPatientDialog,
                icon: const Icon(Icons.person_add_rounded),
                label: const TrText('Register New Patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF376B5C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  if (_caregiverId != null) {
                    _fetchCaregiverPatients(_caregiverId!);
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const TrText('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    final activePatient = _patients[_selectedPatientIndex];
    final patientName = activePatient['patient_name'] ?? 'Patient';
    final relationship = activePatient['relationship_type'] ?? 'Primary caregiver';
    final actsToday = (activePatient['activities_completed_today'] as num?)?.toInt() ?? 0;
    final target = (activePatient['daily_goal_target'] as num?)?.toInt() ?? 10;
    final dailyPct = (activePatient['daily_goal_percentage'] as num?)?.toDouble() ?? 0.0;
    final todayAcc = (activePatient['average_accuracy_today'] as num?)?.toDouble() ?? 0.0;

    final overallProg = (activePatient['overall_progress'] as num?)?.toDouble() ?? 0.0;
    final totalActs = (activePatient['total_activities_completed'] as num?)?.toInt() ?? 0;
    final totalScore = (activePatient['total_score'] as num?)?.toInt() ?? 0;
    final overallAcc = (activePatient['overall_accuracy'] as num?)?.toDouble() ?? 0.0;

    final games = (activePatient['games_breakdown'] as List?) ?? [];
    final weekStatus = (activePatient['week_status'] as Map<String, dynamic>?) ?? {};
    final recentAttempts = (activePatient['recent_attempts'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // CAREGIVER WELCOME BAR
          // --------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2EBE6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EFEA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: Color(0xFF376B5C),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const TrText(
                            'Caregiver',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173B35),
                            ),
                          ),
                          Text(
                            ': $caregiverName',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173B35),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        caregiverEmail,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------
          // CONNECTED PATIENTS & ADD PATIENT
          // --------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TrText(
                'Connected Patients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showRegisterPatientDialog,
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const TrText('Add Patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4EFEA),
                  foregroundColor: const Color(0xFF376B5C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_patients.length > 1) ...[
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _patients.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final p = _patients[index];
                  final isSelected = index == _selectedPatientIndex;
                  return ChoiceChip(
                    label: Text(p['patient_name'] ?? 'Patient ${index + 1}'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF376B5C),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF173B35),
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedPatientIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            const SizedBox(height: 10),
          ],

          // --------------------------------------------------
          // PATIENT OVERVIEW CARD
          // --------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF376B5C), Color(0xFF224D41)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF376B5C),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                const TrText(
                                  'Relationship',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  ': $relationship',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const TrText(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 14),
                // Today's Daily Goal inside Patient Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TrText(
                      "Today's Daily Goal",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${dailyPct.round()}% ($actsToday / $target ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBCE3D5),
                          ),
                        ),
                        const TrText(
                          'activities',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBCE3D5),
                          ),
                        ),
                        const Text(
                          ')',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBCE3D5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (dailyPct / 100.0).clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF86D5B8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                actsToday == 0
                    ? const TrText(
                        'No activities completed yet today.',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      )
                    : Row(
                        children: [
                          const TrText(
                            'Today Accuracy',
                            style: TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                          Text(
                            ': ${todayAcc.round()}%',
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                        ],
                      ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // ALL-TIME SUMMARY TILES
          // --------------------------------------------------
          const TrText(
            'Overall Cognitive Health',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B35),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _metricTile(
                  'Milestone Progress',
                  '${overallProg.round()}%',
                  Icons.timeline_rounded,
                  const Color(0xFFE4EFEA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricTile(
                  'Total Activities',
                  '$totalActs',
                  Icons.sports_esports_rounded,
                  const Color(0xFFE8E4F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  'Overall Accuracy',
                  '${overallAcc.round()}%',
                  Icons.gps_fixed_rounded,
                  const Color(0xFFF1E8D8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricTile(
                  'Total Score',
                  '$totalScore',
                  Icons.emoji_events_rounded,
                  const Color(0xFFE5E9F0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // --------------------------------------------------
          // WEEKLY ACTIVITY STREAK
          // --------------------------------------------------
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
                  'This Week Activity Streak',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _caregiverDayChip('Mon', (weekStatus['Mon'] as bool?) ?? false),
                    _caregiverDayChip('Tue', (weekStatus['Tue'] as bool?) ?? false),
                    _caregiverDayChip('Wed', (weekStatus['Wed'] as bool?) ?? false),
                    _caregiverDayChip('Thu', (weekStatus['Thu'] as bool?) ?? false),
                    _caregiverDayChip('Fri', (weekStatus['Fri'] as bool?) ?? false),
                    _caregiverDayChip('Sat', (weekStatus['Sat'] as bool?) ?? false),
                    _caregiverDayChip('Sun', (weekStatus['Sun'] as bool?) ?? false),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // --------------------------------------------------
          // GAMES PERFORMANCE BREAKDOWN
          // --------------------------------------------------
          const TrText(
            'Games Performance Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B35),
            ),
          ),
          const SizedBox(height: 14),

          if (games.isEmpty)
            const TrText(
              'No game data available.',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...games.map((g) {
              final gMap = Map<String, dynamic>.from(g as Map);
              final name = gMap['name'] ?? 'Game';
              final category = gMap['category'] ?? 'Cognitive';
              final attempts = (gMap['attempts'] as num?)?.toInt() ?? 0;
              final acc = (gMap['average_accuracy'] as num?)?.toDouble() ?? 0.0;
              final highScore = (gMap['high_score'] as num?)?.toInt() ?? 0;
              final played = (gMap['played'] as bool?) ?? (attempts > 0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: played
                          ? const Color(0xFF376B5C).withValues(alpha: 0.3)
                          : const Color(0xFFE5E5E5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: played
                              ? const Color(0xFFE4EFEA)
                              : const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getGameIcon(name),
                          color: played
                              ? const Color(0xFF376B5C)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TrText(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF173B35),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAEAEA),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: TrText(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            played
                                ? Row(
                                    children: [
                                      Text(
                                        '$attempts ',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      TrText(
                                        attempts == 1 ? 'attempt' : 'attempts',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const Text(
                                        ' • ',
                                        style: TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                      const TrText(
                                        'Best',
                                        style: TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                      Text(
                                        ': $highScore ',
                                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                      const TrText(
                                        'pts',
                                        style: TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                    ],
                                  )
                                : const TrText(
                                    'Not played yet',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            played ? '${acc.round()}%' : '0%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: played
                                  ? const Color(0xFF376B5C)
                                  : Colors.grey,
                            ),
                          ),
                          const TrText(
                            'Accuracy',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // RECENT ACTIVITY LOG
          // --------------------------------------------------
          const TrText(
            'Recent Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B35),
            ),
          ),
          const SizedBox(height: 12),

          if (recentAttempts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: TrText(
                  'No recent activities recorded for this patient yet.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            )
          else
            ...recentAttempts.map((att) {
              final aMap = Map<String, dynamic>.from(att as Map);
              final gName = aMap['game_name'] ?? 'Game';
              final score = aMap['score'] ?? 0;
              final acc = (aMap['accuracy'] as num?)?.toDouble() ?? 0.0;
              final startedAt = aMap['started_at'] ?? '';
              final timeStr = startedAt.length >= 16
                  ? startedAt.substring(0, 16).replaceAll('T', ' ')
                  : startedAt;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF376B5C),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TrText(
                              gName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173B35),
                              ),
                            ),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+$score ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF376B5C),
                                ),
                              ),
                              const TrText(
                                'pts',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF376B5C),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${acc.round()}% ',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const TrText(
                                'acc',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF376B5C), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),
                TrText(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _caregiverDayChip(String day, bool active) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF376B5C) : const Color(0xFFF1F1F1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            active ? Icons.check_rounded : Icons.remove_rounded,
            color: active ? Colors.white : Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        TrText(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? const Color(0xFF376B5C) : Colors.grey,
          ),
        ),
      ],
    );
  }

  IconData _getGameIcon(String name) {
    switch (name.toLowerCase()) {
      case 'memory match':
        return Icons.psychology_rounded;
      case 'pattern recall':
        return Icons.grid_view_rounded;
      case 'odd one out':
        return Icons.visibility_rounded;
      case 'number sequence':
        return Icons.pin_rounded;
      default:
        return Icons.sports_esports_rounded;
    }
  }
}
