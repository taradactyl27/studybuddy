import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

final FirebaseFirestore db = FirebaseFirestore.instance;
CollectionReference<Map<String, dynamic>> users = db.collection('users');
CollectionReference<Map<String, dynamic>> courses = db.collection('courses');
CollectionReference<Map<String, dynamic>> defaults = db.collection('defaults');

Future<void> createUserDoc(User? user) async {
  try {
    await users
        .doc(user!.uid)
        .set({"name": user.displayName, "email": user.email});
  } on FirebaseException catch (e) {
    return Future.error(e);
    // TODO: fail harder and delete accounts if doc creation fails
  }
}

Stream<DocumentSnapshot<Map<String, dynamic>>> getDefaultStream(
    String defaultsId) {
  return defaults.doc(defaultsId).snapshots();
}

Future<QuerySnapshot<Map<String, dynamic>>> getRandomTranscription(
    String courseId) {
  return courses.doc(courseId).collection('audios').limit(1).get();
}

Stream<QuerySnapshot<Map<String, dynamic>>> getUserCourseStream(String uid) {
  return courses.where('roles.$uid.email', isGreaterThan: "").snapshots();
}

Stream<QuerySnapshot<Map<String, dynamic>>> getUserFavoritesStream(String uid) {
  return courses.where('roles.$uid.favorite', isEqualTo: true).snapshots();
}

Stream<DocumentSnapshot<Map<String, dynamic>>> getCourseStream(
    String courseId) {
  return courses.doc(courseId).snapshots();
}

Future<dynamic> getCoursePermList(String courseId) async {
  DocumentSnapshot doc = await courses.doc(courseId).get();
  if (doc.exists) {
    return doc.get('roles');
  } else {
    return {};
  }
}

Future<void> addCourseToFavorite(String courseId, String uid) async {
  String favoritesField = "roles.$uid.favorite";
  await courses.doc(courseId).update({favoritesField: true});
}

Future<void> removeCourseFromFavorite(String courseId, String uid) async {
  String favoritesField = "roles.$uid.favorite";
  await courses.doc(courseId).update({favoritesField: false});
}

Future<void> createCourse(
    String uid, String email, String name, String description) async {
  DocumentReference<Object?> value = await courses.add({
    "name": name,
    "description": description,
    "roles": {
      uid: {"email": email, "role": "owner", "favorite": false}
    }
  });
  courses.doc(value.id).update({"course_id": value.id});
}

Future<void> addUserToCourse(String courseId, String email) async {
  QuerySnapshot userdoc = await users.where("email", isEqualTo: email).get();
  if (userdoc.size == 0) {
    throw Exception("User not found");
  } else {
    DocumentSnapshot doc = await courses.doc(courseId).get();
    if (doc.exists) {
      if (doc.get('roles').containsKey(userdoc.docs[0].id)) {
        throw Exception("User already added to course");
      }
    }
    String roleField = "roles.${userdoc.docs[0].id}.role";
    String emailField = "roles.${userdoc.docs[0].id}.email";
    String favoritesField = "roles.${userdoc.docs[0].id}.favorite";
    await courses
        .doc(courseId)
        .update({roleField: "user", emailField: email, favoritesField: false});
  }
}

Future<void> removeUserFromCourse(String courseId, String uid) async {
  String roleField = 'roles.' + uid;
  await courses.doc(courseId).update({roleField: FieldValue.delete()});
}

Future<void> deleteCourse(String uid, String courseId) async {
  await courses.doc(courseId).delete();
}

DocumentReference<Map<String, dynamic>> newLectureRef(String courseID) {
  return courses.doc(courseID).collection('audios').doc();
}

Stream<QuerySnapshot<Map<String, dynamic>>> getCourseTranscriptions(
    String courseId) {
  return courses.doc(courseId).collection('audios').snapshots();
}

Future<DocumentSnapshot<Map<String, dynamic>>> getTranscription(
    String transcriptId, String courseId) {
  return courses.doc(courseId).collection('audios').doc(transcriptId).get();
}

Future<void> uploadStudyNotes(
    String notes, String transcriptId, String courseId) async {
  await courses
      .doc(courseId)
      .collection('audios')
      .doc(transcriptId)
      .update({'studyNotes': notes, 'notesGenerated': true});
  print("NOTES UPLOADED");
}

Future<String> getStudyNotes(String transcriptId, String courseId) async {
  DocumentSnapshot doc =
      await courses.doc(courseId).collection('audios').doc(transcriptId).get();
  if (doc.exists) {
    return doc.get('studyNotes');
  } else {
    return "empty";
  }
}

Future<void> uploadDocumentDeltas(String delta, String fieldName,
    String transcriptId, String courseId) async {
  await courses
      .doc(courseId)
      .collection('audios')
      .doc(transcriptId)
      .update({fieldName: delta});
  print("Deltas Saved");
}
