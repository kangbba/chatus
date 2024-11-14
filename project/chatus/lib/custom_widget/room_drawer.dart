import 'package:chatus/custom_widget/user_list.dart';
import 'package:chatus/managers/my_auth_provider.dart';
import 'package:flutter/material.dart';
import '../classes/room_settings.dart';
import '../classes/chat_room.dart';
import '../custom_widget/simple_separator.dart';

class RoomDrawer extends StatefulWidget {
  final ChatRoom chatRoom;

  const RoomDrawer({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<RoomDrawer> createState() => _RoomDrawerState();
}

class _RoomDrawerState extends State<RoomDrawer> {

  MyAuthProvider authProvider = MyAuthProvider.instance;
  final ValueNotifier<double> myVolumeNotifier = ValueNotifier(RoomSettings().myVolume);
  final ValueNotifier<double> otherVolumeNotifier = ValueNotifier(RoomSettings().otherVolume);

  @override
  void initState() {
    super.initState();
    _loadVolumeSettings();
  }

  // SharedPreferences에서 볼륨 설정 로드
  Future<void> _loadVolumeSettings() async {
    await RoomSettings().loadSettings();
    myVolumeNotifier.value = RoomSettings().myVolume;
    otherVolumeNotifier.value = RoomSettings().otherVolume;
  }

  // RoomDrawer가 닫힐 때 볼륨 설정 저장
  Future<void> _saveVolumeSettings() async {
    RoomSettings().myVolume = myVolumeNotifier.value;
    RoomSettings().otherVolume = otherVolumeNotifier.value;
    await RoomSettings().saveSettings();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    debugPrint("room drawer 닫힘");
    _saveVolumeSettings(); // Drawer가 닫힐 때 저장
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.chatRoom.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: UserList(userModelsStream: widget.chatRoom.userModelsStream)),
            const SimpleSeparator(color: Colors.black54, height: 0.3, top: 8, bottom: 8),
            SizedBox(
              height: 160,
              child: Column(
                children: [
                  volumeSlider("My volume", myVolumeNotifier),
                  volumeSlider("Other people's volume", otherVolumeNotifier),
                ],
              ),
            ),
            SizedBox(
              height: 60,
              child: ListTile(
                tileColor: Colors.black12,
                leading: Icon(Icons.exit_to_app),
                title: Text("Exit Room"),
                onTap: () {
                  widget.chatRoom.exitRoom(authProvider.curUserModel!);
                  Navigator.pop(context); // Drawer 닫기
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget volumeSlider(String title, ValueNotifier<double> volumeNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ValueListenableBuilder<double>(
        valueListenable: volumeNotifier,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14)),
              Slider(
                value: value,
                min: 0.0,
                max: 1.0,
                onChanged: (newValue) {
                  volumeNotifier.value = newValue;
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
