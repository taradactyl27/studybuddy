import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

final FirebaseFirestore db = FirebaseFirestore.instance;
CollectionReference<Map<String, dynamic>> users = db.collection('users');
CollectionReference<Map<String, dynamic>> courses = db.collection('courses');

Future<void> createUserDoc(User? user) async {
  try {
    await users
        .doc(user!.uid)
        .set({"name": user.displayName, "email": user.email, "course_ids": []});
  } on FirebaseException catch (e) {
    return Future.error(e);
    // TODO: fail harder and delete accounts if doc creation fails
  }
}

Future<void> createCourse(String uid, String name, String description) async {
  DocumentReference<Object?> value = await courses.add({
    "name": name,
    "description": description,
  });
  users.doc(uid).update({
    'course_ids': FieldValue.arrayUnion([value.id])
  });
  return courses.doc(value.id).update({'course_id': value.id});
}

Future<void> deleteCourse(String uid, String courseId) async {
  await courses.doc(courseId).delete();
  await users.doc(uid).update({
    'course_ids': FieldValue.arrayRemove([courseId])
  });
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

Future<List<dynamic>> getUserCourseList(String uid) async {
  DocumentSnapshot documentSnapshot = await users.doc(uid).get();
  if (documentSnapshot.exists) {
    return documentSnapshot.get('course_ids');
  } else {
    return ["null"];
  }
}

Future<DocumentSnapshot<Map<String, dynamic>>> getTranscription(
    String transcriptId, String courseId) {
  return courses.doc(courseId).collection('audios').doc(transcriptId).get();
}

Stream<QuerySnapshot<Map<String, dynamic>>> getCourseTranscriptions(
    String courseId) {
  return courses.doc(courseId).collection('audios').snapshots();
}

Stream<QuerySnapshot<Map<String, dynamic>>> getCourseStream(
    List<dynamic>? courseList) {
  return courses.where(FieldPath.documentId, whereIn: courseList).snapshots();
}

DocumentReference<Map<String, dynamic>> getNewAudioRef(String courseID) {
  return courses.doc(courseID).collection('audios').doc();
}
