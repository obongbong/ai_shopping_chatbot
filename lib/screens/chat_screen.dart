// // lib/screens/chat_screen.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_recognition_error.dart';
// import '../services/stt_service.dart';
// import '../services/tts_service.dart';
// import '../services/chat_service.dart';
// import 'search_result.dart';

// class ChatScreen extends StatefulWidget {
//   final String userName;
//   const ChatScreen({Key? key, required this.userName}) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final _controller = TextEditingController();
//   final List<_Msg> _messages = [];
//   bool _sending = false;

//   final SttService _stt = SttService();
//   bool _sttAvailable = false;
//   bool _listening = false;
//   final TtsService _tts = TtsService();

//   @override
//   void initState() {
//     super.initState();
//     _initStt();
//   }

//   Future<void> _initStt() async {
//     final ok = await _stt.init(
//       onStatus: (status) => debugPrint('STT status: $status'),
//       onError: (err) => debugPrint('STT error: ${err.errorMsg}'),
//     );
//     setState(() => _sttAvailable = ok);
//   }

//   Future<void> _startListening() async {
//     if (!_sttAvailable || _listening) return;
//     setState(() => _listening = true);

//     await _stt.listen(
//       onResult: (recognized) {
//         _controller.text = recognized;
//         _send();
//       },
//     );

//     await _stt.stop();
//     setState(() => _listening = false);
//   }

//   Future<void> _send() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty || _sending) return;

//     setState(() {
//       _messages.add(_Msg(text: text, isUser: true));
//       _sending = true;
//       _controller.clear();
//     });

//     final nlu = await ChatService.parseNLU(text);
//     final intent = nlu['intent'] as String?;
//     final product = (nlu['entities'] as Map)['product'] as String?;
//     if (intent == 'search_product' && product != null) {
//       await _tts.speak("‘$product’ 상품을 검색 중입니다.");
//     }

//     try {
//       final replies = await ChatService.sendRawMessage(text);
//       final ttsQueue = <String>[];
//       for (var msg in replies) {
//         if (msg.containsKey('text')) {
//           final botText = msg['text']!;
//           setState(() => _messages.add(_Msg(text: botText, isUser: false)));
//           ttsQueue.add(botText);
//         }
//       }
//       for (var t in ttsQueue) {
//         await _tts.speak(t);
//       }

//       if (intent == 'search_product' && product != null) {
//         final products = await ChatService.fetchTopProductsFromFlask(product);
//         if (!mounted) return;
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (_) => SearchResult(
//                   searchQuery: product,
//                   products: products,
//                   ttsMessages: ttsQueue,
//                 ),
//           ),
//         );
//       }
//     } finally {
//       setState(() => _sending = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('AI 쇼핑 챗봇')),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               padding: const EdgeInsets.all(12),
//               itemCount: _messages.length,
//               itemBuilder: (_, i) {
//                 final m = _messages[_messages.length - 1 - i];
//                 return Align(
//                   alignment:
//                       m.isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 10,
//                       horizontal: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: m.isUser ? Colors.green[200] : Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       m.text ?? '',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Row(
//           children: [
//             IconButton(
//               icon: Icon(_listening ? Icons.mic : Icons.mic_none),
//               onPressed: _startListening,
//             ),
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 onSubmitted: (_) => _send(),
//                 decoration: const InputDecoration(
//                   hintText: '메시지를 입력하거나 마이크를 눌러 말하세요',
//                   contentPadding: EdgeInsets.all(12),
//                 ),
//               ),
//             ),
//             IconButton(
//               icon:
//                   _sending
//                       ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                       : const Icon(Icons.send),
//               onPressed: _sending ? null : _send,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _Msg {
//   final String? text;
//   final bool isUser;
//   _Msg({this.text, required this.isUser});
// }
