import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'icon': Icons.medication_rounded,
        'title': 'Medicine Reminder',
        'message': 'It is time to take your morning medicine.',
        'time': '10:00 AM',
      },
      {
        'icon': Icons.psychology_rounded,
        'title': 'Activity Reminder',
        'message': 'Your memory activity is waiting for you.',
        'time': '11:00 AM',
      },
      {
        'icon': Icons.water_drop_rounded,
        'title': 'Stay Hydrated',
        'message': 'Remember to drink some water.',
        'time': '12:30 PM',
      },
    ];

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
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EFEA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: const Color(0xFF376B5C),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] as String,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173B35),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        notification['message'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        notification['time'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF376B5C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
