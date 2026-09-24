// CogniCare Web Voice Bridge
// Handles Web Speech Recognition (STT) and Multilingual Audio Speech Synthesis (TTS).
// Streams authentic, natural spoken audio for Indian and North-Eastern languages via CogniCare backend proxy.

window.cognicareVoice = {
  recognition: null,
  isListening: false,
  isSpeaking: false,
  speechCallback: null,
  listenCallback: null,
  currentAudio: null,

  isSupported: function() {
    var hasRecognition = ('webkitSpeechRecognition' in window) || ('SpeechRecognition' in window);
    var hasSynthesis = ('speechSynthesis' in window) && ('SpeechSynthesisUtterance' in window);
    var hasAudio = typeof Audio !== 'undefined';
    return (hasRecognition || true) && (hasSynthesis || hasAudio);
  },

  // ==========================================================
  // SPEECH-TO-TEXT (STT) - LISTENING
  // ==========================================================
  startListening: function(callback, langCode) {
    var self = this;
    self.listenCallback = callback;

    var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
      if (self.listenCallback) {
        self.listenCallback('error:Speech recognition not supported in this browser.');
      }
      return;
    }

    try {
      if (self.recognition) {
        try { self.recognition.abort(); } catch(e) {}
      }

      self.recognition = new SpeechRecognition();
      self.recognition.lang = langCode || 'en-US';
      self.recognition.continuous = false;
      self.recognition.interimResults = true;
      self.recognition.maxAlternatives = 1;

      self.recognition.onstart = function() {
        self.isListening = true;
        if (self.listenCallback) {
          self.listenCallback('status:listening');
        }
      };

      self.recognition.onresult = function(event) {
        var interim = '';
        var finalTranscript = '';

        for (var i = event.resultIndex; i < event.results.length; ++i) {
          var transcript = event.results[i][0].transcript;
          if (event.results[i].isFinal) {
            finalTranscript += transcript;
          } else {
            interim += transcript;
          }
        }

        if (finalTranscript.trim().length > 0) {
          if (self.listenCallback) {
            self.listenCallback('final:' + finalTranscript.trim());
          }
        } else if (interim.trim().length > 0) {
          if (self.listenCallback) {
            self.listenCallback('interim:' + interim.trim());
          }
        }
      };

      self.recognition.onerror = function(event) {
        self.isListening = false;
        var errorMsg = event.error || 'Unknown recognition error';
        if (event.error === 'no-speech') {
          errorMsg = 'No speech detected. Please try again.';
        } else if (event.error === 'not-allowed' || event.error === 'permission-denied') {
          errorMsg = 'Microphone permission denied. Please allow microphone in browser settings.';
        }
        if (self.listenCallback) {
          self.listenCallback('error:' + errorMsg);
        }
      };

      self.recognition.onend = function() {
        self.isListening = false;
        if (self.listenCallback) {
          self.listenCallback('status:idle');
        }
      };

      self.recognition.start();
    } catch(err) {
      self.isListening = false;
      if (self.listenCallback) {
        self.listenCallback('error:' + err.toString());
      }
    }
  },

  stopListening: function() {
    if (this.recognition) {
      try {
        this.recognition.stop();
      } catch(e) {}
    }
    this.isListening = false;
    if (this.listenCallback) {
      this.listenCallback('status:idle');
    }
  },

  // ==========================================================
  // TEXT-TO-SPEECH (TTS) - SPOKEN AUDIO OUTPUT
  // ==========================================================

  speak: function(text, callback, langCode) {
    var self = this;
    self.stopSpeaking(); // Cancel any existing speech/audio and increment session
    var sessionId = self._speechSessionId;
    self.speechCallback = callback;

    var cleanText = (text || '')
      .replace(/[*_#`~]/g, '') // strip markdown format symbols
      .replace(/\s+/g, ' ')
      .trim();

    if (!cleanText) {
      if (self.speechCallback) self.speechCallback('status:done');
      return;
    }

    self.isSpeaking = true;

    // Use CogniCare Backend TTS proxy to stream natural, native pronunciation MP3
    var host = (window.location && window.location.hostname && window.location.hostname !== '')
      ? window.location.hostname
      : '127.0.0.1';
    var targetLang = langCode || 'en-US';
    var ttsUrl = 'http://' + host + ':8000/api/translate/tts?text=' +
      encodeURIComponent(cleanText) + '&lang=' + encodeURIComponent(targetLang);

    console.log('[CogniCare Voice] Streaming TTS audio for (' + targetLang + '): ' + cleanText.substring(0, 40) + '...');

    try {
      var audio = new Audio(ttsUrl);
      self.currentAudio = audio;
      audio._isCancelled = false;
      audio._sessionId = sessionId;

      audio.onplay = function() {
        if (self._speechSessionId !== sessionId || audio._isCancelled || self.currentAudio !== audio) return;
        if (self.speechCallback) {
          self.speechCallback('status:speaking');
        }
      };

      audio.onended = function() {
        if (self._speechSessionId !== sessionId || audio._isCancelled || self.currentAudio !== audio) return;
        self.isSpeaking = false;
        self.currentAudio = null;
        if (self.speechCallback) {
          self.speechCallback('status:done');
          self.speechCallback = null;
        }
      };

      audio.onerror = function(err) {
        if (self._speechSessionId !== sessionId || audio._isCancelled || self.currentAudio !== audio) return;
        console.warn('[CogniCare Voice] Audio proxy stream error:', err);
        self.isSpeaking = false;
        self.currentAudio = null;
        if (self.speechCallback) {
          self.speechCallback('status:done');
          self.speechCallback = null;
        }
      };

      var playPromise = audio.play();
      if (playPromise !== undefined) {
        playPromise.catch(function(err) {
          if (self._speechSessionId !== sessionId || audio._isCancelled || self.currentAudio !== audio || err.name === 'AbortError') {
            return;
          }
          console.warn('[CogniCare Voice] Audio play error:', err);
          self.isSpeaking = false;
          self.currentAudio = null;
          if (self.speechCallback) {
            self.speechCallback('status:done');
            self.speechCallback = null;
          }
        });
      }
    } catch(err) {
      console.warn('[CogniCare Voice] Audio creation failed:', err);
      self.isSpeaking = false;
      self.currentAudio = null;
      if (self.speechCallback) {
        self.speechCallback('status:done');
        self.speechCallback = null;
      }
    }
  },

  stopSpeaking: function() {
    this.isSpeaking = false;
    this._speechSessionId = (this._speechSessionId || 0) + 1;

    if (this.currentAudio) {
      try {
        this.currentAudio._isCancelled = true;
        this.currentAudio.onplay = null;
        this.currentAudio.onended = null;
        this.currentAudio.onerror = null;
        this.currentAudio.pause();
        this.currentAudio.currentTime = 0;
        this.currentAudio.src = '';
      } catch(e) {}
      this.currentAudio = null;
    }

    if ('speechSynthesis' in window) {
      try {
        window.speechSynthesis.pause();
        window.speechSynthesis.cancel();
      } catch(e) {}
    }

    if (this.speechCallback) {
      this.speechCallback('status:done');
      this.speechCallback = null;
    }
  }
};

