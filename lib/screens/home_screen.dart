import 'dart:developer';
import 'package:chat_app/constants.dart';
import 'package:chat_app/firebase/fb_authentication.dart';
import 'package:chat_app/firebase/fb_chat.dart';
import 'package:chat_app/functions.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/login_and_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle/lifecycle.dart';

class HomePage extends StatefulWidget {
  static const String id = "HomePage";

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with LifecycleAware, LifecycleMixin {
  late User user;

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    log("event is: $event");
    if (event == LifecycleEvent.active) {
      FbChat.updateStatus(user.email!, "Online");
    } else if (event == LifecycleEvent.inactive) {
      FbChat.updateStatus(user.email!, "Offline");
    }
  }

  @override
  void initState() {
    user = FbAuthentication.getUser();
    if (user.email == null) {
      Navigator.pushNamedAndRemoveUntil(
          context, LoginAndRegisterPage.id, (route) => false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[400],
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          // Stack(
          //   children: [
          //     IconButton(
          //       icon: const Icon(Icons.notifications),
          //       onPressed: () {
          //         Navigator.pushNamed(context, NotificationsScreen.id, arguments: notifications)
          //             .then(
          //           (value) => setState(() {
          //             notifications.clear();
          //           }),
          //         );
          //       },
          //     ),
          //     notifications.isNotEmpty
          //         ? Container(
          //             margin: const EdgeInsets.all(10),
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 5,
          //               vertical: 2,
          //             ),
          //             decoration: const BoxDecoration(
          //                 color: Colors.red, shape: BoxShape.circle),
          //             child: Text(
          //               '${notifications.length}',
          //               style: const TextStyle(fontSize: 10),
          //             ),
          //           )
          //         : const SizedBox(),
          //   ],
          // ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AllFunctions.showDialogLogout(context);
                  });
            },
          ),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder(
              stream: FbChat.getAllUsers(context, user.email!),
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  List<dynamic> users = snapShot.data!.docs;
                  return users.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              UserModel user =
                                  UserModel.fromFirebase(users[index]);

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        otherUserEmail: user.email,
                                        otherUserName: user.name,
                                        userImage: user.imageUrl,
                                      ),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  leading: user.imageUrl != null
                                      ? Hero(
                                          tag: user.imageUrl!,
                                          child: CircleAvatar(
                                            radius: 28,
                                            backgroundColor:
                                                Colors.grey.shade400,
                                            backgroundImage:
                                                NetworkImage(user.imageUrl!),
                                          ),
                                        )
                                      : const CircleAvatar(
                                          radius: 28,
                                          child: Center(
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.black,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                  title: Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(user.email),
                                  trailing: user.status == "Online"
                                      ? const CircleAvatar(
                                          radius: 5,
                                          backgroundColor: Colors.green,
                                        )
                                      : const SizedBox(),
                                ),
                              );
                            },
                          ),
                        )
                      : const Expanded(
                          child: Center(
                            child: Text(
                              'No any users yet',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                }
                return kSizeBoxEmpty;
              },
            )
          ],
        ),
      ),
    );
  }
}
