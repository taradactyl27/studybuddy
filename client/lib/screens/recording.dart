import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:studybuddy/routes/hero_route.dart';
import 'package:studybuddy/services/sound_player.dart';
import 'package:studybuddy/services/sound_recorder.dart';
import 'package:studybuddy/widgets/audio_form.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new_sharp)),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          padding: const EdgeInsets.only(top: 200),
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
                    return Text(
                        StopWatchTimer.getDisplayTime(snapshot.data ?? 0),
                        style: GoogleFonts.nunito(
                            textStyle: const TextStyle(fontSize: 36)));
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(175, 50),
                    primary: primary1,
                    onPrimary: onPrimary1,
                  ),
                  icon: Icon(icon1),
                  label: Text(text1,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
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
                    minimumSize: const Size(175, 50),
                    primary: primary2,
                    onPrimary: onPrimary2,
                  ),
                  icon: Icon(icon2),
                  label: Text(text2,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                  onPressed: () async {
                    if (isPlaying) {
                      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                    } else {
                      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                    }
                    await player.togglePlaying(
                        whenFinished: () => setState(() {
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.stop);
                            }));
                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(175, 50),
                      onPrimary: Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.of(context)
                          .push(HeroDialogRoute(builder: (context) {
                        return const AudioForm();
                      }));
                    },
                    icon: const Icon(Icons.check),
                    label: Text('Finished',
                        style:
                            GoogleFonts.nunito(fontWeight: FontWeight.w600))),
                StreamBuilder(
                  stream: recorder.getRecorderStream,
                  builder: (context, AsyncSnapshot<dynamic> snapshot) {
                    if (!snapshot.hasData) {
                      print("NO DATA");
                      return Container();
                    }
                    return Text(snapshot.data.decibels);
                  },
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
