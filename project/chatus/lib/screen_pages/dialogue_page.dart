import 'dart:async';
import 'package:chatus/classes/room_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import '../classes/chat_room.dart';
import '../classes/dialogue.dart';
import '../classes/user_model.dart';
import '../custom_widget/dialogue_tile.dart';
import '../managers/my_auth_provider.dart';
import '../managers/translate_by_googleserver.dart';
import '../classes/language_select_control.dart';
import '../screens/speech_recognition_popup.dart';

class DialoguePage extends StatefulWidget {
  final ChatRoom chatRoom;
  const DialoguePage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<DialoguePage> createState() => _AudiencePageState();
}

class _AudiencePageState extends State<DialoguePage> {
  final MyAuthProvider authProvider = MyAuthProvider.instance;
  final LanguageSelectControl languageSelectControl = LanguageSelectControl.instance;
  final TranslateByGoogleServer googleTranslator = TranslateByGoogleServer();
  final FlutterTts tts = FlutterTts();

  StreamSubscription<List<Dialogue>>? _dialogueSubscription;
  Map<String, Map<String, String>> translatedDialogues = {}; // 번역된 텍스트와 언어 코드 저장
  List<Dialogue> dialogues = [];
  ScrollController _scrollController = ScrollController();

  StreamSubscription<LanguageItem>? _languageSubscription;
  LanguageItem? curLangItem;

  bool isLoading = true;
  bool isRecordingBtnPressed = false;

