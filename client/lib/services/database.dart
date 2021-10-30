import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

User? currentUser = FirebaseAuth.instance.currentUser;
String uid = currentUser!.uid;
final FirebaseFirestore db = FirebaseFirestore.instance;
CollectionReference<Map<String, dynamic>> users = db.collection('users');
CollectionReference<Map<String, dynamic>> courses = db.collection('courses');

Future<void> createUser() async {
  await users.doc(uid).set({
    "name": currentUser!.displayName,
    "email": currentUser!.email,
    "course_ids": []
  });
}

Future<void> updateUser(User? newUser) async {
  //currentUser = FirebaseAuth.instance.currentUser;
  currentUser = newUser;
  uid = currentUser!.uid;
  print("User Updated");
}

Future<void> deleteCourse(String courseId) async {
  await courses.doc(courseId).delete();
  await users.doc(uid).update({
    'course_ids': FieldValue.arrayRemove([courseId])
  });
}

Future<void> createCourse(String name, String description) async {
  DocumentReference<Object?> value = await courses.add({
    "name": name,
    "description": description,
  });
  users.doc(uid).update({
    'course_ids': FieldValue.arrayUnion([value.id])
  });
  return courses.doc(value.id).update({'course_id': value.id});
}

Future<List<dynamic>> getUserCourseList() async {
  DocumentSnapshot documentSnapshot = await users.doc(uid).get();
  if (documentSnapshot.exists) {
    return documentSnapshot.get('course_ids');
  } else {
    return ["null"];
  }
}

Stream<QuerySnapshot<Map<String, dynamic>>> getCourseTranscriptions(
    String courseId) {
  return courses.doc(courseId).collection('audios').snapshots();
}

Stream<QuerySnapshot<Map<String, dynamic>>> getCourseStream(
    List<dynamic>? courseList) {
  return courses.where(FieldPath.documentId, whereIn: courseList).snapshots();
}
