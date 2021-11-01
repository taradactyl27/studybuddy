import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

final FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;
CollectionReference courses = db.collection('courses');

Future<Map> getSearchResults(String query) async {
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('algolia-generateSearchKey');
  final result = await callable();

  Map reqData = {
    'query': query,
  };
  String key = result.data['key'];
  Map<String, String> _headers = <String, String>{
    'X-Algolia-Application-Id': 'STFQQELZGY',
    'X-Algolia-API-Key': key,
    'Content-Type': 'application/json; charset=UTF-8',
  };

  var response = await http.post(
    Uri.parse('https://stfqqelzgy-dsn.algolia.net/1/indexes/audios/query'),
    headers: _headers,
    body: jsonEncode(reqData),
  );

  Map<String, dynamic> map = json.decode(response.body);
  print(map);
  print(map['hits'].length);
  return map;
}

UploadTask uploadAudioFile(
    User user, FilePickerResult result, String courseID) {
  File file = File(result.files.single.path!);
  String name = result.files.single.name;
  String uid = user.uid;
  String email = user.email!;
  final audioPath = email.contains('admin') ? name : '$uid/$name';
  print('audio UPLOAD done!!!');
  return storage.ref(audioPath).putFile(file);
}

Future<void> uploadFile(
    User user, FilePickerResult result, String courseID) async {
  File file = File(result.files.single.path!);
  String name = result.files.single.name;
  String uid = user.uid;
  String email = user.email!;
  try {
    DocumentReference<Map<String, dynamic>> audioDoc =
        courses.doc(courseID).collection('audios').doc();
    await audioDoc.set({
      'owner': uid,
      'created': Timestamp.now(),
      'audioRef': '$uid/$name',
      'notesGenerated': false,
    });

    HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable('transcription-requestTranscription');

    // mock file by sending template field
    final result = await callable({
      'storagePath': '$uid/$name',
      // 'template': 'VOXTAB_Academic_audio_transcript.json'
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
  } on FirebaseException catch (e) {
    print(e);
  }
}
