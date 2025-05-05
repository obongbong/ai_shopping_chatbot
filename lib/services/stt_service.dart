// // lib/services/stt_service.dart
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:speech_to_text/speech_recognition_error.dart';

// class SttService {
//   SttService._internal() {
//     _stt = SpeechToText();
//   }
//   late final SpeechToText _stt;

//   static final SttService _instance = SttService._internal();
//   factory SttService() => _instance;

//   bool get isAvailable => _stt.isAvailable;
//   bool get isListening => _stt.isListening;

//   Future<bool> init({
//     required void Function(String status) onStatus,
//     required void Function(SpeechRecognitionError err) onError,
//   }) async {
//     return await _stt.initialize(onStatus: onStatus, onError: onError);
//   }

//   Future<void> listen({
//     required void Function(String recognizedText) onResult,
//     Duration listenFor = const Duration(seconds: 30),
//     Duration pauseFor = const Duration(seconds: 5),
//   }) async {
//     await _stt.listen(
//       onResult: (result) {
//         if (result.finalResult) {
//           onResult(result.recognizedWords);
//         }
//       },
//       listenFor: listenFor,
//       pauseFor: pauseFor,
//       localeId: 'ko_KR',
//     );
//   }

//   Future<void> stop() => _stt.stop();
// }
