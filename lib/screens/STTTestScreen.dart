import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class STTTestScreen extends StatefulWidget {
  @override
  _STTTestScreenState createState() => _STTTestScreenState();
}

class _STTTestScreenState extends State<STTTestScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _speechEnabled = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    // permission_handler 대신 STT initialize 에 위임
    _speechEnabled = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (err) => debugPrint('Speech error: $err'),
    );
    setState(() {});
  }

  void _startListening() async {
    if (!_speechEnabled) return;
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: 'ko_KR',
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STT Test Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: _speech.isListening ? '음성 인식 중...' : '여기에 텍스트가 표시됩니다',
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _recognizedText),
            ),
            const SizedBox(height: 20),
            IconButton(
              iconSize: 48,
              icon: Icon(_speech.isListening ? Icons.mic : Icons.mic_none),
              onPressed: _speech.isListening ? _stopListening : _startListening,
            ),
          ],
        ),
      ),
    );
  }
}
