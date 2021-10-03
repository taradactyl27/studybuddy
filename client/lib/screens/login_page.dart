import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginPage extends StatelessWidget {
  Future<FirebaseApp> _initializeFirebase() async {
        FirebaseApp firebaseApp = await Firebase.initializeApp();
        return firebaseApp;
  }
    Future<UserCredential> signInWithGoogle() async {
        // Trigger the authentication flow
        final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Buddy'),
      ),
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              children: [
                  ElevatedButton(
                    child: Text("Google Sign In"),
                    onPressed: () async{
                      UserCredential user = await signInWithGoogle();
                      if (user != null) {
                        print("USER SIGNED IN");
                      }
                    }
                  ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}