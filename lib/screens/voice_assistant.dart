import 'package:flutter/material.dart';

class VoiceAssistantPage extends StatefulWidget {
  const VoiceAssistantPage({super.key});

  @override
  State<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends State<VoiceAssistantPage> {
  bool isListening = false;
  String userMessage = '';
  String assistantMessage = 'Hello! How can I help you today?';

  final List<Map<String, String>> conversation = [
    {'type': 'assistant', 'message': 'Hello! How can I help you today?'},
  ];

  final List<String> suggestions = [
    'What is my next activity?',
    'Remind me to take my medicine.',
    'How am I doing today?',
    'What are my reminders?',
  ];

  // ==========================================================
  // VOICE BUTTON
  // ==========================================================

  void toggleListening() {
    setState(() {
      isListening = !isListening;
    });

    if (isListening) {
      _showMessage('Listening... Speak your command.');
    } else {
      _processDummyVoiceCommand();
    }

    // TODO:
    // Connect speech recognition here later.
  }

  // ==========================================================
  // DUMMY VOICE RESPONSE
  // ==========================================================

  void _processDummyVoiceCommand() {
    if (userMessage.isEmpty) {
      setState(() {
        userMessage = 'What is my next activity?';

        assistantMessage = 'Your next activity is Memory Match at 4:00 PM.';

        conversation.add({'type': 'user', 'message': userMessage});

        conversation.add({'type': 'assistant', 'message': assistantMessage});
      });

      return;
    }
  }

  // ==========================================================
  // SUGGESTION COMMAND
  // ==========================================================

  void selectSuggestion(String suggestion) {
    setState(() {
      userMessage = suggestion;

      conversation.add({'type': 'user', 'message': suggestion});

      assistantMessage = _getDummyResponse(suggestion);

      conversation.add({'type': 'assistant', 'message': assistantMessage});
    });
  }

  // ==========================================================
  // DUMMY AI RESPONSES
  // ==========================================================

  String _getDummyResponse(String command) {
    if (command.contains('next activity')) {
      return 'Your next activity is Memory Match at 4:00 PM.';
    }

    if (command.contains('medicine')) {
      return 'Your next medicine reminder is at 8:00 PM.';
    }

    if (command.contains('doing today')) {
      return 'You are doing well today. You completed 3 activities.';
    }

    if (command.contains('reminders')) {
      return 'You have 4 reminders scheduled for today.';
    }

    return 'I can help you with activities, reminders, mood, and your daily routine.';
  }

  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // =================================================
              // INTRO
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  children: [
                    const Icon(
                      Icons.support_agent_rounded,
                      size: 45,
                      color: Color(0xFF376B5C),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Hi! I am here to help.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'You can ask me about your activities, reminders, mood, or daily routine.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // MICROPHONE
              // =================================================
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: toggleListening,

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),

                        width: isListening ? 145 : 125,

                        height: isListening ? 145 : 125,

                        decoration: BoxDecoration(
                          color: isListening
                              ? const Color(0xFF2D5B4D)
                              : const Color(0xFF376B5C),

                          shape: BoxShape.circle,

                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF376B5C)
                                  .withValues(alpha: 0.20),
                              blurRadius: isListening ? 25 : 15,
                              spreadRadius: isListening ? 8 : 3,
                            ),
                          ],
                        ),

                        child: Icon(
                          isListening
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                          size: 55,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      isListening ? 'Listening...' : 'Tap to speak',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isListening
                            ? const Color(0xFF376B5C)
                            : const Color(0xFF173B35),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      isListening
                          ? 'Tell me what you need'
                          : 'I am ready when you are',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // CONVERSATION
              // =================================================
              const Text(
                'Conversation',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  children: [
                    ...conversation.map((item) {
                      final bool isUser = item['type'] == 'user';

                      return _conversationBubble(
                        message: item['message']!,
                        isUser: isUser,
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // =================================================
              // SUGGESTED COMMANDS
              // =================================================
              const Text(
                'Try asking me',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Tap a question to try it.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 14),

              ...suggestions.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),

                  child: _suggestionCard(suggestion),
                );
              }),

              const SizedBox(height: 20),

              // =================================================
              // AI CONNECTION CARD
              // =================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3F1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDDE7E2)),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF376B5C),
                      size: 25,
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Assistant connection',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173B35),
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'AI responses and voice recognition will be connected here later.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
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
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CONVERSATION BUBBLE
  // ==========================================================

  Widget _conversationBubble({required String message, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),

        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),

        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF376B5C) : const Color(0xFFE4EFEA),

          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            if (!isUser) ...[
              const Icon(
                Icons.psychology_rounded,
                size: 19,
                color: Color(0xFF376B5C),
              ),

              const SizedBox(width: 8),
            ],

            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isUser ? Colors.white : const Color(0xFF173B35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SUGGESTION CARD
  // ==========================================================

  Widget _suggestionCard(String suggestion) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: () {
          selectSuggestion(suggestion);
        },

        borderRadius: BorderRadius.circular(16),

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: const Color(0xFFDDE7E2)),
          ),

          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,

                decoration: BoxDecoration(
                  color: const Color(0xFFE4EFEA),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF376B5C),
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF173B35),
                  ),
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
