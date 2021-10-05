// ignore: import_of_legacy_library_into_null_safe
import 'package:google_sign_in/google_sign_in.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/route/route.dart' as route;
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usercontroller = TextEditingController();

  final TextEditingController _passwordcontroller = TextEditingController();

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User> handleSignInEmail(String email, String password) async {
    UserCredential result = await auth.signInWithEmailAndPassword(
        email: _email, password: _password);
    final User user = result.user!;

    return user;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = 'test@gmail.com';

  String _password = 'password';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("theme/sbuddy.png"),
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _usercontroller,
                  decoration: const InputDecoration(labelText: 'Email'),
                )),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: _passwordcontroller,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                )),
            Container(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                    child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(220, 36)),
                  child: const Text('Sign in',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: () async {
                    _email = _usercontroller.text;
                    _password = _passwordcontroller.text;
                    User user = await handleSignInEmail(_email, _password);
                    Navigator.pushNamed(context, route.landingPage);
                  },
                ))),
            Container(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                    child: SignInButton(Buttons.Google, onPressed: () async {
                  UserCredential user = await signInWithGoogle();
                  var currentUser = FirebaseAuth.instance.currentUser;
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(currentUser!.uid)
                      .set({
                    "name": currentUser.displayName,
                    "email": currentUser.email,
                    "course_ids": []
                  }).then((_) {
                    Navigator.pushNamed(context, route.landingPage);
                    print("success!");
                  });
                }))),
          ],
        ));
  }
}
