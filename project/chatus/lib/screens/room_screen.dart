import 'dart:async';
import 'package:chatus/custom_widget/room_drawer.dart';
import 'package:chatus/screen_pages/dialogue_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/chat_room.dart';
import '../classes/language_select_control.dart';
import '../classes/user_model.dart';
import '../classes/room_settings.dart';
import '../custom_widget/sayne_separator.dart';
import '../custom_widget/user_list.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<double> myVolumeNotifier = ValueNotifier(RoomSettings().myVolume);
  final ValueNotifier<double> otherVolumeNotifier = ValueNotifier(RoomSettings().otherVolume);


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

      // 조건에 따라 로그 출력
      final myUid = authProvider.curUserModel?.uid;

      if (updatedUserModels.isEmpty) {
        debugPrint("Log: userModels count is 0.");
        Navigator.of(context).pop();
      }
      // else if (myUid != null && !updatedUserModels.any((user) => user.uid == myUid)) {
      //   debugPrint("Log: Current user is not in the userModels list.");
      //   Navigator.of(context).pop();
      // }
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

  void saveVolumeSettings() {
    RoomSettings().myVolume = myVolumeNotifier.value;
    RoomSettings().otherVolume = otherVolumeNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white12,
        title: StreamBuilder<List<UserModel>>(
          stream: chatRoom?.userModelsStream,
          builder: (context, snapshot) {
            final memberCount = snapshot.data?.length ?? 0;
            return Text("${chatRoom?.name ?? 'Loading...'} ($memberCount)");
          },
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
      endDrawer: RoomDrawer(chatRoom: widget.chatRoomToLoad),
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

  Widget volumeSlider(String title, ValueNotifier<double> volumeNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14)),
          ValueListenableBuilder<double>(
            valueListenable: volumeNotifier,
            builder: (context, currentValue, child) {
              return Slider(
                value: currentValue,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  volumeNotifier.value = value;
                },
              );
            },
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
