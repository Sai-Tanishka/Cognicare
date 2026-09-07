import 'package:flutter/material.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final List<Map<String, dynamic>> _reminders = [
    {
      'title': 'Morning Medicine',
      'time': '10:00 AM',
      'type': 'Medicine',
      'icon': Icons.medication_rounded,
      'completed': false,
    },
    {
      'title': 'Drink Water',
      'time': '12:30 PM',
      'type': 'Health',
      'icon': Icons.water_drop_rounded,
      'completed': true,
    },
    {
      'title': 'Memory Activity',
      'time': '4:00 PM',
      'type': 'Activity',
      'icon': Icons.psychology_rounded,
      'completed': false,
    },
    {
      'title': 'Evening Medicine',
      'time': '8:00 PM',
      'type': 'Medicine',
      'icon': Icons.medication_rounded,
      'completed': false,
    },
  ];

  void _toggleReminder(int index) {
    setState(() {
      _reminders[index]['completed'] = !_reminders[index]['completed'];
    });
  }

  void _addReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adding new reminders will be connected later.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _reminders
        .where((item) => item['completed'] == true)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF173B35)),
        ),
        title: const Text(
          'Reminders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _addReminder,
            icon: const Icon(
              Icons.add_rounded,
              color: Color(0xFF376B5C),
              size: 28,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Today\'s Reminders',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Stay on track with your daily routine.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 22),

              // Progress card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF376B5C),
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today\'s Progress',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173B35),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            '$completedCount of ${_reminders.length} reminders completed',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Reminder list
              ...List.generate(_reminders.length, (index) {
                final reminder = _reminders[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildReminderCard(index, reminder),
                );
              }),

              const SizedBox(height: 8),

              // Information card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF376B5C),
                      size: 25,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Your reminders will help you remember important activities, medicines and daily tasks.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF173B35),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(int index, Map<String, dynamic> reminder) {
    final bool completed = reminder['completed'] as bool;

    Color iconBackground;

    switch (reminder['type']) {
      case 'Medicine':
        iconBackground = const Color(0xFFF1E8D8);
        break;

      case 'Health':
        iconBackground = const Color(0xFFE4EFEA);
        break;

      case 'Activity':
        iconBackground = const Color(0xFFE8E4F1);
        break;

      default:
        iconBackground = const Color(0xFFE5E9F0);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              reminder['icon'] as IconData,
              color: const Color(0xFF376B5C),
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['title'] as String,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF173B35),
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: Colors.grey,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      reminder['time'] as String,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reminder['type'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF376B5C),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Checkbox
          Checkbox(
            value: completed,
            activeColor: const Color(0xFF376B5C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (_) {
              _toggleReminder(index);
            },
          ),
        ],
      ),
    );
  }
}
