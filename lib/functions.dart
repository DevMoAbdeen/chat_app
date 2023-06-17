import 'package:chat_app/screens/login_and_register.dart';
import 'package:flutter/material.dart';
import 'components/display_files.dart';
import 'firebase/fb_authentication.dart';
import 'dart:io';

class AllFunctions {
  static String convertDateToMessage(String date) {
    // DateFormat("YYYY-MM-DD HH:MM:SS.668735")
    int year = int.parse(date.substring(0, 4));
    int month = int.parse(date.substring(5, 7));
    int day = int.parse(date.substring(8, 10));
    int hour = int.parse(date.substring(11, 13));
    int minute = int.parse(date.substring(14, 16));

    final createdArticle = DateTime(year, month, day, hour, minute);
    final dateNow = DateTime.now();
    int differenceDays = dateNow.difference(createdArticle).inDays;

    if (differenceDays == 0 || differenceDays == 1) {
      String hourSend = hour > 12
          ? "${hour - 12}:$minute PM"
          : hour == 0
              ? "12:$minute AM"
              : "$hour:$minute AM";
      return differenceDays == 0 ? hourSend : "Yesterday, $hourSend";
    } else {
      String hourSend = hour > 12
          ? "${hour - 12}:$minute PM"
          : hour == 0
              ? "12:$minute AM"
              : "$hour:$minute AM";
      return "$year/$month/$day - $hourSend";
    }
  }

  ///////////

  static Widget showDialogLogout(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout!'),
      content: const Text('Are you sure you want logout ?'),
      icon: const Icon(Icons.logout),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: InkWell(
                  child: Text("Cancel",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await FbAuthentication.logoutUser();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginAndRegisterPage.id, (route) => false);
              },
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: InkWell(
                  child: Text("Yes",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /////////////////////

  static Widget showDialogSendFile(BuildContext context,
      {required String fileType,
      required String filePath,
      required Function sendFile}) {
    return AlertDialog(
      title: const Text('Send'),
      content: Text('Are you want send this $fileType ?'),
      icon: Icon(
          fileType == "image" ? Icons.image : Icons.slow_motion_video_rounded),
      actions: [
        Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: fileType == "image"
                  ? Image.file(
                      File(filePath),
                    )
                  : ShowVideoScreen(videoUrl: null, videoPath: filePath),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    sendFile();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Yes",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

///////////////////////////////////
}
