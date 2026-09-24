import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_storage.dart';
import 'people_api.dart';
import 'translation_service.dart';

/// Context-aware reasoning and AI conversational engine for CogniCare's Voice Assistant
class AssistantBrain {
  static Future<String> processQuery(String query, {String? targetLang}) async {
    final q = query.toLowerCase().trim();

    // 1. Fetch live patient context
    String patientName = 'there';
    int activitiesToday = 0;
    int goalTarget = 10;
    double goalPercentage = 0.0;
    double accuracyToday = 0.0;
    String caregiverName = 'your caregiver';
    String caregiverRel = 'Primary caregiver';

    try {
      final profile = await AuthStorage.getPatientProfile();
      if (profile != null && profile['name'] != null) {
        patientName = profile['name'].toString();
      }

      final patientId = await AuthStorage.getPatientId();
      if (patientId != null) {
        final daily = await PeopleApi.getPatientDailyProgress(patientId);
        activitiesToday = (daily['activities_completed_today'] as num?)?.toInt() ?? 0;
        goalTarget = (daily['daily_goal_target'] as num?)?.toInt() ?? 10;
        goalPercentage = (daily['daily_goal_percentage'] as num?)?.toDouble() ?? 0.0;
        accuracyToday = (daily['average_accuracy_today'] as num?)?.toDouble() ?? 0.0;

        final cg = daily['caregiver'] as Map<String, dynamic>?;
        if (cg != null && cg['name'] != null) {
          caregiverName = cg['name'].toString();
          caregiverRel = cg['relationship']?.toString() ?? 'Primary caregiver';
        }
      }
    } catch (_) {}

    // 2. Query backend AI Assistant Chat service (answers any general, medical, or conversational questions)
    try {
      final baseUrl = TranslationService.baseUrl;
      final lang = targetLang ?? TranslationService.instance.currentLanguage.code;

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/translate/assistant-chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query': query,
              'patient_name': patientName,
              'target_lang': lang,
              'activities_today': activitiesToday,
              'goal_target': goalTarget,
              'caregiver_name': caregiverName,
              'caregiver_rel': caregiverRel,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final reply = data['reply']?.toString().trim();
        if (reply != null && reply.isNotEmpty) {
          return reply;
        }
      }
    } catch (_) {
      // Fallback to local cognitive reasoning if offline or network error
    }

    // 3. Local Intent matching with rich, compassionate cognitive responses (Fallback)
    final lang = targetLang ?? TranslationService.instance.currentLanguage.code;
    String localReply = '';

    // Progress & Goals
    if (q.contains('progress') ||
        q.contains('doing today') ||
        q.contains('how am i') ||
        q.contains('my score') ||
        q.contains('daily goal') ||
        q.contains('status')) {
      if (activitiesToday == 0) {
        localReply = 'Hello $patientName! You haven\'t started your activities yet today. Your daily goal is $goalTarget activities. Let\'s play a quick memory game to get started!';
      } else if (activitiesToday >= goalTarget) {
        localReply = 'Incredible work, $patientName! You have completed all $activitiesToday of your $goalTarget daily activities today ($goalPercentage%). Your average accuracy is ${accuracyToday.round()}%. You\'ve achieved your full daily goal!';
      } else {
        final remaining = goalTarget - activitiesToday;
        localReply = 'You\'re doing wonderful, $patientName! Today you have completed $activitiesToday of your $goalTarget activities (${goalPercentage.round()}% of your goal) with ${accuracyToday.round()}% accuracy. Just $remaining more to complete today\'s goal!';
      }
    }

    // Reminders & Medications
    else if (q.contains('reminder') ||
        q.contains('medicine') ||
        q.contains('medication') ||
        q.contains('pill') ||
        q.contains('tablet') ||
        q.contains('water') ||
        q.contains('hydration')) {
      localReply = 'Here are your reminders for today: First, take Donepezil 10mg with water after breakfast. Second, your daily Memory Match exercise. Third, drink 2 glasses of water this afternoon. And fourth, take your evening Multivitamin after dinner.';
    }

    // Games & Activities
    else if (q.contains('game') ||
        q.contains('activity') ||
        q.contains('play') ||
        q.contains('exercise') ||
        q.contains('memory match') ||
        q.contains('pattern recall') ||
        q.contains('odd one out') ||
        q.contains('number sequence')) {
      localReply = 'I recommend playing Memory Match or Pattern Recall today! They are gentle and enjoyable exercises that train visual recall and focus. You can find them under the Games tab.';
    }

    // Caregiver Info
    else if (q.contains('caregiver') ||
        q.contains('doctor') ||
        q.contains('ramu') ||
        q.contains('who is taking care') ||
        q.contains('contact')) {
      localReply = 'Your connected $caregiverRel is $caregiverName. They have direct access to your daily cognitive updates through the Caregiver Portal and are always there to support you.';
    }

    // Emotional Reassurance / Mood
    else if (q.contains('anxious') ||
        q.contains('sad') ||
        q.contains('worried') ||
        q.contains('lonely') ||
        q.contains('tired') ||
        q.contains('stress') ||
        q.contains('scared') ||
        q.contains('bad')) {
      localReply = 'I hear you, $patientName, and I am right here with you. Take a slow, deep breath in... and gently exhale. You are safe, you are cared for, and taking it one step at a time is all you need to do today.';
    }

    else if (q.contains('happy') ||
        q.contains('good') ||
        q.contains('great') ||
        q.contains('wonderful') ||
        q.contains('fine')) {
      localReply = 'I\'m so glad to hear that, $patientName! A positive mindset makes every day brighter. Keep that wonderful energy going!';
    }

    // Greetings
    else if (q.startsWith('hi') ||
        q.startsWith('hello') ||
        q.startsWith('hey') ||
        q.contains('good morning') ||
        q.contains('good afternoon') ||
        q.contains('good evening')) {
      localReply = 'Hello $patientName! It\'s delightful to hear your voice. How can I help you today? You can ask about your reminders, check your daily progress, or ask for game recommendations.';
    }

    // Help & Capabilities
    else if (q.contains('help') ||
        q.contains('what can you do') ||
        q.contains('who are you') ||
        q.contains('features')) {
      localReply = 'I am your CogniCare Voice Assistant! I can listen to your voice and tell you about your daily progress, read your medication reminders, suggest brain games, tell you about your caregiver, and offer supportive care anytime.';
    }

    // Gratitude
    else if (q.contains('thank') || q.contains('thanks')) {
      localReply = 'You are most welcome, $patientName! I\'m always here whenever you want to talk or check in.';
    }

    // Time / Day
    else if (q.contains('time') || q.contains('date') || q.contains('today') || q.contains('day')) {
      final now = DateTime.now();
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final dayName = days[now.weekday - 1];
      final monthName = months[now.month - 1];
      localReply = 'Today is $dayName, $monthName ${now.day}. It\'s a wonderful day to keep your mind active and stay hydrated!';
    }

    // Thoughtful General Fallback
    else {
      localReply = 'I heard you say: "$query". As your CogniCare assistant, I\'m here to support you! You can ask me questions about the world, your reminders, or your daily progress.';
    }

    if (lang != 'en') {
      try {
        return await TranslationService.instance.translate(localReply, targetLang: lang);
      } catch (_) {}
    }
    return localReply;
  }
}

