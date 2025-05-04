// lib/services/google_tts_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class GoogleTtsService {
  static const _apiKey = 'AIzaSyDSBW4CEi4LN3V2GQUWhfY592sd51mcD7Q';
  static const _url =
      'https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey';

  final AudioPlayer _player = AudioPlayer();

  Future<void> speak(String text) async {
    final payload = {
      'input': {'text': text},
      'voice': {'languageCode': 'ko-KR', 'ssmlGender': 'FEMALE'},
      'audioConfig': {'audioEncoding': 'MP3'},
    };
    debugPrint('TTS payload: $payload');

    final res = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(payload),
    );
    debugPrint('TTS status: ${res.statusCode}');
    debugPrint('TTS body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Google TTS error ${res.statusCode}: ${res.body}');
    }

    final audioContent = jsonDecode(res.body)['audioContent'] as String;
    final bytes = base64Decode(audioContent);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tts.mp3');
    await file.writeAsBytes(bytes);

    await _player.setFilePath(file.path);
    await _player.play();
    // 재생 완료까지 대기
    await _player.processingStateStream.firstWhere(
      (state) => state == ProcessingState.completed,
    );
  }
}
