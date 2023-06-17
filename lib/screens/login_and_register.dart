import 'dart:io';
import 'package:chat_app/firebase/fb_authentication.dart';
import 'package:chat_app/firebase/fb_files.dart';
import 'package:chat_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/main_btn.dart';
import '../constants.dart';
import 'home_screen.dart';

class LoginAndRegisterPage extends StatefulWidget {
  static const String id = "LoginAndRegisterPage";

  const LoginAndRegisterPage({Key? key}) : super(key: key);

  @override
  State<LoginAndRegisterPage> createState() => _LoginAndRegisterPageState();
}

class _LoginAndRegisterPageState extends State<LoginAndRegisterPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController tabController;
  late String uniqueImageName;
  String? imagePath;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailLoginController = TextEditingController();
  TextEditingController passwordLoginController = TextEditingController();

  TextEditingController emailSignupController = TextEditingController();
  TextEditingController passwordSignupController = TextEditingController();

  bool isVisibleLogin = false;
  bool isClickButton = false;
  bool isUploadingImage = false;
  bool isVisibleSignup = false;

  String? imageUrl;
  XFile? file;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    tabController.dispose();
    nameController.dispose();
    emailLoginController.dispose();
    passwordLoginController.dispose();
    emailSignupController.dispose();
    passwordSignupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Login"),
              Tab(text: "Signup"),
            ],
          ),
          title: const Text("Login and Signup"),
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Flexible(
                    child: Hero(
                      tag: 'logo',
                      child: SizedBox(
                        height: 250,
                        child: Image.asset('images/logo.png'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 48.0,
                  ),
                  TextFormField(
                    controller: emailLoginController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Write your Email',
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.lightBlueAccent,
                        ),
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    controller: passwordLoginController,
                    obscureText: !isVisibleLogin,
                    decoration: kTextFieldDecoration.copyWith(
                      prefixIcon: const Icon(Icons.lock),
                      prefixIconColor: Colors.lightBlueAccent,
                      border: const UnderlineInputBorder(),
                      hintText: "Write your password",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisibleLogin = !isVisibleLogin;
                          });
                        },
                        icon: isVisibleLogin
                            ? const Icon(
                                Icons.visibility,
                                color: Colors.grey,
                              )
                            : const Icon(
                                Icons.visibility_off,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  MainBtn(
                    showProgress: isClickButton,
                    color: Colors.lightBlueAccent,
                    text: 'Login',
                    onPressed: () async {
                      String email = emailLoginController.text.trim();
                      String password = passwordLoginController.text.trim();

                      if (email.isNotEmpty && password.isNotEmpty) {
                        setState(() {
                          isClickButton = true;
                        });
                        try {
                          final newUser = await FbAuthentication.loginWithEmailAndPassword(email, password);
                          if (newUser.user != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('loged in  ${newUser.user!.email}')),
                            );
                            Navigator.pushReplacementNamed(context, HomePage.id);
                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found' || e.code == 'wrong-password') {
                            var snackBar = const SnackBar(content: Text('The password is wrong, or No user found for that email'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }else if(e.code == "invalid-email"){
                            var snackBar = const SnackBar(content: Text('This email is not valid!'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        } catch(e){
                          var snackBar = SnackBar(content: Text('Error, $e'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fill all fields !')),
                        );
                      }
                      setState(() {
                        isClickButton = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            //
            // Signup
            //
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ListView(
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: SizedBox(
                      height: 150,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  InkWell(
                    onTap: () async {
                      if (!isUploadingImage) {
                        ImagePicker imagePicker = ImagePicker();
                        file = await imagePicker.pickImage(source: ImageSource.gallery);

                        if (file != null) {
                          uniqueImageName = DateTime.now().millisecondsSinceEpoch.toString();
                          imagePath = file!.path;
                          setState(() {});
                        }
                      }
                    },
                    child: imagePath == null
                        ? const CircleAvatar(
                            backgroundColor: Colors.lightBlueAccent,
                            radius: 56,
                            child: Center(
                              child: Text(
                                "Select\nimage",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : isUploadingImage
                            ? CircleAvatar(
                                radius: 64,
                                backgroundColor: Colors.grey.shade400,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                radius: 64,
                                backgroundColor: Colors.grey.shade400,
                                backgroundImage: FileImage(File(imagePath!)),
                              ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Write your name',
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.lightBlueAccent,
                        ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: emailSignupController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Write your Email',
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.lightBlueAccent,
                        ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: passwordSignupController,
                    obscureText: !isVisibleSignup,
                    decoration: kTextFieldDecoration.copyWith(
                      prefixIcon: const Icon(Icons.lock),
                      prefixIconColor: Colors.lightBlueAccent,
                      border: const UnderlineInputBorder(),
                      hintText: "Write your password",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisibleSignup = !isVisibleSignup;
                          });
                        },
                        icon: isVisibleSignup
                            ? const Icon(
                                Icons.visibility,
                                color: Colors.grey,
                              )
                            : const Icon(
                                Icons.visibility_off,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  MainBtn(
                    showProgress: isClickButton,
                    color: Colors.lightBlueAccent,
                    text: 'Sign Up',
                    onPressed: () async {
                      String name = nameController.text.trim();
                      String email = emailSignupController.text.trim();
                      String password = passwordSignupController.text.trim();
                      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                        setState(() {
                          isClickButton = true;
                        });

                        try {
                          final newUser = await FbAuthentication.signUpWithEmailAndPassword(email, password);
                          if (newUser.user != null) {
                            if (file != null) {
                              imageUrl = await FbFiles.uploadImage(context, file!, uniqueImageName);

                            }
                            UserModel newUser = UserModel(imageUrl: imageUrl, name: name, email: email, status: "Online", token: null);
                            await FbAuthentication.addUser(context, newUser);
                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'invalid-email') {
                            var snackBar = const SnackBar(content: Text('Write valid email!'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          } else if (e.code == 'email-already-in-use') {
                            var snackBar = const SnackBar(content: Text('This email has already been taken.'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        } catch (e) {
                          var snackBar = SnackBar(content: Text('Error, $e'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fill all fields !')),
                        );
                      }
                      setState(() {
                        isClickButton = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
