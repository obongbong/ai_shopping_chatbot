// lib/services/tts_service.dart
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._internal() {
    _tts =
        FlutterTts()
          ..setLanguage('ko-KR')
          ..setSpeechRate(0.5)
          ..setVolume(0.8)
          ..setPitch(1.2)
          ..setQueueMode(1) // QUEUE_ADD
          ..awaitSpeakCompletion(true);
  }

  late final FlutterTts _tts;
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }
}
