import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

String recentFilePath = "";
String tempfilename = "";

class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;
  Stream? get getRecorderStream =>
      _audioRecorder!.isRecording ? _audioRecorder!.onProgress : null;
  bool get isRecording => _audioRecorder!.isRecording;

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone Permission Not Granted');
    }
    final storeStatus = await Permission.storage.request();
    if (storeStatus != PermissionStatus.granted) {
      throw RecordingPermissionException('Storage Permission Not Granted');
    }
    await _audioRecorder!.openAudioSession();
    _isRecorderInitialized = true;
  }

  void dispose() {
    if (!_isRecorderInitialized) return;
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    _isRecorderInitialized = false;
  }

  Future _record() async {
    if (!_isRecorderInitialized) return;
    Directory directory = await getApplicationDocumentsDirectory();
    String filepath = directory.path;
    String tempDateTime = DateTime.now().millisecondsSinceEpoch.toString();
    filepath += '/$tempDateTime.aac';
    tempfilename = '$tempDateTime.aac';
    recentFilePath = filepath;
    await _audioRecorder!.startRecorder(
      toFile: filepath,
    );
  }

  Future _stop() async {
    if (!_isRecorderInitialized) return;
    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecording() async {
    if (_audioRecorder!.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }
}
