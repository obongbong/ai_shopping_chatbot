// lib/widgets/global_stt_tts_wrapper.dart

import 'package:ai_shopping_chatbot/main.dart';
import 'package:flutter/material.dart';
import 'package:ai_shopping_chatbot/services/audio_service.dart';
import 'package:ai_shopping_chatbot/services/chat_service.dart';
import 'package:ai_shopping_chatbot/services/tts_service.dart';
import 'package:ai_shopping_chatbot/screens/search_result.dart';

class GlobalSttTtsWrapper extends StatefulWidget {
  final Widget child;
  const GlobalSttTtsWrapper({Key? key, required this.child}) : super(key: key);

  static _GlobalSttTtsWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<_GlobalSttTtsWrapperState>();
  }

  @override
  State<GlobalSttTtsWrapper> createState() => _GlobalSttTtsWrapperState();
}

class _GlobalSttTtsWrapperState extends State<GlobalSttTtsWrapper> {
  final TtsService _tts = TtsService();
  bool _isListening = false;

  /// 실제 봇 응답(빠른 피드백 제외) 개수
  int _pendingTts = 0;

  /// 빠른 피드백 완료 이벤트를 무시할 플래그
  bool _suppressNextComplete = false;

  @override
  void initState() {
    super.initState();

    // TTS가 시작되면 STT 중지
    _tts.onStart = () {
      debugPrint('🛑 [Wrapper] TTS 시작 — STT 중지');
      AudioService().stopListening();
      setState(() => _isListening = false);
    };

    // TTS 완료 콜백
    _tts.onComplete = () {
      if (_suppressNextComplete) {
        // 빠른 피드백 끝난 거면 무시
        _suppressNextComplete = false;
        debugPrint('🔵 [Wrapper] 빠른 피드백 완료 — 무시');
        return;
      }

      debugPrint('🔴 [Wrapper] onComplete 호출 — 남은 발화: $_pendingTts');
      _pendingTts--;
      if (_pendingTts <= 0) {
        debugPrint('✅ [Wrapper] 모든 TTS 완료 — 1초 뒤 STT 재시작');
        Future.delayed(const Duration(seconds: 1), _startListening);
      }
    };
  }

  /// 외부에서 호출 가능한 공개 메서드
  void startListening() => _startListening();

  /// STT 시작 로직
  void _startListening() {
    if (_isListening) return;
    debugPrint('🎙 [Wrapper] STT 시작');
    setState(() => _isListening = true);

    AudioService.listenFor(
      onResult: (text) async {
        debugPrint('🛑 [Wrapper] STT 결과 수신 → "$text"');
        await AudioService().stopListening();
        setState(() => _isListening = false);
        await _handleResult(text);
      },
      onStatus: (status) => debugPrint('📡 [Wrapper] STT status: $status'),
    );
  }

  /// STT → NLU → TTS → 화면 전환
  Future<void> _handleResult(String speechText) async {
    // 1) NLU 파싱
    final nlu = await ChatService.parseNLU(speechText);
    final intent = nlu['intent'] as String?;
    final product = (nlu['entities'] as Map)['product'] as String?;

    // 2) 빠른 피드백 (await, 그리고 다음 complete 무시)
    final quickText =
        (intent == 'search_product' && product != null)
            ? '$product 상품을 검색 중입니다.'
            : '요청을 처리 중입니다.';
    _suppressNextComplete = true;
    await _tts.speak(quickText);

    // 3) 실제 봇 응답
    final replies = await ChatService.sendRawMessage(speechText);

    // 4) search_product → 첫 답변만, 그 외 전부
    final toSpeak =
        (intent == 'search_product' && product != null && replies.isNotEmpty)
            ? [replies.first]
            : replies;

    // 5) pendingTts는 실제 speak() 호출할 개수
    _pendingTts = toSpeak.length;
    debugPrint('🎤 [Wrapper] 실제 읽을 TTS 발화 수: $_pendingTts');

    // 6) 나머지 답변들 speak() 호출 (await 없이)
    for (var r in toSpeak) {
      final t = r['text'] as String?;
      if (t != null && t.isNotEmpty) {
        _tts.speak(t);
      } else {
        // 빈 텍스트면 즉시 카운트 감소
        _pendingTts--;
      }
    }

    // (7) 화면 전환 (search_product)
    if (intent == 'search_product' && product != null && mounted) {
      final products = await ChatService.fetchTopProductsFromFlask(product);

      // 전역 navigatorKey 를 통해 푸시
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (_) => SearchResult(searchQuery: product, products: products),
        ),
      );
    }
    // → onComplete 콜백이 남은 _pendingTts 를 모두 처리한 뒤 STT 재시작됩니다.
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isListening)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🎙 음성 인식 중...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
