import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/routes/hero_route.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/services/auth.dart' show User;
import 'package:studybuddy/services/course_state.dart';
import 'package:studybuddy/services/database.dart' as database;
import 'package:studybuddy/widgets/audio_form.dart';
import 'package:studybuddy/widgets/sharing_form.dart';
import 'package:studybuddy/widgets/side_menu.dart';
import 'package:studybuddy/widgets/transcript_tile.dart';
import 'package:timezone/timezone.dart' as tz;

import "../services/notifications.dart";

class CoursePage extends StatefulWidget {
  const CoursePage({
    Key? key,
  }) : super(key: key);
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  int currentIndex = 0;
  bool enabled = false;
  String courseName = '';
  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<User>().uid;
    Stream<DocumentSnapshot<Map<String, dynamic>>>? course =
        Provider.of<CourseState>(context).courseStream;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Provider.of<CourseState>(context).currentCourseId != ""
        ? Scaffold(
            key: _scaffoldKey,
            drawer: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: const SideMenu(),
            ),
            resizeToAvoidBottomInset: false,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            floatingActionButton: SpeedDial(
              iconTheme: const IconThemeData(color: Colors.white),
              icon: Icons.add,
              activeIcon: Icons.close,
              spacing: 10,
              overlayColor: Colors.blueGrey,
              overlayOpacity: 0.6,
              children: [
                SpeedDialChild(
                    child: const Icon(Icons.mic_rounded, color: Colors.black),
                    label: 'Upload Lecture',
                    onTap: () {
                      Navigator.of(context)
                          .push(HeroDialogRoute(builder: (context) {
                        return const AudioForm();
                      }));
                    })
              ],
            ),
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_sharp)),
              title: Stack(
                children: [
                  StreamBuilder(
                      stream: course,
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                              height: 50,
                              child:
                                  Center(child: CircularProgressIndicator()));
                        }
                        courseName = snapshot.data!.get("name");
                        return Text(snapshot.data!.get("name") ?? "error",
                            style: GoogleFonts.nunito(
                                textStyle: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w200)));
                      }),
                ],
              ),
              actions: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      print(courseName);
                      setState(() {
                        enabled = !enabled;
                        enableNotification(
                            enabled,
                            context.read<CourseState>().currentCourseId,
                            courseName);
                      });
                    },
                    icon: enabled
                        ? const Icon(
                            Icons.notifications_none_outlined,
                            color: Colors.white,
                            size: 24.0,
                          )
                        : const Icon(
                            Icons.notifications_off_outlined,
                            color: Colors.white,
                            size: 24.0,
                          ),
                    label: const Text("Reminders",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Provider.of<CourseState>(context, listen: false)
                          .resetCourseStream(
                              Provider.of<CourseState>(context, listen: false)
                                  .currentCourseId);
                      await Navigator.of(context)
                          .push(HeroDialogRoute(builder: (context) {
                        return const SharingForm();
                      }));
                    },
                    icon: const Icon(
                      Icons.folder_shared,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    label: const Text("Share",
                        style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView(
                padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
                children: [
                  const SizedBox(
                    height: 150,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your Transcripts",
                          style: GoogleFonts.nunito(
                              textStyle: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w400,
                          ))),
                      StreamBuilder(
                          stream: database.getCourseTranscriptions(
                              Provider.of<CourseState>(context)
                                  .currentCourseId),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                  height: 200,
                                  child: Center(
                                      child: CircularProgressIndicator()));
                            }
                            return SizedBox(
                                height: 400,
                                width: MediaQuery.of(context).size.width,
                                child: ListView(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(10.0),
                                  children:
                                      snapshot.data!.docs.map((transcript) {
                                    var data = transcript.data();
                                    final courseID =
                                        Provider.of<CourseState>(context)
                                            .currentCourseId;

                                    if (data.containsKey('text')) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, routes.transcriptPage,
                                              arguments: {
                                                'transcript': transcript,
                                                'course_id': courseID
                                              });
                                        },
                                        child: TranscriptTile(
                                          transcript: transcript,
                                          courseId: courseID,
                                        ),
                                      );
                                    } else {
                                      return InkWell(
                                        onTap: null,
                                        child: TranscriptTile(
                                          transcript: transcript,
                                          courseId: courseID,
                                        ),
                                      );
                                    }
                                  }).toList(),
                                ));
                          })
                    ],
                  ),
                  StreamBuilder(
                      stream: course,
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (!snapshot.hasData) return Container();
                        if (snapshot.data!.get("roles")[uid]["role"] ==
                            "owner") {
                          return Positioned(
                              width: MediaQuery.of(context).size.width,
                              bottom: 100,
                              left: 0,
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await database.deleteCourse(
                                        uid,
                                        Provider.of<CourseState>(context,
                                                listen: false)
                                            .currentCourseId);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Delete Course"),
                                ),
                              ));
                        }
                        return Container();
                      }),
                ],
              ),
            ),
            bottomNavigationBar: !kIsWeb
                ? BottomAppBar(
                    shape: const CircularNotchedRectangle(),
                    notchMargin: 8.0,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              _scaffoldKey.currentState!.openDrawer();
                            },
                          ),
                        ]))
                : null)
        : const Center(child: Text("No Course Selected"));
  }
}
