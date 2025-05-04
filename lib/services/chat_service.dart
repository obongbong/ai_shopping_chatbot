import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // Flutter → Flask (chat proxy) 엔드포인트
  static const _chatUrl = 'http://192.168.0.86:5000/chat';
  // Flask 백엔드에서 크롤링 결과를 가져오는 엔드포인트
  static const _flaskUrl = 'http://192.168.0.86:5000/search';
  // Rasa NLU 파싱 엔드포인트
  static const _nluUrl = 'http://192.168.0.86:5005/model/parse';

  /// Rasa NLU로부터 intent와 product 엔티티 반환
  static Future<Map<String, dynamic>> parseNLU(String text) async {
    final response = await http.post(
      Uri.parse(_nluUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    if (response.statusCode != 200) {
      throw Exception('NLU parsing failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final intentName =
        (data['intent'] as Map<String, dynamic>)['name'] as String?;

    final entitiesList = data['entities'] as List<dynamic>;
    String? product;
    for (final ent in entitiesList) {
      if (ent['entity'] == 'product') {
        product = ent['value'] as String?;
        break;
      }
    }

    return {
      'intent': intentName,
      'entities': {'product': product},
    };
  }

  /// 구버전 호환: Rasa NLU로부터 product 엔티티만 빠르게 추출
  static Future<String?> parseProductEntity(String text) async {
    final res = await http.post(
      Uri.parse(_nluUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    if (res.statusCode != 200) return null;
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final entities = json['entities'] as List<dynamic>;
    final prod = entities.firstWhere(
      (e) => e['entity'] == 'product',
      orElse: () => null,
    );
    return prod != null ? prod['value'] as String : null;
  }

  /// 메시지 전송 (Flutter → Flask → Rasa → Flask → Flutter)
  static Future<List<Map<String, dynamic>>> sendRawMessage(
    String message, {
    String sender = 'mobile',
  }) async {
    final response = await http.post(
      Uri.parse(_chatUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sender': sender, 'message': message}),
    );
    if (response.statusCode != 200) {
      throw Exception('Chat proxy error ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['responses'] as List<dynamic>;
    return list.map((t) => {'text': t as String}).toList();
  }

  /// Flask 백엔드에서 topN 크롤링 결과 가져오기
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
    if (listData == null || listData is! List) {
      throw Exception('No top data found');
    }
    return List<Map<String, dynamic>>.from(listData);
  }

  /// Rasa 응답 중 텍스트만 추출
  static Future<List<String>> sendMessage(
    String message, {
    String sender = 'mobile',
  }) async {
    final full = await sendRawMessage(message, sender: sender);
    return full
        .map<String>((m) {
          if (m.containsKey('text')) return m['text'] as String;
          if (m.containsKey('image')) return '[이미지] ${m['image']}';
          return '';
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
