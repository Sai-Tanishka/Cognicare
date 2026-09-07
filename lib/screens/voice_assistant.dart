import 'package:flutter/material.dart';

class VoiceAssistantPage extends StatefulWidget {
  const VoiceAssistantPage({super.key});

  @override
  State<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends State<VoiceAssistantPage> {
  bool isListening = false;

  void _toggleListening() {
    setState(() {
      isListening = !isListening;
    });
  }

  void _showCommand(String command) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Command selected: $command'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        title: const Text(
          'Voice Assistant',
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
                'Talk to Cognicare',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'You can talk to me whenever you need help.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 25),

              // Conversation area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conversation',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Cognicare message
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4EFEA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Hello! How can I help you today?',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF173B35),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Placeholder user message
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1E8D8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Tap the microphone to talk.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF173B35),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Microphone
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _toggleListening,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isListening ? 120 : 105,
                        height: isListening ? 120 : 105,
                        decoration: BoxDecoration(
                          color: const Color(0xFF376B5C),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF376B5C).withOpacity(0.25),
                              blurRadius: isListening ? 25 : 12,
                              spreadRadius: isListening ? 6 : 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      isListening ? 'Listening...' : 'Tap to speak',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF173B35),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Try saying',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 14),

              _commandCard('What are my reminders?', Icons.alarm_rounded),

              const SizedBox(height: 12),

              _commandCard('How am I doing today?', Icons.bar_chart_rounded),

              const SizedBox(height: 12),

              _commandCard('Start an activity', Icons.psychology_rounded),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFF376B5C),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can ask Cognicare about your reminders, activities, mood, and progress.',
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

  Widget _commandCard(String command, IconData icon) {
    return InkWell(
      onTap: () => _showCommand(command),
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
              child: Text(
                command,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF173B35),
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
