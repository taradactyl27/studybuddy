import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

User? currentUser = FirebaseAuth.instance.currentUser;
String uid = currentUser!.uid;
String email = currentUser!.email!;
final FirebaseFirestore db = FirebaseFirestore.instance;
final firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;
CollectionReference courses = db.collection('courses');

Future<Map> getSearchResults(String query) async {
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('algolia-generateSearchKey');
  final result = await callable();
  Map reqData = {'params': "query=" + query};
  String key = result.data['key'];
  var response = await http.post(
      Uri.parse('https://STFQQELZGY-dsn.algolia.net/1/indexes/audios/query"'),
      headers: {
        HttpHeaders.authorizationHeader: "X-Algolia-API-Key: $key",
        HttpHeaders.authorizationHeader: "X-Algolia-API-Key: $key",
        HttpHeaders.acceptHeader: "application/json; charset=UTF-8",
        HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8"
      },
      body: jsonEncode(reqData));
  Map<String, dynamic> map = json.decode(response.body);
  print(map);
  return {};
}

UploadTask createUpload(
    User user, String courseID, String audioID, File file, String name) {
  String uid = user.uid;

  SettableMetadata metadata = SettableMetadata(
    customMetadata: <String, String>{
      'courseID': courseID,
      'audioID': audioID,
      'uid': user.uid,
      'mocker':
          dotenv.get('TRANSCRIBE', fallback: '') == 'y' ? '' : user.email!,
      'mockTemplate': dotenv.get('MOCK_TEMPLATE', fallback: ''),
    },
  );
  return storage.ref('$uid/$name').putFile(file, metadata);
}

Future<void> uploadFile(
    FilePickerResult result, String selectedName, String courseID) async {
  File file = File(result.files.single.path!);
  try {
    final audioPath =
        email.contains('admin') ? selectedName : '$uid/$selectedName';
    await storage.ref(audioPath).putFile(file);
    print('audio UPLOAD done!!!');

    DocumentReference<Map<String, dynamic>> audioDoc =
        courses.doc(courseID).collection('audios').doc();
    await audioDoc.set({
      'owner': uid,
      'created': Timestamp.now(),
      'audioRef': '$uid/$selectedName',
      'notesGenerated': false,
    });

    HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable('transcription-requestTranscription');
    final result = await callable({
      'storagePath': '$uid/$selectedName',
      'template':
          'VOXTAB_Academic_audio_transcript-2021-10-30T18-02-43_431109621+00-00.json'
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
