import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Database {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static CollectionReference users = _db.collection('users');
  static CollectionReference courses = _db.collection('courses');

  static Future<void> createUser(
      String uid, String? name, String? email) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set({"name": name, "email": email, "course_ids": []});
  }

  static Future<void> deleteCourse(String uid, String courseId) async {
    courses.doc(courseId).delete();
    users.doc(uid).update({
      'course_ids': FieldValue.arrayRemove([courseId])
    });
  }

  static Future<void> createCourse(
      String uid, String name, String description) async {
    DocumentReference<Object?> value = await courses.add({
      "name": name,
      "description": description,
    });
    users.doc(uid).update({
      'course_ids': FieldValue.arrayUnion([value.id])
    });
    courses.doc(value.id).update({'course_id': value.id});
  }

  static Future<void> uploadFile(
      String? filePath, String fileName, String uid) async {
    File file = File(filePath!);
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('$uid/$fileName')
          .putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  static Future<List<dynamic>> getUserCourseList(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (documentSnapshot.exists) {
      return documentSnapshot.get('course_ids');
    } else {
      return ["null"];
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getCourseStream(
      List<dynamic>? courseList) {
    return FirebaseFirestore.instance
        .collection('courses')
        .where(FieldPath.documentId, whereIn: courseList)
        .snapshots();
  }
}
