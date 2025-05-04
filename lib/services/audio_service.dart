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
        debugPrint('STT status: $status');
        if (status == 'notListening' || status == 'done') {
          _isListening = false;
        }
      },
      onError: (err) {
        debugPrint('STT error: $err');
        if (err.errorMsg == 'error_no_match' || err.errorMsg == 'error_busy') {
          _isListening = false;
        }
      },
    );

    if (!_initialized) {
      debugPrint('STT 초기화 실패: 권한을 허용했는지 확인하세요.');
    }
  }

  void startListening() {
    if (!_initialized || _isListening) return;
    _startListening();
  }

  Future<void> _startListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      await Future.delayed(const Duration(seconds: 1));
    }

    try {
      _isListening = true;
      await _speech.listen(
        onResult: (val) {
          if (val.finalResult) {
            _controller.add(val.recognizedWords);
            _isListening = false;
          }
        },
        localeId: 'ko_KR',
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 10),
        partialResults: false,
      );
    } catch (e) {
      _isListening = false;
      debugPrint('STT start error: $e');
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

  // ✅ 새로 추가된 정적 메서드
  static Future<void> listenFor({
    required Function(String) onResult,
    Function(String)? onStatus,
  }) async {
    final instance = AudioService();
    await instance.init();

    // 수동으로 status 이벤트도 전달하려면 stream 구독을 직접 처리
    instance._speech.statusListener = (status) {
      debugPrint('STT status: $status');
      if (onStatus != null) onStatus(status);
    };

    instance._speech.listen(
      onResult: (val) {
        if (val.finalResult) {
          onResult(val.recognizedWords);
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
