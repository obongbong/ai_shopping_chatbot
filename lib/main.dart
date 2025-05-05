// lib/main.dart

import 'package:ai_shopping_chatbot/screens/main_screen.dart';
import 'package:ai_shopping_chatbot/widgets/GlobalSttTtsWrapper.dart';
import 'package:flutter/material.dart';

/// ① 전역 NavigatorKey 선언
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// ② 이 키를 MaterialApp 에 넘겨줍니다
      navigatorKey: navigatorKey,
      home: GlobalSttTtsWrapper(child: const HomeScreen(userName: '')),
    );
  }
}
