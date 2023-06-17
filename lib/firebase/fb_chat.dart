import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/Massege.dart';

class FbChat {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>>? getAllUsers(
      BuildContext context, String myEmail) {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> stream = _db
          .collection("Users")
          .where("email", isNotEqualTo: myEmail)
          .snapshots();
      return stream;
    } catch (e) {
      var snackBar =
          SnackBar(content: Text('Error fetch data, ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return null;
  }

  ///////////////////////////

  static updateStatus(String email, String status) async {
    log("Update");
    _db.collection("Users").doc(email).update({"status": status});
  }

  ///////////////////////////

  static Future<void> sendMessage(BuildContext context, Message message) async {
    try {
      await _db
          .collection('Chat')
          .doc("${message.senderEmail}-${message.receiverEmail}")
          .collection("Messages")
          .doc(message.date)
          .set(message.toFirebase());

      await _db
          .collection('Chat')
          .doc("${message.receiverEmail}-${message.senderEmail}")
          .collection("Messages")
          .doc(message.date)
          .set(message.toFirebase());
    } catch (error) {
      var snackBar =
          SnackBar(content: Text('Error send message, ${error.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ///////////////////////////

  static Stream<QuerySnapshot<Map<String, dynamic>>>? getChatMessages(
      BuildContext context, String senderEmail, String receiverEmail) {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> stream = _db
          .collection('Chat')
          .doc("$senderEmail-$receiverEmail")
          .collection("Messages")
          // .orderBy('date', descending: true)
          .snapshots();
      return stream;
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }

  ///////////////////////////

  static Stream<DocumentSnapshot<Map<String, dynamic>>>? getOtherStatus(
      String otherUserEmail) {
    try {
      Stream<DocumentSnapshot<Map<String, dynamic>>>? stream =
          _db.collection('Users').doc(otherUserEmail).snapshots();
      return stream;
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }

  ///////////////////////////

  static Future<void> deleteMessageForMe(Message message, bool isMe) async {
    try {
      await _db
          .collection('Chat')
          .doc(isMe
              ? "${message.senderEmail}-${message.receiverEmail}"
              : "${message.receiverEmail}-${message.senderEmail}")
          .collection("Messages")
          .doc(message.date)
          .delete();
    } catch (e) {
      log(e.toString());
    }
  }

  ///////////////////////////

  static Future<void> deleteMessageForAll(Message message) async {
    try {
      await _db
          .collection('Chat')
          .doc("${message.senderEmail}-${message.receiverEmail}")
          .collection("Messages")
          .doc(message.date)
          .delete();

      await _db
          .collection('Chat')
          .doc("${message.receiverEmail}-${message.senderEmail}")
          .collection("Messages")
          .doc(message.date)
          .delete();
    } catch (e) {
      log(e.toString());
    }
  }
}
