import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

User? currentUser = FirebaseAuth.instance.currentUser;
String uid = currentUser!.uid;
String email = currentUser!.email!;
final FirebaseFirestore db = FirebaseFirestore.instance;
final firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;
CollectionReference courses = db.collection('courses');

Future<void> uploadFile(FilePickerResult result, String courseID) async {
  File file = File(result.files.single.path!);
  String name = result.files.single.name;
  try {
    final audioPath = email.contains('admin') ? name : '$uid/$name';
    await storage.ref(audioPath).putFile(file);
    print('audio UPLOAD done!!!');

    DocumentReference<Map<String, dynamic>> audioDoc =
        courses.doc(courseID).collection('audios').doc();
    await audioDoc.set({
      'owner': uid,
      'created': Timestamp.now(),
      'audioRef': '$uid/$name',
    });

    HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable('transcription-requestTranscription');
    final result = await callable({
      'storagePath': '$uid/$name',
      // add template here if mocking transcription to choose a different example
    });

    final data = Map<String, dynamic>.from(result.data);

    // mocked transcription copying succeeded
    if (data['path'] != null) {
      Uint8List? transcriptData = await storage.ref(data['path']).getData();

      Map<String, dynamic> transcript =
          jsonDecode(utf8.decode(transcriptData!));

      String fullTranscriptText = transcript['results'].fold(
          '',
          (prev, result) =>
              prev + ' ' + result['alternatives'][0]['transcript']);

      audioDoc.update({
        'transcriptRef': data['path'],
        'text': fullTranscriptText,
      });
      print(fullTranscriptText);
      // send to transcript review and editing process

    }

    // TODO: release control here and set necessary data for background transcription loading

    if (data['operationID'] != null) {
      print(data['operationID']);
    }

    return;
  } on firebase_core.FirebaseException catch (e) {
    print(e);
  }
}