  @override
  void initState() {
    super.initState();
    googleTranslator.initializeTranslateByGoogleServer();
    initializeLanguages();
    initializeDialogues(languageSelectControl.myLanguageItem);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dialogueSubscription?.cancel();
    _languageSubscription?.cancel();
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  // 스크롤 리스너에서 maxScrollExtent의 변화를 감지하고 scrollToEnd 호출
  void _scrollListener() {
    debugPrint('Scroll position: ${_scrollController.position.pixels}');
    debugPrint('extentAfter: ${ _scrollController.position.extentAfter}');
    debugPrint('Max Scroll extent: ${_scrollController.position.maxScrollExtent}');
    debugPrint('Scroll direction: ${_scrollController.position.userScrollDirection}');
  }

  void scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // void scrollToEnd() {
  //   if (_scrollController.hasClients) {
  //     SchedulerBinding.instance.addPostFrameCallback((_) {
  //       _scrollController.animateTo(_scrollController.position.maxScrollExtent);
  //     });
  //   }
  // }







  // Languages
  Future<void> initializeLanguages() async {
    try {
      curLangItem = languageSelectControl.myLanguageItem;
    } catch (e) {
      debugPrint("AudiencePage: Error loading initializeLanguages - $e");
    }
    tts.setLanguage(languageSelectControl.myLanguageItem.ttsLangCode);
    setState(() {});
    listenToLanguageChanges();
  }

  void listenToLanguageChanges() {
    _languageSubscription = languageSelectControl.languageItemStream.listen((languageItem) async {
      curLangItem = languageItem;
      translatedDialogues.clear(); // 언어 변경 시 기존 번역 내용 초기화
      tts.setLanguage(languageItem.ttsLangCode);
      await translateAllDialogues(languageItem.langCodeGoogleServer); // 전체 번역 수행
      setState(() {});
    });
  }

  void sortDialoguesByCreatedAt(List<Dialogue> dialogues) {
    dialogues.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Dialogues
  Future<void> initializeDialogues(LanguageItem? initialLanguageItem) async {
    try {
      dialogues = await widget.chatRoom.dialoguesStream().first;
      sortDialoguesByCreatedAt(dialogues);
      isLoading = false;
      await translateAllDialogues(initialLanguageItem?.langCodeGoogleServer);
      listenToDialogueStream();
      setState(() {});
    } catch (e) {
      debugPrint("AudiencePage: Error loading initial dialogues - $e");
    }
  }

  void listenToDialogueStream() {
    _dialogueSubscription = widget.chatRoom.dialoguesStream().listen(
          (dialogueList) async {
        final currentIds = dialogues.map((d) => d.id).toSet();
        final newDialogues = dialogueList.where((d) => !currentIds.contains(d.id)).toList();

        if (newDialogues.isNotEmpty) {
          String? curLangCode = curLangItem?.langCodeGoogleServer;
          sortDialoguesByCreatedAt(newDialogues);
          dialogues.addAll(newDialogues);
          debugPrint("AudiencePage: New dialogues received, count: ${newDialogues.length}");

          debugPrint("Translation request count: ${newDialogues.length}");
          String lastTranslation = '';
          for (var dialogue in newDialogues) {
            lastTranslation = await translateDialogue(dialogue, curLangCode!);
          }
          if (lastTranslation.isNotEmpty) {
            debugPrint("tts to speak : ${lastTranslation}");
            bool isMyDialogue = newDialogues.last.ownerUid == authProvider.curUserModel?.uid;
            await tts.setVolume(isMyDialogue ? RoomSettings().myVolume : RoomSettings().otherVolume);
            tts.speak(lastTranslation);
          }
          scrollToEnd();
        }
      },
      onError: (error) {
        debugPrint("AudiencePage: Error in dialogue stream - $error");
      },
      onDone: () {
        debugPrint("AudiencePage: Dialogue stream closed.");
      },
    );
  }

  // 개별 대화 번역 수행
  Future<String> translateDialogue(Dialogue dialogue, String targetLangCode) async {
    final translatedData = translatedDialogues[dialogue.id];

    if (translatedData != null && translatedData['langCode'] == targetLangCode) {
      return dialogue.content;
    }

    try {
      final translation = await googleTranslator.textTranslate(dialogue.content, targetLangCode);
      translatedDialogues[dialogue.id] = {
        'text': translation ?? dialogue.content,
        'langCode': targetLangCode
      };
      return translation ?? '';
    } catch (e) {
      debugPrint("Translation error for '${dialogue.content}': $e");
      translatedDialogues[dialogue.id] = {
        'text': dialogue.content,
        'langCode': dialogue.langCode
      };

      return dialogue.content;
    }
  }

  // 전체 대화 번역 수행
  Future<void> translateAllDialogues(String? targetLangCode) async {
    if (targetLangCode == null) return;

    debugPrint("Translation request count: ${dialogues.length}");
    for (var dialogue in dialogues) {
      await translateDialogue(dialogue, targetLangCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: scrollToEnd,
        child: const Icon(Icons.arrow_downward),
      ),
      body: Column(
        children: [
          Expanded(
            child: dialogues.isEmpty
                ? const Center(child: Text('대화 내역이 없습니다'))
                : ListView.builder(
              controller: _scrollController,
              itemCount: dialogues.length,
              itemBuilder: (context, index) {
                final dialogue = dialogues[index];
                final translatedData = translatedDialogues[dialogue.id];
                final translatedText = translatedData?['text'] ?? dialogue.content;
                final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dialogue.createdAt);

                return FutureBuilder<UserModel?>(
                  future: widget.chatRoom.getUserByUid(dialogue.ownerUid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(height: 100,);
                    }

                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return SizedBox(height: 100,);
                    }

                    final userModel = snapshot.data!;
                    return DialogueTile(
                      isMine: dialogue.ownerUid == authProvider.curUserModel?.uid,
                      userModel: userModel,
                      text: translatedText,
                      date: formattedDate,
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 70,
            child: _audioRecordBtn(),
          ),
        ],
      ),
    );
  }

  Widget _audioRecordBtn() {
    return RippleAnimation(
      color: Colors.blue,
      delay: const Duration(milliseconds: 200),
      repeat: true,
      minRadius: isRecordingBtnPressed ? 35 : 0,
      ripplesCount: 8,
      duration: const Duration(milliseconds: 6 * 300),
      child: ElevatedButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(55, 55)),
          shape: MaterialStateProperty.all(CircleBorder()),
          backgroundColor: MaterialStateProperty.all(Colors.redAccent),
        ),
        onPressed: () async {
          try {
            if (authProvider.curUserModel == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("오류: 로그인 상태가 아닙니다. 로그인 후 시도해주세요.")),
              );
              return;
            }

            if (curLangItem == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("오류: 언어 설정이 선택되지 않았습니다.")),
              );
              return;
            }

            String resultStr = await showVoicePopUp(curLangItem!);
            if (resultStr.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("오류: 녹음된 내용이 없습니다.")),
              );
              return;
            }

            await widget.chatRoom.addDialogue(
              authProvider.curUserModel!.uid,
              curLangItem!.sttLangCode!,
              resultStr,
            );

            setState(() {});
          } catch (e) {
            debugPrint("AudioRecordBtn: Error adding dialogue - $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("오류: 대화를 추가하는 중 문제가 발생했습니다.")),
            );
          }
        },
        child: isRecordingBtnPressed
            ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white)
            : Icon(Icons.mic, color: Colors.white, size: 33),
      ),
    );
  }

  Future<String> showVoicePopUp(LanguageItem languageItem) async {
    String speechStr = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            height: 500,
            child: SpeechRecognitionPopUp(
                icon: Icons.mic,
                iconColor: Colors.white,
                backgroundColor: Colors.blue,
                langItem: languageItem,
                fontSize: 26,
                titleText: "Please speak now",
                onCompleted: () => (),
                onCanceled: () async {}),
          ),
        );
      },
    ) ?? '';
    return speechStr;
  }
}
