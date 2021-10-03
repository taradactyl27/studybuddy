import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studybuddy/route/route.dart' as route;

class LoginPage extends StatelessWidget {
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
      body: Column(
              children: [
                  ElevatedButton(
                    child: Text("Google Sign In"),
                    onPressed: () async{
                      UserCredential user = await signInWithGoogle();
                      if (user != null) {
                        Navigator.pushNamed(context,route.landingPage);
                      }
                    }
                  ),
              ],
        )
    );
  }
}
