// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:chatus/classes/language_select_control.dart';
// import 'package:flutter/services.dart';
//
// class TextToSpeechControl extends ChangeNotifier{
//
//   static TextToSpeechControl? _instance;
//   static TextToSpeechControl get instance {
//     _instance ??= TextToSpeechControl();
//     return _instance!;
//   }
//   FlutterTts flutterTts = FlutterTts();
//   initTextToSpeech(LanguageItem languageItem) async
//   {
//     audioSpeakMode(false);
//     await flutterTts.setSharedInstance(true);
//     changeLanguage(languageItem);
//   }
//
//   audioSpeakMode(bool b) async{
//     bool isIOS = Platform.isIOS;
//     if(b){
//       print("스피크 모드 시작");
//       if(isIOS){
//         try{
//           await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambient,
//               [
//                 IosTextToSpeechAudioCategoryOptions.allowBluetooth,
//                 IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
//                 IosTextToSpeechAudioCategoryOptions.mixWithOthers
//               ],
//               IosTextToSpeechAudioMode.videoChat
//           );
//           // await flutterTts.setVolume(1.0); // TTS 음성 볼륨을 최대로 설정
//           await flutterTts.setPitch(1.0);
//           await flutterTts.setSpeechRate(0.5);
//         }
//         catch(e){
//           print("audio setting error : $e");
//         }
//       }
//       else{
//         // await flutterTts.setVolume(1.0); // TTS 음성 볼륨을 최대로 설정
//         await flutterTts.setPitch(1.0);
//         await flutterTts.setSpeechRate(0.5);
//       }
//     }
//     else{
//       print("스피크 모드 중단");
//       await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambientSolo,
//           [
//             IosTextToSpeechAudioCategoryOptions.allowBluetooth,
//             IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
//             IosTextToSpeechAudioCategoryOptions.mixWithOthers
//           ],
//           IosTextToSpeechAudioMode.defaultMode
//       );
//     }
//   }
//   changeLanguage(LanguageItem languageItem) async
//   {
//     await flutterTts.setLanguage(languageItem.ttsLangCode);
//     // 사용 가능한 음성 목록 가져오기
//     List<dynamic>? totalVoices = await flutterTts.getVoices;
//     if(totalVoices == null || totalVoices.isEmpty){
//       print('totalVoices가 없어서 아무것도 하지않습니다');
//     }
//     List<dynamic>? availableVoices = [];
//     totalVoices?.forEach((voice) {
//       if (voice['locale'] == languageItem.ttsLangCode) {
//         availableVoices.add(voice);
//       }
//     });
//     if(availableVoices.isEmpty){
//       print("사용가능한 목소리가 없음");
//       return;
//     }
//     print("총 목소리갯수 ${totalVoices!.length}");
//     print("총 가능한 목소리갯수 ${availableVoices!.length}");
//     for(int i = 0 ; i < availableVoices.length ; i++){
//       print(availableVoices[i]);
//     }
//     await flutterTts.setLanguage(languageItem.ttsLangCode);
//
//     Map<String, String> selectedVoice;
//     String ttsVoiceCode = Platform.isIOS ? languageItem.iosTtsVoice : languageItem.androidTtsVoice;
//     if(Platform.isIOS){
//     }
//     else{
//       print(availableVoices);
//       if(ttsVoiceCode!.isEmpty){
//         selectedVoice = {
//           'name': availableVoices.first['name'],
//           'locale': availableVoices.first['locale'],
//         };
//         print("해당 정보 없으므로, 마지막 정보로 selected : $selectedVoice");
//         await flutterTts.setVoice(selectedVoice);
//       }
//       else{
//         selectedVoice = {
//           'name': ttsVoiceCode,
//           'locale': languageItem.ttsLangCode,
//         };
//         print("커스텀 정보 있으므로, 마지막 정보로 selected : $selectedVoice");
//         await flutterTts.setVoice(selectedVoice);
//       }
//     }
//
//     // voices?.forEach((voice) {
//     //   if (voice['locale'] == manipulatedLangCode) {
//     //     print(voice);
//     //   }
//     // });
//
//     // if (voices == null) {
//     //   return;
//     // }
//     // // 남성 목소리 선택
//     // Map<String, String>? maleVoiceMap = voices.firstWhere((voice) => voice["gender"] == "male", orElse: () => null);
//     // print(maleVoiceMap);
//     // if (maleVoiceMap == null) {
//     //   return;
//     // }
//     // // 남성 목소리로 변경
//     // await flutterTts.setVoice(maleVoiceMap);
//   }
//   speak(String str, bool useWaiting) async {
//
//     if(Platform.isIOS){
//       await audioSpeakMode(true);
//       await flutterTts.speak(str);
//       await flutterTts.awaitSpeakCompletion(useWaiting);
//       await audioSpeakMode(false);
//     }
//     else{
//       await flutterTts.speak(str);
//       await flutterTts.awaitSpeakCompletion(useWaiting);
//     }
//     print("음성 재생이 실제로 완료됨");
//   }
// }