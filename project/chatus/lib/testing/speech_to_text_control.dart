// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
//
//
// class SpeechToTextControl with ChangeNotifier {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//
//   bool _isListening = false;
//   bool get isListening => _isListening;
//   set isListening(bool value) {
//     _isListening = value;
//     notifyListeners();
//   }
//   // final StreamController<List<String>> _sentencedController = StreamController();
//   // Stream<List<String>> get sentencedStream => _sentencedController.stream;
//   // List<String> _sentenced = [];
//   // List<String> get sentenced => _sentenced;
//   // set sentenced(List<String> value) {
//   //   _sentenced = value;
//   //   _sentencedController.add(value);
//   //   notifyListeners();
//   // }
//
//   String _recentSentence = '';
//   String get recentSentence => _recentSentence;
//   set recentSentence(String value) {
//     _recentSentence = value;
//     notifyListeners();
//   }
//   Future<bool> init() async{
//     if(isListening){
//       print("이미 듣고있음");
//       return false;
//     }
//     bool available = await _speech.initialize(
//       onStatus: (status) {
//         print('status: $status');
//       },
//       onError: (error) {
//         print('error: $error');
//       },
//     );
//     return available;
//   }
//   void startListen(String localeId) {
//     isListening = true;
//     _speech.listen(
//         localeId: localeId,
//         onResult: (result) {
//           bool b = result.finalResult;
//           String recognizedWords = result.recognizedWords;
//           recentSentence = recognizedWords;
//
//           if (b) {
//             print("FINAL RESULT");
//           }
//         },
//         onSoundLevelChange: (level) {
//           //  print('sound level stream: $level');
//         }
//     );
//   }
//
//   stopListen(){
//     isListening = false;
//     _speech.stop();
//   }
// }
