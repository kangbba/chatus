import 'package:flutter/material.dart';
import 'package:chatus/classes/user_model.dart';
import 'profile_circle.dart'; // ProfileCircle을 import

class DialogueTile extends StatelessWidget {
  final UserModel userModel;
  final String text;
  final String date;
  final bool isTranslationFailed;
  final bool isMine;

  const DialogueTile({
    Key? key,
    required this.userModel,
    required this.text,
    required this.date,
    required this.isMine,
    this.isTranslationFailed = false,
  }) : super(key: key);

  static const double fontSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ProfileCircle 추가
            if(!isMine)
              Row(
                children: [
                  ProfileCircle(
                    userModel: userModel,
                    radius: 20, // 원하는 반지름 값 설정
                  ),
                  const SizedBox(width: 12), // 프로필 사진과 텍스트 사이 간격
                ],
              ),

            // 텍스트와 날짜를 포함하는 부분
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isMine ? Colors.blueAccent : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(fontSize: fontSize),
                    ),
                    const SizedBox(height: 4),
                    if (isTranslationFailed)
                      Text(
                        "번역 실패, 원본으로 표시합니다.",
                        style: TextStyle(fontSize: fontSize - 4, color: Colors.red.shade400),
                      ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        date,
                        style: const TextStyle(fontSize: fontSize - 6, color: Colors.black45),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if(isMine)
              Row(
                children: [
                  const SizedBox(width: 12), // 프로필 사진과 텍스트 사이 간격
                  ProfileCircle(
                    userModel: userModel,
                    radius: 20, // 원하는 반지름 값 설정
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
