import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/auth_storage.dart';
import '../services/daily_tasks_api.dart';
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

  Map<String, dynamic>? _patientDailyTaskOverview;
  bool _isLoadingDailyTasks = false;
  final TextEditingController _caregiverFeedbackCtrl = TextEditingController();
  bool _isSubmittingReview = false;

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
  final TextEditingController _regPtPhoneController = TextEditingController();
  final TextEditingController _regPtAgeController = TextEditingController();
  final TextEditingController _regPtDiagnosisController = TextEditingController();
  final TextEditingController _regPtSeverityController = TextEditingController();
  final TextEditingController _regPtDoctorNameController = TextEditingController();
  final TextEditingController _regPtDoctorContactController = TextEditingController();
  final TextEditingController _regPtDoctorCredentialsController =
      TextEditingController(text: 'Neurologist / Specialist');

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
    _regPtPhoneController.dispose();
    _regPtAgeController.dispose();
    _regPtDiagnosisController.dispose();
    _regPtSeverityController.dispose();
    _regPtDoctorNameController.dispose();
    _regPtDoctorContactController.dispose();
    _regPtDoctorCredentialsController.dispose();
    _caregiverFeedbackCtrl.dispose();
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
        if (_patients.isNotEmpty) {
          final firstPid = _patients[0]['patient_id'] as String?;
          if (firstPid != null) {
            _fetchPatientDailyTasks(firstPid);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load patients data: $e';
        });
      }
    }
  }

  Future<void> _fetchPatientDailyTasks(String patientId) async {
    setState(() => _isLoadingDailyTasks = true);
    try {
      final res = await DailyTasksApi.getCaregiverDailyTaskOverview(patientId);
      if (mounted) {
        setState(() {
          _patientDailyTaskOverview = res;
          _isLoadingDailyTasks = false;
          final todayTask = res['today_task'] as Map<String, dynamic>?;
          _caregiverFeedbackCtrl.text =
              (todayTask?['caregiver_feedback'] as String?) ?? '';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingDailyTasks = false);
      }
    }
  }

  Future<void> _handleReviewTask(String dailyTaskId, String status) async {
    setState(() => _isSubmittingReview = true);
    try {
      final feedback = _caregiverFeedbackCtrl.text.trim();
      await DailyTasksApi.reviewTask(
        dailyTaskId: dailyTaskId,
        status: status,
        feedback: feedback.isNotEmpty
            ? feedback
            : (status == 'APPROVED'
                ? 'Task completed successfully.'
                : 'Please try the task again.'),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'APPROVED'
                ? 'Task approved successfully!'
                : 'Task marked for retry.'),
            backgroundColor: status == 'APPROVED'
                ? const Color(0xFF15803D)
                : const Color(0xFFC2410C),
          ),
        );
      }
      if (_patients.isNotEmpty) {
        final currentPt = _patients[_selectedPatientIndex];
        final pId = currentPt['patient_id'] as String?;
        if (pId != null) {
          await _fetchPatientDailyTasks(pId);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingReview = false);
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
    final ptPhone = _regPtPhoneController.text.trim();
    final ptAgeStr = _regPtAgeController.text.trim();
    final ptDiagnosis = _regPtDiagnosisController.text.trim();
    final ptSeverity = _regPtSeverityController.text.trim();
    final ptDoctorName = _regPtDoctorNameController.text.trim();
    final ptDoctorContact = _regPtDoctorContactController.text.trim();
    final ptDoctorCredentials = _regPtDoctorCredentialsController.text.trim();

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
        patientPhone: ptPhone.isNotEmpty ? ptPhone : null,
        patientAge: int.tryParse(ptAgeStr),
        patientDiagnosis: ptDiagnosis.isNotEmpty ? ptDiagnosis : null,
        patientSeverity: ptSeverity.isNotEmpty ? ptSeverity : null,
        patientDoctorName: ptDoctorName.isNotEmpty ? ptDoctorName : null,
        patientDoctorContact: ptDoctorContact.isNotEmpty ? ptDoctorContact : null,
        patientDoctorCredentials: ptDoctorCredentials.isNotEmpty ? ptDoctorCredentials : null,
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
    final ptPhoneCtrl = TextEditingController();
    final ptAgeCtrl = TextEditingController();
    final ptRelCtrl = TextEditingController(text: 'Primary caregiver');
    final ptDiagCtrl = TextEditingController();
    final ptSeverityCtrl = TextEditingController();
    final ptDoctorNameCtrl = TextEditingController();
    final ptDoctorContactCtrl = TextEditingController();
    final ptDoctorRoleCtrl = TextEditingController(text: 'Neurologist / Specialist');
    final ptEmailCtrl = TextEditingController();
    final ptPwdCtrl = TextEditingController();
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
                    'Provide personal, medical, and doctor details for your patient, along with login credentials.',
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
                  // --- BASIC INFO ---
                  const TrText(
                    'Personal Details',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF173B35)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ptNameCtrl,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Patient Full Name *'),
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ptPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Patient Phone Number'),
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // --- MEDICAL INFO ---
                  const TrText(
                    'Medical Information',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF173B35)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ptDiagCtrl,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Diagnosis / Condition (e.g. MCI, Alzheimer\'s)'),
                      prefixIcon: const Icon(Icons.psychology_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ptSeverityCtrl,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Stage / Severity (e.g. Mild, Moderate, Early)'),
                      prefixIcon: const Icon(Icons.monitor_heart_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // --- DOCTOR / THERAPIST ---
                  const TrText(
                    'Doctor / Therapist',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF173B35)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ptDoctorNameCtrl,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Doctor / Therapist Name'),
                      prefixIcon: const Icon(Icons.medical_services_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ptDoctorContactCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Doctor Contact Number'),
                      prefixIcon: const Icon(Icons.contact_phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ptDoctorRoleCtrl,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Specialty (e.g. Neurologist / Specialist)'),
                      prefixIcon: const Icon(Icons.verified_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // --- LOGIN CREDENTIALS ---
                  const TrText(
                    'Patient Login Credentials',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF173B35)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ptEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: TranslationService.instance.getCached('Patient Login Email *'),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      final pPhone = ptPhoneCtrl.text.trim();
                      final pAge = int.tryParse(ptAgeCtrl.text.trim());
                      final pDiag = ptDiagCtrl.text.trim();
                      final pSeverity = ptSeverityCtrl.text.trim();
                      final pDoctorName = ptDoctorNameCtrl.text.trim();
                      final pDoctorContact = ptDoctorContactCtrl.text.trim();
                      final pDoctorRole = ptDoctorRoleCtrl.text.trim();
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

                      try {
                        await PeopleApi.caregiverCreatePatient(
                          caregiverId: _caregiverId!,
                          patientName: pName,
                          patientEmail: pEmail,
                          patientPassword: pPwd,
                          patientPhone: pPhone.isNotEmpty ? pPhone : null,
                          patientAge: pAge,
                          patientDiagnosis: pDiag.isNotEmpty ? pDiag : null,
                          patientSeverity: pSeverity.isNotEmpty ? pSeverity : null,
                          patientDoctorName: pDoctorName.isNotEmpty ? pDoctorName : null,
                          patientDoctorContact: pDoctorContact.isNotEmpty ? pDoctorContact : null,
                          patientDoctorCredentials: pDoctorRole.isNotEmpty ? pDoctorRole : null,
                          relationshipType: pRel.isNotEmpty ? pRel : 'Primary caregiver',
                        );

                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        if (mounted) {
                          await _fetchCaregiverPatients(_caregiverId!);
                          if (!mounted) return;
                          if (_patients.isNotEmpty) {
                            setState(() {
                              _selectedPatientIndex = _patients.length - 1;
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF376B5C),
                              content: Text(
                                'Patient $pName registered successfully! Login email: $pEmail',
                              ),
                            ),
                          );
                        }
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
        TextField(
          controller: _regPtPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Patient Phone Number'),
            prefixIcon: const Icon(Icons.phone_outlined),
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
                  labelText: TranslationService.instance.getCached('Diagnosis / Condition'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regPtSeverityController,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Stage / Severity (e.g. Mild, Moderate)'),
            prefixIcon: const Icon(Icons.monitor_heart_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regPtDoctorNameController,
          decoration: InputDecoration(
            labelText: TranslationService.instance.getCached('Doctor / Therapist Name'),
            prefixIcon: const Icon(Icons.medical_services_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _regPtDoctorContactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: TranslationService.instance.getCached('Doctor Phone Number'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _regPtDoctorCredentialsController,
                decoration: InputDecoration(
                  labelText: TranslationService.instance.getCached('Doctor Specialty'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
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
                      final pId = _patients[index]['patient_id'] as String?;
                      if (pId != null) {
                        _fetchPatientDailyTasks(pId);
                      }
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
          const SizedBox(height: 20),

          // --------------------------------------------------
          // PATIENT CLINICAL & MEDICAL PROFILE
          // --------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2EBE6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.medical_information_outlined, color: Color(0xFF376B5C), size: 22),
                        SizedBox(width: 8),
                        TrText(
                          'Patient Medical Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173B35),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4EFEA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (activePatient['severity'] != null && activePatient['severity'].toString().isNotEmpty)
                            ? activePatient['severity']
                            : 'Patient Record',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF376B5C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _profileMiniItem(
                        Icons.cake_outlined,
                        'Age',
                        activePatient['age'] != null ? '${activePatient['age']} yrs' : 'Not provided',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _profileMiniItem(
                        Icons.phone_outlined,
                        'Phone',
                        (activePatient['phone'] != null && activePatient['phone'].toString().isNotEmpty)
                            ? activePatient['phone']
                            : 'Not provided',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _profileMiniItem(
                        Icons.psychology_rounded,
                        'Diagnosis',
                        (activePatient['diagnosis'] != null && activePatient['diagnosis'].toString().isNotEmpty)
                            ? activePatient['diagnosis']
                            : 'Not Specified',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _profileMiniItem(
                        Icons.monitor_heart_outlined,
                        'Stage / Severity',
                        (activePatient['severity'] != null && activePatient['severity'].toString().isNotEmpty)
                            ? activePatient['severity']
                            : 'Not Specified',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4EFEA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medical_services_outlined, color: Color(0xFF376B5C), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (activePatient['doctor_name'] != null && activePatient['doctor_name'].toString().isNotEmpty)
                                ? activePatient['doctor_name']
                                : 'Doctor / Therapist: Not Assigned',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173B35),
                            ),
                          ),
                          Text(
                            (activePatient['doctor_role'] != null && activePatient['doctor_role'].toString().isNotEmpty)
                                ? activePatient['doctor_role']
                                : 'Neurologist / Specialist',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (activePatient['doctor_contact'] != null &&
                        activePatient['doctor_contact'].toString().isNotEmpty &&
                        activePatient['doctor_contact'] != 'Not Assigned')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF15803D)),
                            const SizedBox(width: 4),
                            Text(
                              activePatient['doctor_contact'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // DAILY SPT (SUBJECT PERFORMED TASK) PROGRESS & REVIEW
          // --------------------------------------------------
          _buildDailyTaskProgressSection(activePatient),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // DAILY TASK HISTORY
          // --------------------------------------------------
          _buildDailyTaskHistorySection(activePatient),

          const SizedBox(height: 28),

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

  Widget _profileMiniItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2EBE6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF376B5C), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrText(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF173B35),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  // ------------------------------------------------------------
  // DAILY SPT PROOF MEDIA VIEWER
  // ------------------------------------------------------------
  void _showMediaDialog(
      BuildContext context, String? relativeUrl, String type, String title) {
    final mediaUrl = DailyTasksApi.resolveMediaUrl(relativeUrl);
    if (mediaUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No uploaded proof file available.')),
      );
      return;
    }

    final isPhoto = type.toUpperCase() == 'PHOTO';
    final isVideo = type.toUpperCase() == 'VIDEO';
    final isAudio = type.toUpperCase() == 'AUDIO';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(
              isPhoto
                  ? Icons.photo_library_rounded
                  : (isVideo
                      ? Icons.videocam_rounded
                      : Icons.audiotrack_rounded),
              color: const Color(0xFF376B5C),
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$title ($type)',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPhoto) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    mediaUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: Color(0xFF376B5C)),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                            SizedBox(height: 10),
                            Text('Unable to display image preview.'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else if (isVideo) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EFEA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.videocam_rounded, size: 56, color: Color(0xFF376B5C)),
                      const SizedBox(height: 12),
                      const Text(
                        'Video Submission Recorded',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173B35),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mediaUrl,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(mediaUrl);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.play_circle_filled_rounded),
                        label: const Text('Play Video in Browser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF376B5C),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isAudio) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1E8D8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.audiotrack_rounded, size: 56, color: Color(0xFF8A642B)),
                      const SizedBox(height: 12),
                      const Text(
                        'Voice Note Audio Submission',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A411B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mediaUrl,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(mediaUrl);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play Audio in Browser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A642B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION: DAILY TASK PROGRESS (DAILY SPT)
  // ------------------------------------------------------------
  Widget _buildDailyTaskProgressSection(Map<String, dynamic> activePatient) {
    final patientName = activePatient['patient_name'] ?? 'Patient';

    if (_isLoadingDailyTasks) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2EBE6)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF376B5C)),
        ),
      );
    }

    final todayTask =
        _patientDailyTaskOverview?['today_task'] as Map<String, dynamic>?;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EBE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFE4EFEA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment_turned_in_rounded,
                        color: Color(0xFF376B5C), size: 24),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TrText(
                          'Daily Task Progress',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173B35),
                          ),
                        ),
                        Text(
                          'Subject Performed Task (SPT) for $patientName',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF376B5C)),
                  tooltip: 'Refresh Task',
                  onPressed: () {
                    final pId = activePatient['patient_id'] as String?;
                    if (pId != null) _fetchPatientDailyTasks(pId);
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: todayTask == null
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No task has been assigned for today yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : _buildTodayTaskContent(todayTask),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTaskContent(Map<String, dynamic> task) {
    final title = task['title'] ?? 'Daily Task';
    final category = (task['task_category'] ?? 'DAILY').toString().replaceAll('_', ' ');
    final duration = task['estimated_duration'] ?? '5 mins';
    final status = (task['status'] ?? 'ASSIGNED').toString().toUpperCase();
    final submissionType =
        (task['submission_type'] ?? 'PHOTO').toString().toUpperCase();
    final submittedAt = task['submitted_at'] as String?;
    final submissionUrl = task['submission_url'] as String?;
    final notes = task['submission_notes'] as String?;
    final dailyTaskId = task['daily_task_id'] as String;

    final isSubmitted = status == 'SUBMITTED';
    final isApproved = status == 'APPROVED';
    final isNeedsRetry = status == 'NEEDS_RETRY';

    Color statusBg;
    Color statusFg;
    String statusLabel;

    if (isApproved) {
      statusBg = const Color(0xFFDCFCE7);
      statusFg = const Color(0xFF15803D);
      statusLabel = 'Approved';
    } else if (isNeedsRetry) {
      statusBg = const Color(0xFFFFEDD5);
      statusFg = const Color(0xFFC2410C);
      statusLabel = 'Needs Retry';
    } else if (isSubmitted) {
      statusBg = const Color(0xFFCCE3D8);
      statusFg = const Color(0xFF1B4E41);
      statusLabel = 'Submitted';
    } else {
      statusBg = const Color(0xFFF1F5F9);
      statusFg = const Color(0xFF475569);
      statusLabel = 'Assigned (Pending)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Status Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B35),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4EFEA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF376B5C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        duration,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusFg,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),

        // Submission Details
        Row(
          children: [
            Expanded(
              child: _profileMiniItem(
                Icons.cloud_upload_outlined,
                'Submission Type',
                submissionType,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _profileMiniItem(
                Icons.access_time_rounded,
                'Submitted At',
                submittedAt != null
                    ? submittedAt.replaceAll('T', ' ').substring(0, 16)
                    : 'Not submitted yet',
              ),
            ),
          ],
        ),

        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2EBE6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 18, color: Color(0xFF376B5C)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Patient Note: "$notes"',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF173B35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Uploaded Proof Preview
        if (submissionUrl != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EBE6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EFEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    submissionType == 'PHOTO'
                        ? Icons.photo_rounded
                        : (submissionType == 'VIDEO'
                            ? Icons.videocam_rounded
                            : Icons.mic_rounded),
                    color: const Color(0xFF376B5C),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Uploaded Proof Available',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173B35),
                        ),
                      ),
                      Text(
                        'Format: $submissionType • Tap to inspect',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showMediaDialog(
                    context,
                    submissionUrl,
                    submissionType,
                    title,
                  ),
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text('View Proof'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF376B5C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2EBE6)),
            ),
            child: const Row(
              children: [
                Icon(Icons.hourglass_empty_rounded, size: 20, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Patient has not uploaded proof for today\'s task yet.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // CAREGIVER REVIEW ACTION BOX
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.rate_review_outlined,
                      color: Color(0xFF15803D), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Caregiver Review & Feedback',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14532D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _caregiverFeedbackCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter encouragement or retry guidance for the patient...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              if (_isSubmittingReview)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Color(0xFF15803D)),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _handleReviewTask(dailyTaskId, 'APPROVED'),
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Approve Task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _handleReviewTask(dailyTaskId, 'NEEDS_RETRY'),
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: const Text('Needs Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC2410C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SECTION: DAILY TASK HISTORY
  // ------------------------------------------------------------
  Widget _buildDailyTaskHistorySection(Map<String, dynamic> activePatient) {
    final history =
        (_patientDailyTaskOverview?['history'] as List?) ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EBE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_rounded, color: Color(0xFF376B5C), size: 22),
                  SizedBox(width: 8),
                  TrText(
                    'Daily Task History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B35),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${history.length} tasks',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF376B5C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No past daily task records yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final item = Map<String, dynamic>.from(history[index] as Map);
                final dateStr = item['assigned_date'] ?? '';
                final title = item['title'] ?? 'Task';
                final cat = (item['task_category'] ?? '').toString().replaceAll('_', ' ');
                final status = (item['status'] ?? 'ASSIGNED').toString().toUpperCase();
                final subType = item['submission_type'] ?? 'PHOTO';
                final proofUrl = item['submission_url'] as String?;
                final feedback = item['caregiver_feedback'] as String?;

                Color sColor;
                if (status == 'APPROVED') {
                  sColor = const Color(0xFF15803D);
                } else if (status == 'NEEDS_RETRY') {
                  sColor = const Color(0xFFC2410C);
                } else if (status == 'SUBMITTED') {
                  sColor = const Color(0xFF0369A1);
                } else {
                  sColor = Colors.grey;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4EFEA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        subType == 'PHOTO'
                            ? Icons.photo_rounded
                            : (subType == 'VIDEO'
                                ? Icons.videocam_rounded
                                : Icons.mic_rounded),
                        color: const Color(0xFF376B5C),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173B35),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('• $cat',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          if (feedback != null && feedback.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Note: $feedback',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: sColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: sColor,
                        ),
                      ),
                    ),
                    if (proofUrl != null) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye_rounded,
                            size: 18, color: Color(0xFF376B5C)),
                        tooltip: 'View Proof',
                        onPressed: () => _showMediaDialog(
                          context,
                          proofUrl,
                          subType,
                          title,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
