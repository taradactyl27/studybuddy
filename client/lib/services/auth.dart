import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'database.dart' show createUserDoc;
export 'package:firebase_auth/firebase_auth.dart' show User;

final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

CollectionReference<Map<String, dynamic>> users =
    FirebaseFirestore.instance.collection('users');

// sign(in|up|out) functions
Future<void> signInEmail(String email, String password) async {
  try {
    await auth.signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {return Future.error(e);}
}

Future<void> signInGoogle() async {
  try {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Once signed in, get the UserCredential
    UserCredential userCred = await auth.signInWithCredential(credential);

    if (userCred.additionalUserInfo!.isNewUser) {
      print("New Google User, creating docs ...");
      await createUserDoc(userCred.user);
    }
  } catch (e) {
    return Future.error(e);
  }
}

Future<void> signUpEmail(String email, String password) async {
  try {
    UserCredential userCred = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await createUserDoc(userCred.user);
  } on FirebaseAuthException catch (e) {
    return Future.error(e);
  }
}

Future<void> signOut() async {
  try {
    await googleSignIn.signOut();
    await auth.signOut();
  } on FirebaseAuthException catch (e) {
    return Future.error(e);
  }
}
