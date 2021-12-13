import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/services/sound_player.dart';
import 'package:studybuddy/services/sound_recorder.dart';
//import 'package:flutter_sound/flutter_sound.dart';
//import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
//import 'package:permission_handler/permission_handler.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({Key? key}) : super(key: key);

  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final recorder = SoundRecorder();
  final player = SoundPlayer();

  @override
  void initState() {
    super.initState();
    recorder.init();
    player.init();
  }

  @override
  void dispose() async {
    player.dispose();
    recorder.dispose();
    await _stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = recorder.isRecording;
    final icon1 = isRecording ? Icons.stop : Icons.mic;
    final text1 = isRecording ? 'STOP' : 'START';
    final primary1 = isRecording ? Colors.red : Colors.white;
    final onPrimary1 = isRecording ? Colors.white : Colors.red;

    final isPlaying = player.isPlaying;
    final icon2 = isPlaying ? Icons.stop : Icons.play_arrow;
    final text2 = isPlaying ? 'Stop Playing' : 'Start Playing';
    final primary2 = isPlaying ? Colors.red : Colors.white;
    final onPrimary2 = isPlaying ? Colors.white : Colors.red;

    return Scaffold(
      body: Stack(
        children: [
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder(
                stream: _stopWatchTimer.rawTime,
                builder: (context, AsyncSnapshot<int> snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return Text(StopWatchTimer.getDisplayTime(snapshot.data ?? 0),
                      style: const TextStyle(fontSize: 32));
                },
              ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(175, 50),
                  primary: primary1,
                  onPrimary: onPrimary1,
                ),
                icon: Icon(icon1),
                label: Text(text1),
                onPressed: () async {
                  await recorder.toggleRecording();
                  if (isRecording) {
                    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                  } else {
                    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                  }
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(175, 50),
                  primary: primary2,
                  onPrimary: onPrimary2,
                ),
                icon: Icon(icon2),
                label: Text(text2),
                onPressed: () async {
                  await player.togglePlaying(
                      whenFinished: () => setState(() {}));
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(175, 50),
                    primary: Colors.white,
                    onPrimary: Colors.red,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.check),
                  label: Text('Finished'))
              //child: const Text('Finished'))
            ],
          ))
        ],
      ),
    );
  }

/*
  @override
  Widget buildadad(BuildContext context) {
 
    final isRecording = recorder.isRecording;
    final icon1 = isRecording ? Icons.stop : Icons.mic;
    final text1 = isRecording ? 'STOP' : 'START';
    final primary1 = isRecording ? Colors.red : Colors.white;
    final onPrimary1 = isRecording ? Colors.white : Colors.red;

      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(175,50),
          primary: primary,
          onPrimary: onPrimary,
        ),
        icon: Icon(icon),
        label: Text(text),
          onPressed: () async {
            final isRecording = await recorder.toggleRecording();
            setState(() {});
          },
        );
      
      
    
    }
  
  Widget buildPlay(){
    final isPlaying = false;
    final icon2 = isPlaying ? Icons.stop : Icons.play_arrow;
    final text2 = isPlaying ? 'Stop Playing' : 'Start Playing';
    final primary2 = isPlaying ? Colors.red : Colors.white;
    final onPrimary2 = isPlaying ? Colors.white : Colors.red;
    
    
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(175,50),
          primary: primary,
          onPrimary: onPrimary,
        ),
        icon: Icon(icon),
        label: Text(text),
          onPressed: () async {
            await player.togglePlaying(whenFinished: (){});
          },
        );
  }
  */

}
