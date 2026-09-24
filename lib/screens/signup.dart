import 'package:flutter/material.dart';

import 'login.dart';
import '../services/people_api.dart';
import '../widgets/language_selector.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController doctorContactController = TextEditingController();
  final TextEditingController doctorCredentialsController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController caregiverNameController = TextEditingController();
  final TextEditingController caregiverEmailController = TextEditingController();
  final TextEditingController caregiverPhoneController = TextEditingController();

  String? diagnosis;
  String? severity;
  String? relationship;
  String? caregiverRelationship = 'Primary caregiver';

  final List<String> symptomOptions = [
    'Memory Loss',
    'Confusion',
    'Difficulty Concentrating',
    'Disorientation',
    'Communication Difficulties',
    'Mood Changes',
    'Difficulty Performing Daily Tasks',
    'Sleep Problems',
    'Other',
  ];

  final List<String> selectedSymptoms = [];

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool acceptedTerms = false;
  bool isSubmitting = false;

  String? uploadedDocumentName;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    doctorNameController.dispose();
    doctorContactController.dispose();
    doctorCredentialsController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    caregiverNameController.dispose();
    caregiverEmailController.dispose();
    caregiverPhoneController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your age';
    }

    final age = int.tryParse(value.trim());

    if (age == null || age < 1 || age > 120) {
      return 'Enter a valid age';
    }

    return null;
  }

  void showSymptomsSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Symptoms',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Select all symptoms that apply.',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 12),

                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: symptomOptions.map((symptom) {
                          final selected = selectedSymptoms.contains(symptom);

                          return CheckboxListTile(
                            value: selected,
                            activeColor: const Color(0xFF376B5C),
                            title: Text(symptom),
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  if (!selectedSymptoms.contains(symptom)) {
                                    selectedSymptoms.add(symptom);
                                  }
                                } else {
                                  selectedSymptoms.remove(symptom);
                                }
                              });

                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF376B5C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Done'),
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

  void uploadDocument() {
    // Actual file picker will be connected later.
    setState(() {
      uploadedDocumentName = 'Medical_Report.pdf';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document upload will be connected later.')),
    );
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (diagnosis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a diagnosis')),
      );
      return;
    }

    if (severity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the stage / severity')),
      );
      return;
    }

    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // The backend creates the patient account and its zeroed progress row
      // in one database transaction.
      await PeopleApi.registerPatient(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim(),
        age: int.tryParse(ageController.text.trim()),
        diagnosis: diagnosis,
        severity: severity,
        doctorName: doctorNameController.text.trim(),
        doctorContact: doctorContactController.text.trim(),
        doctorCredentials: doctorCredentialsController.text.trim(),
        caregiverName: caregiverNameController.text.trim(),
        caregiverEmail: caregiverEmailController.text.trim(),
        caregiverPhone: caregiverPhoneController.text.trim(),
        caregiverRelationship: caregiverRelationship,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
      return;
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration successful! You can now log in.')),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  InputDecoration fieldDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorMaxLines: 2,
    );
  }

  Widget sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrText(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B35),
            ),
          ),
          const SizedBox(height: 4),
          TrText(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget labeledField(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrText(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          field,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF376B5C)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const TrText(
          'Create Account',
          style: TextStyle(
            color: Color(0xFF173B35),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          LanguageSelectorButton(),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 35),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: TrText(
                    'Create your Cognicare account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B35),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: TrText(
                    'Enter patient details to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),

                // ---------------- PERSONAL DETAILS ----------------
                sectionTitle(
                  'Personal Details',
                  'Basic information about the patient.',
                ),

                labeledField(
                  'Full Name',
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration(
                      'Enter full name',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),

                labeledField(
                  'Email',
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: fieldDecoration(
                      'Enter your email',
                      icon: Icons.email_outlined,
                    ),
                    validator: validateEmail,
                  ),
                ),

                labeledField(
                  'Phone Number',
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: fieldDecoration(
                      'Enter 10-digit phone number',
                      icon: Icons.phone_outlined,
                    ).copyWith(counterText: ''),
                    validator: validatePhone,
                  ),
                ),

                labeledField(
                  'Age',
                  TextFormField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: fieldDecoration(
                      'Enter age',
                      icon: Icons.cake_outlined,
                    ),
                    validator: validateAge,
                  ),
                ),

                // ---------------- MEDICAL DETAILS ----------------
                sectionTitle(
                  'Medical Details',
                  'This information helps personalize Cognicare.',
                ),

                labeledField(
                  'Diagnosis',
                  DropdownButtonFormField<String>(
                    initialValue: diagnosis,
                    decoration: fieldDecoration(
                      'Select diagnosis',
                      icon: Icons.medical_information_outlined,
                    ),
                    items:
                        const [
                          'Alzheimer’s Disease',
                          'Dementia',
                          'Mild Cognitive Impairment',
                          'Other',
                          'Not Diagnosed',
                        ].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        diagnosis = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a diagnosis';
                      }
                      return null;
                    },
                  ),
                ),

                labeledField(
                  'Stage / Severity',
                  DropdownButtonFormField<String>(
                    initialValue: severity,
                    decoration: fieldDecoration(
                      'Select stage / severity',
                      icon: Icons.speed_rounded,
                    ),
                    items: const ['Mild', 'Moderate', 'Severe', 'Not Specified']
                        .map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        severity = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select the stage / severity';
                      }
                      return null;
                    },
                  ),
                ),

                labeledField(
                  'Symptoms',
                  InkWell(
                    onTap: showSymptomsSelector,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: fieldDecoration(
                        'Select symptoms',
                        icon: Icons.list_alt_rounded,
                      ),
                      child: Text(
                        selectedSymptoms.isEmpty
                            ? 'Select symptoms'
                            : selectedSymptoms.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedSymptoms.isEmpty
                              ? Colors.grey
                              : const Color(0xFF173B35),
                        ),
                      ),
                    ),
                  ),
                ),

                // ---------------- DOCTOR DETAILS ----------------
                sectionTitle(
                  'Doctor / Therapist Details',
                  'Optional information for future care coordination.',
                ),

                labeledField(
                  'Doctor / Therapist Name',
                  TextFormField(
                    controller: doctorNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration(
                      'Enter name',
                      icon: Icons.person_search_outlined,
                    ),
                  ),
                ),

                labeledField(
                  'Relationship',
                  DropdownButtonFormField<String>(
                    initialValue: relationship,
                    decoration: fieldDecoration(
                      'Select relationship',
                      icon: Icons.people_outline_rounded,
                    ),
                    items:
                        const [
                          'Doctor',
                          'Therapist',
                          'Neurologist',
                          'Psychologist',
                          'Other',
                        ].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        relationship = value;
                      });
                    },
                  ),
                ),

                labeledField(
                  'Doctor / Therapist Contact',
                  TextFormField(
                    controller: doctorContactController,
                    keyboardType: TextInputType.phone,
                    decoration: fieldDecoration(
                      'Enter contact number',
                      icon: Icons.phone_in_talk_outlined,
                    ),
                  ),
                ),

                labeledField(
                  'Doctor / Therapist Credentials',
                  TextFormField(
                    controller: doctorCredentialsController,
                    maxLines: 2,
                    decoration: fieldDecoration(
                      'Example: MBBS, MD / Clinical Psychologist',
                      icon: Icons.badge_outlined,
                    ),
                  ),
                ),

                // ---------------- CAREGIVER DETAILS ----------------
                sectionTitle(
                  'Connected Caregiver Account',
                  'Connect the caregiver who monitors and manages your care.',
                ),

                labeledField(
                  'Caregiver Name',
                  TextFormField(
                    controller: caregiverNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration(
                      'Enter caregiver full name',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter caregiver name';
                      }
                      return null;
                    },
                  ),
                ),

                labeledField(
                  'Caregiver Email / Account',
                  TextFormField(
                    controller: caregiverEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: fieldDecoration(
                      'Enter caregiver email address',
                      icon: Icons.alternate_email_rounded,
                    ),
                    validator: validateEmail,
                  ),
                ),

                labeledField(
                  'Caregiver Phone Number',
                  TextFormField(
                    controller: caregiverPhoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: fieldDecoration(
                      'Enter 10-digit phone number',
                      icon: Icons.phone_outlined,
                    ).copyWith(counterText: ''),
                  ),
                ),

                labeledField(
                  'Relationship with Caregiver',
                  DropdownButtonFormField<String>(
                    initialValue: caregiverRelationship,
                    decoration: fieldDecoration(
                      'Select relationship',
                      icon: Icons.volunteer_activism_outlined,
                    ),
                    items: const [
                      'Primary caregiver',
                      'Spouse',
                      'Child',
                      'Sibling',
                      'Parent',
                      'Professional Caregiver',
                      'Other',
                    ].map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        caregiverRelationship = value;
                      });
                    },
                  ),
                ),

                // ---------------- MEDICAL RECORDS ----------------
                sectionTitle(
                  'Medical Records',
                  'Upload a doctor or therapist report, prescription, or session document.',
                ),

                InkWell(
                  onTap: uploadDocument,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFDDE7E2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EFEA),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.upload_file_rounded,
                            color: Color(0xFF376B5C),
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TrText(
                                uploadedDocumentName ?? 'Upload Document',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const TrText(
                                'PDF, JPG or PNG • Optional',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: Color(0xFF376B5C),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---------------- CREDENTIALS ----------------
                sectionTitle(
                  'Account Credentials',
                  'Create the credentials you will use to log in.',
                ),

                labeledField(
                  'Password',
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration:
                        fieldDecoration(
                          'Create a password',
                          icon: Icons.lock_outline_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }

                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }

                      return null;
                    },
                  ),
                ),

                labeledField(
                  'Confirm Password',
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration:
                        fieldDecoration(
                          'Confirm your password',
                          icon: Icons.lock_reset_outlined,
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }

                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),
                ),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: acceptedTerms,
                  activeColor: const Color(0xFF376B5C),
                  title: const TrText(
                    'I agree to the Terms & Conditions',
                    style: TextStyle(fontSize: 14),
                  ),
                  onChanged: (value) {
                    setState(() {
                      acceptedTerms = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: 15),

                // ---------------- REGISTER ----------------
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF376B5C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: TrText(
                      isSubmitting ? 'Creating account...' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const TrText('Already have an account? Log In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
