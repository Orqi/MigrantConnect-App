import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart'; // 👈 Added this

/// Requests microphone permission
Future<void> requestMicPermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    status = await Permission.microphone.request();
  }

  if (status.isGranted) {
    print("🎤 Microphone permission granted.");
  } else {
    print("❌ Microphone permission denied.");
  }
}

/// A class that provides voice assistant functionalities including
/// Text-to-Speech (TTS), Speech-to-Text (STT), and AI integration
/// using the Gemini API.
class VoiceAssistant {
  // Speech-to-Text instance
  final stt.SpeechToText _speech = stt.SpeechToText();
  // Flutter Text-to-Speech instance
  final FlutterTts _flutterTts = FlutterTts();

  // State variables for listening status and recognized text
  bool isListening = false;
  String recognizedText = '';

  /// Initializes the Text-to-Speech engine.
  /// Sets speech rate and pitch. Also prints available languages.
  Future<void> initTTS() async {
    try {
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);

      // Print available TTS languages
      var languages = await _flutterTts.getLanguages;
      print("Available TTS languages: $languages");

      print('TTS initialized successfully.');
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  /// Speaks the given [text] in the specified [language].
  /// Supports "Hindi" (hi-IN) and "English" (en-IN).
  Future<void> speak(String text, String language) async {
    try {
      final String locale = language == "Hindi" ? "hi-IN" : "en-IN";
      await _flutterTts.setLanguage(locale);
      await _flutterTts.speak(text);
      print('Speaking: "$text" in $locale');
    } catch (e) {
      print('Error speaking text: $e');
    }
  }

  /// Stops any ongoing speech.
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      print('Stopped speaking.');
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  /// Starts listening for user's speech.
  /// [onResult] is a callback function that receives the recognized text (including partials).
  /// [onFinalResult] is a callback that receives the final recognized text when speech ends.
  /// [language] specifies the listening language ("Hindi" or "English").
  Future<void> startListening(Function(String) onResult, String language, {Function(String)? onFinalResult}) async {
    final locale = language == "Hindi" ? "hi-IN" : "en-IN";

    // 👇 Ensure permission before proceeding
    var micPermission = await Permission.microphone.status;
    if (!micPermission.isGranted) {
      micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        print("Microphone permission not granted. Cannot start listening.");
        return;
      }
    }

    try {
      bool available = await _speech.initialize(
        onError: (errorNotification) => print('STT Error: ${errorNotification.errorMsg}'),
        onStatus: (status) => print('STT Status: $status'),
      );

      if (available) {
        _speech.listen(
          localeId: locale,
          onResult: (result) {
            recognizedText = result.recognizedWords;
            onResult(recognizedText);
            if (result.finalResult) {
              print('Final recognized text: $recognizedText');
              isListening = false;
              if (onFinalResult != null) {
                onFinalResult(recognizedText);
              }
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
        );
        isListening = true;
        print('Started listening in $locale...');
      } else {
        print('Speech recognition not available. Check permissions.');
        isListening = false;
      }
    } catch (e) {
      print('Error starting listening: $e');
      isListening = false;
    }
  }

  /// Stops the ongoing speech recognition.
  void stopListening() {
    _speech.stop();
    isListening = false;
    print('Stopped listening.');
  }

  /// Fetches a response from the Gemini AI model.
  /// [prompt] is the user's query.
  /// [language] can be "Hindi" or "English" to set the AI's persona.
  Future<String> getAIResponse(String prompt, String language) async {
    const apiKey = '';
    const apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final List<Map<String, dynamic>> chatHistory = [];

    String fullPrompt = prompt;
    if (language == "Hindi") {
      fullPrompt = "आप एक सहायक हो जो हिंदी में बात करता है। " + prompt;
    } else {
      fullPrompt = "You are an assistant who speaks English. " + prompt;
    }

    chatHistory.add({
      "role": "user",
      "parts": [
        {"text": fullPrompt}
      ]
    });

    final payload = {
      "contents": chatHistory,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['candidates'] != null && decoded['candidates'].isNotEmpty &&
            decoded['candidates'][0]['content'] != null &&
            decoded['candidates'][0]['content']['parts'] != null &&
            decoded['candidates'][0]['content']['parts'].isNotEmpty) {
          return decoded['candidates'][0]['content']['parts'][0]['text'];
        } else {
          print('Error: Unexpected Gemini API response structure: ${response.body}');
          return 'Sorry, I could not get a proper response from the AI due to an unexpected structure.';
        }
      } else {
        print('Error: Gemini API request failed with status ${response.statusCode}: ${response.body}');
        return 'Sorry, there was an error connecting to the AI service. Status code: ${response.statusCode}.';
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return 'Sorry, an unexpected error occurred while communicating with the AI.';
    }
  }
}