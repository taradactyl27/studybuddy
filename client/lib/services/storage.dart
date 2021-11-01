import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;
CollectionReference courses = db.collection('courses');

UploadTask createUpload(User user, String courseID, FilePickerResult result) {
  File file = File(result.files.single.path!);
  String name = result.files.single.name;
  String uid = user.uid;
  return storage.ref('$uid/$name').putFile(file);
}

Future<void> attemptTranscript(
    String courseID, String audioID, String path) async {
  try {
    Uint8List? transcriptData = await storage.ref(path).getData();
    Map<String, dynamic> transcript = jsonDecode(utf8.decode(transcriptData!));

    String fullTranscriptText = transcript['results'].fold('',
        (prev, result) => prev + ' ' + result['alternatives'][0]['transcript']);
    print(fullTranscriptText);
    await courses.doc(courseID).collection('audios').doc(audioID).update({
      'text': fullTranscriptText,
      'isTranscribing': false,
    });
  } catch (e) {
    print('getting/updating transcript json ref failed. wait longer.....');
  }
}
