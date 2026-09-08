import 'package:flutter/material.dart';

import '../main.dart';
import '../services/auth_storage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Dummy patient data.
  // Backend can replace these values later.
  final String patientName = 'John Doe';
  final String email = 'johndoe@gmail.com';
  final String phone = '+91 98765 43210';
  final String age = '68';
  final String diagnosis = "Alzheimer's Disease";
  final String severity = 'Mild';
  final String doctorName = 'Dr. Ananya Rao';
  final String doctorRole = 'Neurologist';
  final String doctorContact = '+91 98765 12345';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              // =================================================
              // PROFILE HEADER
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(24),
                ),

                child: Column(
                  children: [
                    // Profile picture placeholder
                    Container(
                      width: 100,
                      height: 100,

                      decoration: BoxDecoration(
                        color: const Color(0xFF376B5C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),

                      child: const Icon(
                        Icons.person_rounded,
                        size: 58,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      patientName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Patient',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 46,

                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showMessage(
                            context,
                            'Edit profile will be connected later.',
                          );
                        },

                        icon: const Icon(Icons.edit_outlined, size: 19),

                        label: const Text('Edit Profile'),

                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF376B5C),

                          side: const BorderSide(color: Color(0xFF376B5C)),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // PERSONAL INFORMATION
              // =================================================
              _sectionTitle('Personal Information'),

              const SizedBox(height: 12),

              _infoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: email,
              ),

              const SizedBox(height: 12),

              _infoCard(
                icon: Icons.phone_outlined,
                title: 'Phone Number',
                value: phone,
              ),

              const SizedBox(height: 12),

              _infoCard(
                icon: Icons.cake_outlined,
                title: 'Age',
                value: '$age years',
              ),

              const SizedBox(height: 12),

              _infoCard(
                icon: Icons.volunteer_activism_outlined,
                title: 'Caregiver',
                value: 'Ananya Rao\nPrimary caregiver',
              ),

              const SizedBox(height: 25),

              // =================================================
              // MEDICAL INFORMATION
              // =================================================
              _sectionTitle('Medical Information'),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  children: [
                    _medicalRow(
                      Icons.psychology_rounded,
                      'Diagnosis',
                      diagnosis,
                    ),

                    const Divider(height: 28),

                    _medicalRow(
                      Icons.monitor_heart_outlined,
                      'Stage / Severity',
                      severity,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // DOCTOR INFORMATION
              // =================================================
              _sectionTitle('Doctor / Therapist'),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,

                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EFEA),
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: const Icon(
                            Icons.medical_services_outlined,
                            color: Color(0xFF376B5C),
                            size: 27,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                doctorName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                doctorRole,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _doctorContactRow(Icons.phone_outlined, doctorContact),

                    const SizedBox(height: 10),

                    _doctorContactRow(
                      Icons.verified_outlined,
                      'Credentials verified',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // MEDICAL RECORDS
              // =================================================
              _sectionTitle('Medical Records'),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,

                      decoration: BoxDecoration(
                        color: const Color(0xFFF1E8D8),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Color(0xFF376B5C),
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Medical_Report.pdf',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173B35),
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Medical record',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.visibility_outlined,
                        color: Color(0xFF376B5C),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // ACCOUNT SETTINGS
              // =================================================
              _sectionTitle('Account Settings'),

              const SizedBox(height: 12),

              _settingsTile(
                context,
                Icons.lock_outline_rounded,
                'Change Password',
                () {
                  _showMessage(
                    context,
                    'Change password will be connected later.',
                  );
                },
              ),

              const SizedBox(height: 10),

              _settingsTile(
                context,
                Icons.notifications_none_rounded,
                'Notification Settings',
                () {
                  _showMessage(
                    context,
                    'Notification settings will be connected later.',
                  );
                },
              ),

              const SizedBox(height: 10),

              _settingsTile(
                context,
                Icons.help_outline_rounded,
                'Help & Support',
                () {
                  _showMessage(
                    context,
                    'Help & support will be connected later.',
                  );
                },
              ),

              const SizedBox(height: 25),

              // =================================================
              // LOGOUT
              // =================================================
              SizedBox(
                width: double.infinity,
                height: 52,

                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },

                  icon: const Icon(Icons.logout_rounded),

                  label: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,

                    side: const BorderSide(color: Colors.redAccent),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Cognicare',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF376B5C),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Your care. Your connection. Your Cognicare.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: Color(0xFF173B35),
        ),
      ),
    );
  }

  // ==========================================================
  // INFORMATION CARD
  // ==========================================================

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: const Color(0xFFE4EFEA),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: const Color(0xFF376B5C)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF173B35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MEDICAL ROW
  // ==========================================================

  Widget _medicalRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,

          decoration: BoxDecoration(
            color: const Color(0xFFE4EFEA),
            borderRadius: BorderRadius.circular(13),
          ),

          child: Icon(icon, color: const Color(0xFF376B5C)),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF173B35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DOCTOR CONTACT
  // ==========================================================

  Widget _doctorContactRow(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F2),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF376B5C)),

          const SizedBox(width: 10),

          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF173B35)),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SETTINGS TILE
  // ==========================================================

  Widget _settingsTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(17),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,

                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(icon, color: const Color(0xFF376B5C)),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF173B35),
                  ),
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // ==========================================================
  // LOGOUT DIALOG
  // ==========================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Log Out?'),

          content: const Text('Are you sure you want to log out of Cognicare?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },

              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    await AuthStorage.clearPatientSession();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
      (_) => false,
    );
  }
}
