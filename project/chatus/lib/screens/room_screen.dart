
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatus/helper/colors.dart';
import 'package:chatus/custom_widget/sayne_dialogs.dart';
import 'package:chatus/testing/presenter_page.dart';
import 'package:chatus/custom_widget/profile_circle.dart';
import 'package:chatus/custom_widget/user_speakspeed_slider.dart';

import '../testing/text_to_speech_control.dart';
import '../managers/my_auth_provider.dart';
import '../managers/chat_provider.dart';
import '../classes/chat_room.dart';
import '../classes/language_select_control.dart';
import '../classes/user_model.dart';
import '../custom_widget/sayne_separator.dart';
import '../screen_pages/language_select_screen_btn.dart';
import 'language_select_screen.dart';
import '../screen_pages/dialogue_page.dart';
import '../screen_pages/room_displayer.dart';
class RoomScreen extends StatefulWidget {
  RoomScreen({Key? key, required this.chatRoomToLoad}) : super(key: key);
  ChatRoom chatRoomToLoad;
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _authProvider = MyAuthProvider.instance;
  final _chatProvider = ChatProvider.instance;
  final LanguageSelectControl _languageSelectControl = LanguageSelectControl.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double _presenterSpeakIdleLimit = 2000;

  ChatRoom? chatRoom;
  bool isRoomDisplayerOpen = false;
  Stream<UserModel>? _hostStream;

  @override
  void deactivate() {
    // 작업 수행
    // 다른 위젯이 현재 위젯을 덮을 때
    // 전체 화면 다이얼로그 또는 알림이 표시될 때
    // 앱이 백그라운드로 이동할 때
    // 다른 위젯으로 전환되거나 앱이 종료될 때
    print("앱이 비활성화됨");
    super.deactivate();
  }
  initializeChatRoom() async {
    UserModel userModel = UserModel.fromFirebaseUser(_authProvider.curUser!);

    //참가 처리
    final isJoined = await widget.chatRoomToLoad.joinRoom(userModel);
    simpleToast("방 로드 ${isJoined ? "성공" : "실패"}");
    chatRoom = isJoined ? widget.chatRoomToLoad : null;
    setState(() {

    });
    // chatRoom이 null이면 이전 화면으로 돌아갑니다.
    if (chatRoom == null) {
        await sayneConfirmDialog(context, "" , "방 로드 실패");
       Navigator.pop(context);
    }
    else{
      _hostStream = chatRoom!.hostStream();
    }

    setState(() {

    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeChatRoom();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (chatRoom == null) {
      return loading("Loading..");
    }
    if( _authProvider.curUserModel == null){
      return loading("로그인 필요");
    }
    return MultiProvider(
      providers: [
        StreamProvider<List<UserModel>>(
          create: (_) => chatRoom!.userModelsStream,
          initialData: [],
        ),
        StreamProvider<UserModel>(
          create: (_) => _hostStream,
          initialData: chatRoom!.host,
        ),
        ListenableProvider<LanguageSelectControl>(
          create: (_) => _languageSelectControl,
        ),
      ],
      child: Consumer2<List<UserModel>, UserModel>(
        builder: (_, userModelsSnapshot, hostUserModel, __) {
          if (userModelsSnapshot.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: ColorManager.color_standard,
                title: Text(chatRoom!.name),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          UserModel curUserModel = _authProvider.curUserModel!;
          final isCurUserHost = hostUserModel.uid == curUserModel.uid;

          return WillPopScope(
            onWillPop: () async {
              if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
                Navigator.of(context).pop();
                return false;
              } else {
                return true;
              }
            },
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: ColorManager.color_standard,
                title: StreamBuilder<List<UserModel>>(
                  stream: chatRoom?.userModelsStream, // 실시간으로 멤버 변화를 감지
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // 로딩 중일 때 표시할 텍스트
                      return Text("${chatRoom?.name} (...)");
                    } else if (snapshot.hasError) {
                      // 오류 발생 시 표시할 텍스트
                      return Text("${chatRoom?.name} (..)");
                    } else {
                      // 멤버 수를 정상적으로 가져왔을 때
                      final memberCount = snapshot.data?.length ?? 0;
                      return Text("${chatRoom?.name} ($memberCount)");
                    }
                  },
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => onBackPressed(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),

              endDrawer: roomDrawer(context, isCurUserHost),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: Column(
                        children:
                        [
                          const SimpleSeparator(color: Colors.black54, height: 0.3, top: 0, bottom: 0),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Container(
                        child : DialoguePage(chatRoom: chatRoom!)
                      )
                    ),

                    const SimpleSeparator(color: Colors.black54, height: 0.3, top: 8, bottom: 16),
                    SizedBox(
                      height: 60,
                      child: LanguageSelectScreenButton(isHost: isCurUserHost,),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget roomDrawer(BuildContext context, bool isHost) {
    return SafeArea(
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // 스크롤 가능한 리스트뷰 내용
                    SimpleSeparator(color: Colors.black, height: 0, top: 8, bottom: 8),
                    Text(chatRoom!.name, style: TextStyle(fontSize: 16),),
                    SimpleSeparator(color: Colors.black, height: 0.2, top: 8, bottom: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(children: const [
                        Icon(Icons.people, color: Colors.black45,),
                        Text(" 참여자" ,style: TextStyle(fontSize: 15),
                        )]
                      ),
                    ),
                    SizedBox(height: 8,),
                    RoomDisplayer(chatRoom: chatRoom!),
                    SimpleSeparator(color: Colors.black54, height: 0.3, top: 8, bottom: 8),
                    // ...
                  ],
                ),
              ),
            ),
            // 고정된 ListTile
            isHost ?
            UserSpeakSpeedSlider(
              presenterSpeakIdleLimit: _presenterSpeakIdleLimit,
              onChanged: (double value) {
                setState(() {
                  _presenterSpeakIdleLimit = value;
                });
              },
            ) : Container(),
            ListTile(
              tileColor: Colors.black12,
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Exit Classroom"),
              onTap: () => _onPressedExitRoom(context),
            ),
          ],
        ),
      ),
    );
  }


  void onBackPressed(BuildContext context){
    Navigator.pop(context);

  }
  Scaffold loading(String str) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: ColorManager.color_standard,
      ),

      body: Center(
        child: Text(str),
      ),
    );
  }


  _onPressedExitRoom(BuildContext context) async{
    if(_authProvider.curUserModel == null){
      simpleToast("curUserModel null");
      return;
    }
    bool? confirmation = await sayneAskDialog(context, "", "이 채팅방에서 나가시겠습니까?");
    UserModel user = _authProvider.curUserModel!;
    if(confirmation == true){
      await chatRoom!.exitRoom(user);
      if(mounted) {
        onBackPressed(context);
      }
    }
  }

  Widget languageSelectScreenBtn(bool isHost) {
    return Consumer<LanguageSelectControl>(
      builder: (context, languageSelectControl, child) {
        return Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              late LanguageSelectScreen myLanguageSelectScreen =
              LanguageSelectScreen(
                isHost: isHost,
                languageSelectControl: languageSelectControl,
              );
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0),
                      child: myLanguageSelectScreen,
                    ),
                  );
                },
              );
              setState(() {

              });
            },
            child: SizedBox(
              height: 60,
              child: Column(
                children: [
                  Text("   ${languageSelectControl.myLanguageItem.menuDisplayStr} 으로 ${isHost ? '발표 하는 중' : '보는중'}"),
                  SizedBox(height: 8,),
                  Text( "   번역 언어 변경하기   ", textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
