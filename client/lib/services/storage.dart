import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth.dart' show User;

final FirebaseStorage storage = FirebaseStorage.instance;

UploadTask createUpload(
    User user, String courseID, String audioID, FilePickerResult result) {
  File file = File(result.files.single.path!);
  String name = result.files.single.name;
  String uid = user.uid;

  SettableMetadata metadata = SettableMetadata(
    customMetadata: <String, String>{
      'courseID': courseID,
      'audioID': audioID,
      'uid': uid,
      'mocker':
          dotenv.get('TRANSCRIBE', fallback: '') == 'y' ? '' : user.email!,
      'mockTemplate': dotenv.get('MOCK_TEMPLATE', fallback: ''),
    },
  );
  return storage.ref('$uid/$name').putFile(file, metadata);
}
