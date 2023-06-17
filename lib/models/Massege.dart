import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? message;
  String? imageUrl;
  String? videoUrl;
  String senderEmail;
  String receiverEmail;
  String date;

  Message({
    required this.message,
    required this.imageUrl,
    required this.videoUrl,
    required this.senderEmail,
    required this.receiverEmail,
    required this.date,
  });

  factory Message.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Message(
      message: data?['message'],
      imageUrl: data?['imageUrl'],
      videoUrl: data?['videoUrl'],
      senderEmail: data?['senderEmail'],
      receiverEmail: data?['receiverEmail'],
      date: data?['date'],
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      if (message != null) ...{
        "message": message
      } else if (imageUrl != null) ...{
        "imageUrl": imageUrl
      } else ...{
        "videoUrl": videoUrl
      },
      "senderEmail": senderEmail,
      "receiverEmail": receiverEmail,
      "date": date,
    };
  }
}
