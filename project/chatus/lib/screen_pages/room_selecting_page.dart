import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:chatus/managers/my_auth_provider.dart';
import 'package:chatus/managers/chat_provider.dart';

import '../classes/chat_room.dart';
import '../classes/user_model.dart';
import '../custom_widget/profile_circle.dart';
import '../custom_widget/profile_circle_stack.dart';
import '../screens/room_screen.dart';

class RoomSelectingPage extends StatefulWidget {
  const RoomSelectingPage({Key? key}) : super(key: key);

  @override
  State<RoomSelectingPage> createState() => _RoomSelectingPageState();
}

class _RoomSelectingPageState extends State<RoomSelectingPage> {
  final _authProvider = MyAuthProvider.instance;
  final _chatProvider = ChatProvider.instance;
  // CachedQueryFirebaseFirestore 인스턴스 생성
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatRoom>>(
      stream: _chatProvider.chatRoomsStream(),
      initialData: [], // 초기 데이터 설정
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if(!snapshot.hasData){
          return Center(
            child: Text('Error: hasData is false'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        List<ChatRoom> chatRooms = snapshot.data!;
        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            return StreamBuilder<List<UserModel>>(
                  stream: chatRoom.userModelsStream,
                  builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return SizedBox(height: 10,);
                    }
                    return Slidable(
                        key: Key(chatRoom.id),
                        endActionPane: ActionPane(
                          extentRatio: 0.2,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                chatRoom.exitRoom(UserModel.fromFirebaseUser(_authProvider.curUser!));
                              },
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              label: '삭제',
                            ),
                          ],
                        ),
                        child: chatRoomListTile(chatRoom, snapshot.data!, context));
                  }
              );
          },
        );
      },
    );
  }

  Widget chatRoomListTile(ChatRoom chatRoom, List<UserModel> userModels, BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: ListTile(
          title: SizedBox(width : 200, child: Text("${chatRoom.name}")),
          leading: ProfileCircleStack(users: [chatRoom.host], maxRectangleSize : 45),
          subtitle: Row(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(scale : 0.8, child: Icon(Icons.account_box)),
                  Text('${chatRoom.host.displayName}', style: TextStyle(fontSize: 12),),
                ],
              ),
              SizedBox(width: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(scale : 0.8, child: Icon(Icons.people_alt)),
                  Text('${userModels.length}', style: TextStyle(fontSize: 13),),
                ],
              )
            ],
          ),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoomScreen(chatRoomToLoad: chatRoom,),
              ),
            );
          },
        ),
      ),
    );
  }



}
