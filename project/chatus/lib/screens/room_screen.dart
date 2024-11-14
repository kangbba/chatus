import 'dart:async';
import 'package:chatus/screen_pages/dialogue_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/chat_room.dart';
import '../classes/language_select_control.dart';
import '../classes/user_model.dart';
import '../classes/room_settings.dart';
import '../custom_widget/sayne_separator.dart';
import '../managers/my_auth_provider.dart';
import 'language_select_screen.dart';

class RoomScreen extends StatefulWidget {
  final ChatRoom chatRoomToLoad;

  RoomScreen({Key? key, required this.chatRoomToLoad}) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  ChatRoom? chatRoom;
  final MyAuthProvider authProvider = MyAuthProvider.instance;
  StreamSubscription<List<UserModel>>? _userModelsSubscription;
  List<UserModel> userModels = [];
  double myVolume = RoomSettings().myVolume;
  double otherVolume = RoomSettings().otherVolume;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initializeChatRoom();
    listenToUserModels();
  }

  // 채팅방 초기화
  Future<void> initializeChatRoom() async {
    final userModel = authProvider.curUserModel;
    if (userModel != null) {
      final isJoined = await widget.chatRoomToLoad.joinRoom(userModel);
      if (isJoined) {
        setState(() {
          chatRoom = widget.chatRoomToLoad;
        });
      } else {
        Navigator.pop(context);
      }
    }
  }

  // 멤버 리스트 스트림 구독
  void listenToUserModels() {
    _userModelsSubscription = widget.chatRoomToLoad.userModelsStream.listen((updatedUserModels) {
      setState(() {
        userModels = updatedUserModels;
      });
    });
  }

  @override
  void dispose() {
    _userModelsSubscription?.cancel();
    super.dispose();
  }

  // 나가기 버튼 기능
  Future<void> exitRoom() async {
    if (authProvider.curUserModel != null) {
      await chatRoom?.exitRoom(authProvider.curUserModel!);
      Navigator.pop(context);
    }
  }

  // Drawer가 닫힐 때 RoomSettings에 볼륨 값을 저장
  void saveVolumeSettings() {
    RoomSettings().myVolume = myVolume;
    RoomSettings().otherVolume = otherVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key : _scaffoldKey,
      appBar: AppBar(
        title: StreamBuilder<List<UserModel>>(
          stream: chatRoom?.userModelsStream,
          builder: (context, snapshot) {
            final memberCount = snapshot.data?.length ?? 0;
            return Text("${chatRoom?.name ?? 'Loading...'} ($memberCount)");
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: roomDrawer(),
      body: chatRoom == null
          ? Center(child: CircularProgressIndicator())
          : Column(
            children: [
              Expanded(child: DialoguePage(chatRoom: widget.chatRoomToLoad)),
              SizedBox(
                  height : 100 , child: languageSelectScreenBtn())
            ],
          ),
    );
  }

  // Drawer 위젯 생성
  Widget roomDrawer() {
    return SafeArea(
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(chatRoom?.name ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SimpleSeparator(color: Colors.black54, height: 0.3, top: 8, bottom: 8),
                // 멤버 표시 영역
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(children: [
                    Icon(Icons.people, color: Colors.black45),
                    SizedBox(width: 8),
                    Text("참여자 목록", style: TextStyle(fontSize: 16)),
                  ]),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: userModels.length,
                    itemBuilder: (context, index) {
                      final user = userModels[index];
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text(user.displayName ?? "Unknown"),
                      );
                    },
                  ),
                ),
                const SimpleSeparator(color: Colors.black54, height: 0.3, top: 8, bottom: 8),
                // 슬라이더
                volumeSlider("나의 소리 볼륨", myVolume, (value) {
                  setState(() {
                    myVolume = value;
                  });
                }),
                volumeSlider("상대 소리 볼륨", otherVolume, (value) {
                  setState(() {
                    otherVolume = value;
                  });
                }),
              ],
            ),
            // 나가기 버튼
            ListTile(
              tileColor: Colors.black12,
              leading: Icon(Icons.exit_to_app),
              title: Text("Exit Room"),
              onTap: () {
                saveVolumeSettings();
                exitRoom();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget languageSelectScreenBtn() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () async {
          late LanguageSelectScreen myLanguageSelectScreen =
          LanguageSelectScreen(
            languageSelectControl: LanguageSelectControl.instance,
          );
          await showDialog(
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
              Text("   ${ LanguageSelectControl.instance.myLanguageItem.menuDisplayStr}"),
              SizedBox(height: 8,),
              Text( "   언어 변경하기   ", textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // 슬라이더 생성 함수
  Widget volumeSlider(String title, double currentValue, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14)),
          Slider(
            value: currentValue,
            min: 0.0,
            max: 1.0,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Drawer가 닫힐 때 RoomSettings에 볼륨 값을 저장
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    saveVolumeSettings();
  }
}
