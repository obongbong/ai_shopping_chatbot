import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

class AudioService {
  AudioService._internal();
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final _controller = StreamController<String>.broadcast();
  Stream<String> get speechStream => _controller.stream;

  bool _initialized = false;
  bool _isListening = false;

  Future<void> init() async {
    _initialized = await _speech.initialize(
      onStatus: (status) {
        debugPrint('🎙 STT status: $status');
        if (status == 'notListening' || status == 'done') {
          _isListening = false;
        }
      },
      onError: (err) {
        debugPrint('❌ STT error: ${err.errorMsg}');
        if (err.permanent) {
          _isListening = false;
        }
      },
    );

    if (!_initialized) {
      debugPrint('❗ STT 초기화 실패: 권한을 허용했는지 확인하세요.');
    }
  }

  void startListening() {
    if (!_initialized || _isListening) return;
    _startListening();
  }

  Future<void> _startListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      _isListening = true;
      await _speech.listen(
        onResult: (val) {
          final result = val.recognizedWords.trim();
          debugPrint("🎧 STT 인식 결과: '$result'");

          if (val.finalResult && result.isNotEmpty) {
            _controller.add(result);
          } else {
            debugPrint("⚠️ 무시된 STT 결과 (빈 문자열 또는 임시 결과)");
          }

          _isListening = false;
        },
        localeId: 'ko_KR',
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 10),
        partialResults: false,
      );
    } catch (e) {
      _isListening = false;
      debugPrint('❌ STT start error: $e');
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  void dispose() {
    _speech.stop();
    _controller.close();
  }

  static Future<void> listenFor({
    required Function(String) onResult,
    Function(String)? onStatus,
  }) async {
    final instance = AudioService();
    await instance.init();

    instance._speech.statusListener = (status) {
      debugPrint('📡 STT status: $status');
      if (onStatus != null) onStatus(status);
    };

    instance._speech.listen(
      onResult: (val) {
        final result = val.recognizedWords.trim();
        debugPrint("🎧 수동 STT 결과: '$result'");
        if (val.finalResult && result.isNotEmpty) {
          onResult(result);
        } else {
          debugPrint("⚠️ 수동 STT 결과 무시됨");
        }
      },
      localeId: 'ko_KR',
      listenMode: stt.ListenMode.dictation,
      listenFor: const Duration(minutes: 2),
      pauseFor: const Duration(seconds: 10),
      partialResults: false,
    );
  }
}
