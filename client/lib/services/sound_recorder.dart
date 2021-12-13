import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

//final pathForSavedAudio = 'example_audio.aac';
String recentFilePath = "";
String tempfilename = "";
class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;
  bool get isRecording => _audioRecorder!.isRecording;
  //String _recentFilePath = "";

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone Permission Not Granted');
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
    print('recording started');

    Directory directory = await getApplicationDocumentsDirectory();
    String filepath = directory.path;
        //'/' +
        //DateTime.now().millisecondsSinceEpoch.toString() +
        //'.aac';

    String TempDateTime = DateTime.now().millisecondsSinceEpoch.toString();
    filepath += '/' + TempDateTime + '.aac';
    tempfilename = TempDateTime;

    print(filepath);
    recentFilePath = filepath;
    await _audioRecorder!.startRecorder(
      toFile: filepath,
    );
    //await _audioRecorder!.startRecorder(toFile: pathForSavedAudio,);
  }

  Future _stop() async {
    if (!_isRecorderInitialized) return;
    print('recording stopped');
    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecording() async {
    if (_audioRecorder!.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }

  //String get recentFilePath => _recentFilePath;

}
