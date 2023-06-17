import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? imageUrl;
  String name;
  String email;
  String status;
  String? token;

  UserModel({
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.status,
    required this.token,
  });

  factory UserModel.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserModel(
      // userId: snapshot.id,
      imageUrl: data?['imageUrl'],
      name: data?['name'],
      email: data?['email'],
      status: data?['status'],
      token: data?['token'],
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      "imageUrl": imageUrl,
      "name": name,
      "email": email,
      "status": status,
      "token": token,
    };
  }
}