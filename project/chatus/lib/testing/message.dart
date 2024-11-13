
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final String senderId;
  final String senderEmail;
  final DateTime createdAt;

  Message({
    required this.text,
    required this.senderId,
    required this.senderEmail,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    final text = data['text'];
    final senderId = data['senderId'];
    final senderEmail = data['senderEmail'];
    final timestamp = (data['createdAt'] as Timestamp).toDate();

    return Message(
      text: text,
      senderId: senderId,
      senderEmail: senderEmail,
      createdAt: timestamp,
    );
  }
}