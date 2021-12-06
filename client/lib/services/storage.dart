import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth.dart' show User;

final FirebaseStorage storage = FirebaseStorage.instance;

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
