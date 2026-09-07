import 'package:flutter/material.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reminders = [
      {
        'title': 'Take morning medicine',
        'time': '9:00 AM',
        'icon': Icons.medication_rounded,
        'color': const Color(0xFFE4EFEA),
      },
      {
        'title': 'Drink some water',
        'time': '11:00 AM',
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFFE5E9F0),
      },
      {
        'title': 'Lunch time',
        'time': '1:00 PM',
        'icon': Icons.restaurant_rounded,
        'color': const Color(0xFFF1E8D8),
      },
      {
        'title': 'Take evening medicine',
        'time': '7:00 PM',
        'icon': Icons.medication_rounded,
        'color': const Color(0xFFE8E4F1),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        title: const Text(
          'Reminders',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                'Here are the things you need to remember today.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 25),

              ...reminders.map(
                (reminder) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _reminderCard(
                    icon: reminder['icon'] as IconData,
                    title: reminder['title'] as String,
                    time: reminder['time'] as String,
                    color: reminder['color'] as Color,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF376B5C)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your reminders will be updated automatically.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF376B5C),
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

  Widget _reminderCard({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, size: 30, color: const Color(0xFF376B5C)),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.notifications_active_outlined,
            color: Color(0xFF376B5C),
            size: 25,
          ),
        ],
      ),
    );
  }
}
