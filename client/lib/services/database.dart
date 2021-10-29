import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

User? currentUser = FirebaseAuth.instance.currentUser;
String uid = currentUser!.uid;
final FirebaseFirestore db = FirebaseFirestore.instance;
CollectionReference users = db.collection('users');
CollectionReference courses = db.collection('courses');

Future<void> createUser() async {
  FirebaseFirestore.instance.collection("users").doc(uid).set({
    "name": currentUser!.displayName,
    "email": currentUser!.email,
    "course_ids": []
  });
}

Future<void> deleteCourse(String courseId) async {
  courses.doc(courseId).delete();
  users.doc(uid).update({
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
  courses.doc(value.id).update({'course_id': value.id});
}

Future<List<dynamic>> getUserCourseList() async {
  DocumentSnapshot documentSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (documentSnapshot.exists) {
    return documentSnapshot.get('course_ids');
  } else {
    return ["null"];
  }
}

Stream<QuerySnapshot<Map<String, dynamic>>> getCourseStream(
    List<dynamic>? courseList) {
  return FirebaseFirestore.instance
      .collection('courses')
      .where(FieldPath.documentId, whereIn: courseList)
      .snapshots();
}
