// lib/services/tts_service.dart
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class TtsService {
  /// 말하기 시작 시 호출될 콜백
  VoidCallback? onStart;

  /// 말하기 완료 시 호출될 콜백
  VoidCallback? onComplete;

  TtsService._internal() {
    _tts =
        FlutterTts()
          ..setLanguage('ko-KR')
          ..setSpeechRate(0.6)
          ..setVolume(0.8)
          ..setPitch(1.2)
          ..setQueueMode(1) // QUEUE_ADD
          ..awaitSpeakCompletion(true);

    // TTS 시작/완료 핸들러 연결
    _tts.setStartHandler(() {
      debugPrint('🟢 [TtsService] onStart 호출');
      if (onStart != null) onStart!();
    });
    _tts.setCompletionHandler(() {
      debugPrint('🔴 [TtsService] onComplete 호출');
      if (onComplete != null) onComplete!();
    });
  }

  late final FlutterTts _tts;
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }
}
