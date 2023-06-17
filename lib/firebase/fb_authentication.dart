import 'package:chat_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class FbAuthentication {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static dynamic loginWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static dynamic signUpWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /////////////////////

  static User getUser() {
    return _auth.currentUser!;
  }

  static logoutUser() {
    _auth.signOut();
  }

  /////////////////

  static Future<void> addUser(BuildContext context, UserModel user) async {
    await _db.collection("Users").doc(user.email).set(user.toFirebase())
        .whenComplete(() => {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in by: ${user.email}')),
      ),
      Navigator.pushReplacementNamed(context, HomePage.id),
    })
        .onError((error, stackTrace) => {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      ),
    });
  }

}
