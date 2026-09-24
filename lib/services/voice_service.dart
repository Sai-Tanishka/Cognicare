import 'dart:js_interop';
import 'package:flutter/foundation.dart';

@JS('cognicareVoice.isSupported')
external bool? _jsIsSupported();

@JS('cognicareVoice.startListening')
external void _jsStartListening(JSFunction callback, JSString langCode);

@JS('cognicareVoice.stopListening')
external void _jsStopListening();

@JS('cognicareVoice.speak')
external void _jsSpeak(JSString text, JSFunction callback, JSString langCode);

@JS('cognicareVoice.stopSpeaking')
external void _jsStopSpeaking();

/// Cross-platform Multilingual Voice Service supporting Web Speech API (STT & TTS)
class VoiceService {
  static final VoiceService instance = VoiceService._internal();
  VoiceService._internal();

  bool _isListening = false;
  bool _isSpeaking = false;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  /// Checks whether Web Speech Recognition and Synthesis are supported in this environment
  bool get isSupported {
    if (!kIsWeb) return false;
    try {
      return _jsIsSupported() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Starts listening to the microphone for user speech in the specified language
  void startListening({
    String langCode = 'en-US',
    required void Function(String text, bool isFinal) onResult,
    required void Function(String error) onError,
    required VoidCallback onEnd,
  }) {
    if (!kIsWeb) {
      onError('Speech recognition is supported on web browsers.');
      onEnd();
      return;
    }

    _isListening = true;

    final jsCallback = (JSString msg) {
      final str = msg.toDart;
      if (str.startsWith('final:')) {
        _isListening = false;
        final transcript = str.substring(6);
        onResult(transcript, true);
      } else if (str.startsWith('interim:')) {
        final transcript = str.substring(8);
        onResult(transcript, false);
      } else if (str.startsWith('error:')) {
        _isListening = false;
        final error = str.substring(6);
        onError(error);
      } else if (str == 'status:idle') {
        _isListening = false;
        onEnd();
      }
    }.toJS;

    try {
      _jsStartListening(jsCallback, langCode.toJS);
    } catch (e) {
      _isListening = false;
      onError('Failed to start microphone: $e');
      onEnd();
    }
  }

  /// Stops speech recognition
  void stopListening() {
    _isListening = false;
    if (kIsWeb) {
      try {
        _jsStopListening();
      } catch (_) {}
    }
  }

  /// Synthesizes and speaks text aloud using Web Speech Synthesis in the target language
  void speak(
    String text, {
    String langCode = 'en-US',
    VoidCallback? onStart,
    VoidCallback? onDone,
  }) {
    if (!kIsWeb) {
      onDone?.call();
      return;
    }

    _isSpeaking = true;

    final jsCallback = (JSString msg) {
      final str = msg.toDart;
      if (str == 'status:speaking') {
        _isSpeaking = true;
        onStart?.call();
      } else if (str == 'status:done' || str == 'status:unsupported') {
        _isSpeaking = false;
        onDone?.call();
      }
    }.toJS;

    try {
      _jsSpeak(text.toJS, jsCallback, langCode.toJS);
    } catch (_) {
      _isSpeaking = false;
      onDone?.call();
    }
  }

  /// Stops ongoing speech audio immediately
  void stopSpeaking() {
    _isSpeaking = false;
    if (kIsWeb) {
      try {
        _jsStopSpeaking();
      } catch (_) {}
    }
  }
}
