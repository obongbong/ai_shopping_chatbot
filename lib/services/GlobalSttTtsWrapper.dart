// lib/widgets/global_stt_tts_wrapper.dart
import 'package:flutter/material.dart';
import 'package:ai_shopping_chatbot/services/audio_service.dart';
import 'package:ai_shopping_chatbot/services/chat_service.dart';
import 'package:ai_shopping_chatbot/services/tts_service.dart';
import 'package:ai_shopping_chatbot/screens/search_result.dart';

class GlobalSttTtsWrapper extends StatefulWidget {
  final Widget child;
  const GlobalSttTtsWrapper({super.key, required this.child});

  @override
  State<GlobalSttTtsWrapper> createState() => _GlobalSttTtsWrapperState();
}

class _GlobalSttTtsWrapperState extends State<GlobalSttTtsWrapper> {
  final TtsService _tts = TtsService();

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    AudioService.listenFor(
      onResult: _handleResult,
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          Future.delayed(Duration(seconds: 1), _startListening);
        }
      },
    );
  }

  Future<void> _handleResult(String speechText) async {
    final replies = await ChatService.sendRawMessage(speechText);

    for (var reply in replies) {
      if (reply['text'] != null) {
        await _tts.speak(reply['text']);
      }
    }

    final intent =
        replies.firstWhere(
          (r) => r['intent'] != null,
          orElse: () => {},
        )['intent'];
    final product =
        replies.firstWhere(
          (r) => r['product'] != null,
          orElse: () => {},
        )['product'];

    if (intent == 'search_product' && product != null) {
      final products = await ChatService.fetchTopProductsFromFlask(product);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => SearchResult(
                searchQuery: product,
                products: products,
                ttsMessages:
                    replies.map<String>((r) => r['text'] ?? '').toList(),
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
