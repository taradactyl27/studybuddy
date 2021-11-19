import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

Future<void> createCourse(
    String uid, String email, String name, String description) async {
  DocumentReference<Object?> value = await courses.add({
    "name": name,
    "description": description,
    "roles": {
      uid: {"email": email, "role": "owner"}
    }
  });
  users.doc(uid).update({
    "course_ids": FieldValue.arrayUnion([value.id])
  });
  courses.doc(value.id).update({"course_id": value.id});
}

Future<void> addUserToCourse(String courseId, String email) async {
  QuerySnapshot userdoc = await users.where("email", isEqualTo: email).get();
  if (userdoc.size == 0) {
    throw Exception("User not found");
  } else {
    String roleField = "roles." + userdoc.docs[0].id + ".role";
    String emailField = "roles." + userdoc.docs[0].id + ".email";
    await courses.doc(courseId).update({roleField: "user"});
    await courses.doc(courseId).update({emailField: email});
    await users.doc(userdoc.docs[0].id).update({
      'course_ids': FieldValue.arrayUnion([courseId])
    });
  }
}

Future<void> removeUserFromCourse(String courseId, String uid) async {
  String roleField = 'roles.' + uid;
  await courses.doc(courseId).update({roleField: FieldValue.delete()});
  await users.doc(uid).update({
    'course_ids': FieldValue.arrayRemove([courseId])
  });
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

Future<void> uploadDocumentDeltas(String delta, String fieldName,
    String transcriptId, String courseId) async {
  await courses
      .doc(courseId)
      .collection('audios')
      .doc(transcriptId)
      .update({fieldName: delta});
  print("Deltas Saved");
}

Future<dynamic> getCoursePermList(String courseId) async {
  DocumentSnapshot doc = await courses.doc(courseId).get();
  print("got doc");
  if (doc.exists) {
    print(doc.get('roles'));
    return doc.get('roles');
  } else {
    print('empty');
    return {};
  }
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

Future<void> createAudioDoc(User user, String courseID, String path) async {
  String uid = user.uid;
  try {
    DocumentReference<Map<String, dynamic>> audioDoc =
        courses.doc(courseID).collection('audios').doc();

    await audioDoc.set({
      'owner': uid,
      'created': Timestamp.now(),
      'audioRef': path,
      'notesGenerated': false,
    });

    HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable('transcription-mockTranscript');

    final result = await callable({
      'storagePath': path,
    });

    final data = Map<String, dynamic>.from(result.data);

    if (data['path'] != null) {
      await audioDoc.update({
        'transcriptRef': data['path'],
        'isTranscribing': true,
      });
      return;
    }

    // TODO: release control here and set necessary data for background transcription loading

    if (data['operationID'] != null) {
      print(data['operationID']);
    }

    print("error in transcribing process");
    return;
  } on FirebaseException catch (e) {
    print(e);
  }
}
