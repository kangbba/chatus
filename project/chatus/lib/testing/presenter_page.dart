// import 'dart:async';
// import 'dart:io';
// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter/material.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:simple_ripple_animation/simple_ripple_animation.dart';
// import 'package:chatus/managers/speech_to_text_control.dart';
// import 'package:chatus/managers/my_auth_provider.dart';
// import 'package:chatus/custom_widget/simple_dialog.dart';
// import '../managers/text_to_speech_control.dart';
// import '../classes/chat_room.dart';
// import '../classes/language_select_control.dart';
// import '../screens/speech_recognition_popup.dart';
//
// class PresenterPage extends StatefulWidget {
//   final ChatRoom chatRoom;
//   final double presenterSpeakIdleLimit;
//
//   const PresenterPage({Key? key, required this.chatRoom, required this.presenterSpeakIdleLimit}) : super(key: key);
//
//   @override
//   _PresenterPageState createState() => _PresenterPageState();
// }
// class _PresenterPageState extends State<PresenterPage> {
//   SpeechToTextControl speechToTextControl = SpeechToTextControl();
//   final LanguageSelectControl _languageSelectControl = LanguageSelectControl.instance;
//   final MyAuthProvider _authProvider = MyAuthProvider.instance;
//
//   StreamSubscription<LanguageItem>? _languageSubscription;
//   bool recordBtnState = false;
//   StreamSubscription? hostStreamSubscription;
//   LanguageItem? curLangItem;
//   String recentStr = 'speak';
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // initAudioStreamType();
//     speechToTextControl.init();
//     TextToSpeechControl.instance.initTextToSpeech(_languageSelectControl.myLanguageItem);
//     hostStreamSubscription = widget.chatRoom.hostStream().listen((host) {
//       if(_authProvider.curUser == null){
//         print("curUser가 null이 되었다");
//       }
//       if(host.uid != _authProvider.curUser!.uid){
//         print("내가 호스트가 아니게 되었다.");
//       }
//     });
//     curLangItem = _languageSelectControl.myLanguageItem;
//     _languageSubscription = _languageSelectControl.languageItemStream.listen((currentLanguageItem) {
//       print("currentLanguageItem 변경이 감지됨");
//
//       curLangItem = currentLanguageItem;
//       setState(() {
//
//       });
//     });
//   }
//   @override
//   void dispose() {
//     print("presenter page가 dispose됨");
//     recordBtnState = false;
//     speechToTextControl.stopListen();
//
//     if(_languageSubscription != null){
//       _languageSubscription!.cancel();
//     }
//     if(hostStreamSubscription!=null){
//       hostStreamSubscription!.cancel();
//     }
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final fontSize = screenHeight * 0.032; // 디바이스 높이의 3%에 해당하는 폰트 크기
//     final height = screenHeight / 2; // 디바이스 높이의 1/3에 해당하는 height
//     return Column(
//       children: [
//         Expanded(flex : 1, child: Center(child: Text(recentStr, style : TextStyle(fontSize: fontSize),))),
//         _audioRecordBtn()
//       ],
//     );
//   }
//   Widget _audioRecordBtn() {
//     return
//       RippleAnimation(
//           color: Colors.blue,
//           delay: const Duration(milliseconds: 200),
//           repeat: true,
//           minRadius: recordBtnState ? 35 : 0,
//           ripplesCount: 8,
//           duration: const Duration(milliseconds: 6 * 300),
//           child:ElevatedButton(
//             style: ButtonStyle(
//               minimumSize: MaterialStateProperty.all(Size(55, 55)),
//               shape: MaterialStateProperty.all(CircleBorder()),
//               backgroundColor: MaterialStateProperty.all(Colors.redAccent[200] ),
//             ),
//             onPressed: () async {
//               String resultStr = await showVoicePopUp(curLangItem!);
//               widget.chatRoom.addDialogue(curLangItem!.sttLangCode!, resultStr);
//               recentStr = resultStr;
//               setState(() {});
//             },
//             child: recordBtnState ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white) : Icon(Icons.mic, color:  Colors.white, size: 33,),
//           )
//       ) ;
//   }
//
//   Future<String> showVoicePopUp(LanguageItem presentLanguageItem) async {
//
//     String speechStr = await showDialog<String>(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           child: SizedBox(
//             height: 500,
//             child: SpeechRecognitionPopUp(
//                 icon: Icons.mic,
//                 iconColor: Colors.white,
//                 backgroundColor: Colors.blue,
//                 langItem: presentLanguageItem,
//                 fontSize: 26,
//                 titleText: "Please speak now",
//                 onCompleted: () => (),
//                 onCanceled: () async {
//                 }),
//           ),
//         );
//       },
//     ) ??
//         '';
//     return speechStr;
//   }
//
// // listeningRoutine(String langCode) async {
//   //
//   //   speechToTextControl = SpeechToTextControl();
//   //   recentStr = '';
//   //   bool isInitialized = await speechToTextControl.init();
//   //   if(!isInitialized) {
//   //     sayneToast("아직 리스닝이 초기화되지 않았습니다");
//   //     return;
//   //   }
//   //   speechToTextControl.listen(langCode);
//   //   speechToTextControl.recentSentenceStream.listen((recentSentence) {
//   //     setState(() {
//   //       print("갱신중");
//   //       recentStr = recentSentence;
//   //       widget.chatRoom.updatePresentation(langCode, recentStr);
//   //     });
//   //   });
//   // }
//
// }
