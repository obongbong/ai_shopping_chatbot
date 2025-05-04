// main.dart
import 'package:ai_shopping_chatbot/screens/STTTestScreen.dart';
import 'package:ai_shopping_chatbot/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'STT Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      //home: STTTestScreen(), // 여기에서 테스트 화면을 실행
      home: const HomeScreen(userName: ''), // ✅ STT 적용된 메인 화면으로 실행
    );
  }
}
