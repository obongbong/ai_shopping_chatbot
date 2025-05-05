// lib/services/chat_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tts_service.dart';

class ChatService {
  static const _chatUrl = 'http://192.168.0.86:5000/chat';
  static const _flaskUrl = 'http://192.168.0.86:5000/search';
  static const _nluUrl = 'http://192.168.0.86:5005/model/parse';

  /// Flutter → Rasa NLU parse API
  /// 리턴값: { 'intent': String, 'entities': Map<String,String> }
  static Future<Map<String, dynamic>> parseNLU(String text) async {
    final res = await http.post(
      Uri.parse(_nluUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    if (res.statusCode != 200) {
      throw Exception('NLU parsing failed: ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    // 1) intent 이름
    final intentName =
        (data['intent'] is Map)
            ? (data['intent']['name'] as String)
            : (data['intent'] as String);

    // 2) entities 리스트 → Map<String,String>
    final ents = <String, String>{};
    if (data['entities'] is List) {
      for (var e in data['entities'] as List<dynamic>) {
        final entity = e['entity'] as String?;
        final value = e['value'] as String?;
        if (entity != null && value != null) {
          ents[entity] = value;
        }
      }
    }

    return {'intent': intentName, 'entities': ents};
  }

  /// Flutter → Flask(chat proxy) → Rasa → Flask → Flutter
  static Future<List<Map<String, dynamic>>> sendRawMessage(
    String message, {
    String sender = 'mobile',
  }) async {
    final res = await http.post(
      Uri.parse(_chatUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sender': sender, 'message': message}),
    );
    if (res.statusCode != 200) {
      throw Exception('Chat proxy error: ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['responses'] as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  /// sendRawMessage() 결과에서 text 만 꺼내기
  static Future<List<String>> sendMessage(
    String message, {
    String sender = 'mobile',
  }) => sendRawMessage(message, sender: sender).then(
    (full) =>
        full
            .map((m) => m['text'] as String? ?? '')
            .where((t) => t.isNotEmpty)
            .toList(),
  );

  /// Flask → 크롤링(top3/top5) 결과 가져오기
  static Future<List<Map<String, dynamic>>> fetchTopProductsFromFlask(
    String product,
  ) async {
    final uri = Uri.parse(
      _flaskUrl,
    ).replace(queryParameters: {'product': product.trim()});
    final res = await http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('Flask error: ${res.statusCode}');
    }
    final raw = utf8.decode(res.bodyBytes);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final listData = decoded['top3'] ?? decoded['top5'];
    if (listData is! List) {
      throw Exception('No product data');
    }
    return List<Map<String, dynamic>>.from(listData);
  }

  /// STT → parseNLU → 빠른 TTS → 전체 응답 TTS
  static Future<void> handleSpeechInput(String speech) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      final parsed = await parseNLU(speech);
      final intent = parsed['intent'] as String;
      final ents = parsed['entities'] as Map<String, String>;
      final product = ents['product'];

      // 빠른 피드백
      if (intent == 'search_product' && product != null) {
        await TtsService().speak('$product 상품을 검색 중입니다.');
      } else {
        await TtsService().speak('요청을 처리 중입니다.');
      }

      // 전체 응답
      final full = await sendRawMessage(speech);
      for (var r in full) {
        final t = r['text'] as String?;
        if (t != null && t.isNotEmpty) {
          await TtsService().speak(t);
        }
      }
    } catch (e) {
      await TtsService().speak('서버 연결에 실패했습니다.');
    } finally {
      _isProcessing = false;
    }
  }

  static bool _isProcessing = false;
}
