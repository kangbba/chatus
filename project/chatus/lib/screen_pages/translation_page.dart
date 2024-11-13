// import 'dart:async';
// import 'dart:ui';
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:provider/provider.dart';
// import 'package:simple_ripple_animation/simple_ripple_animation.dart';
// import 'package:chatus/managers/text_to_speech_control.dart';
// import 'package:chatus/custom_widget/sayne_separator.dart';
// import 'package:chatus/screen_pages/presenter_page.dart';
//
// import '../custom_widget/sayne_dialogs.dart';
// import '../managers/my_auth_provider.dart';
// import '../managers/chat_provider.dart';
// import '../managers/speech_to_text_control.dart';
// import '../managers/translate_by_googleserver.dart';
// import '../classes/chat_room.dart';
// import '../classes/language_select_control.dart';
// import '../classes/dialogue.dart';
// import '../screens/language_select_screen.dart';
// import '../custom_widget/auto_scrollable_text.dart';
//
// class TranslationPage extends StatefulWidget {
//   const TranslationPage({Key? key}) : super(key: key);
//
//   @override
//   State<TranslationPage> createState() => _TranslationPageState();
// }
//
// class _TranslationPageState extends State<TranslationPage> {
//
//   SpeechToTextControl speechToTextControl = SpeechToTextControl();
//   final _authProvider = MyAuthProvider.instance;
//   final _chatProvider = ChatProvider.instance;
//
//   bool recordBtnState = false;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return _audioRecordBtn();
//   }
//
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
//               setState(() {
//                 recordBtnState = !recordBtnState;
//                 if(recordBtnState){
//                   listeningLoopingRoutine();
//                 }
//                 else{
//                 }
//               });
//             },
//             child: recordBtnState ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white) : Icon(Icons.mic, color:  Colors.white, size: 33,),
//           )
//       ) ;
//   }
//   listeningLoopingRoutine() async{
//
//   }
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     recordBtnState = false;
//     super.dispose();
//   }
//
// }
