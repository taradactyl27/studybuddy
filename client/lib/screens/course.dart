import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:studybuddy/services/auth.dart' show User;
import 'package:studybuddy/routes/hero_route.dart';
import 'package:studybuddy/services/course_state.dart';
import 'package:studybuddy/widgets/audio_form.dart';
import 'package:studybuddy/services/database.dart' as database;
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:studybuddy/widgets/bottom_bar_painter.dart';
import 'package:studybuddy/widgets/sharing_form.dart';
import 'package:studybuddy/widgets/transcript_tile.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({
    Key? key,
  }) : super(key: key);
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  int currentIndex = 0;
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
    print(course != null);
    return Provider.of<CourseState>(context).currentCourseId != ""
        ? Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
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
                        return SharingForm();
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
              child: Stack(
                children: [
                  ClipPath(
                    clipper: WaveClipperTwo(),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF61A3FE), Color(0xFF63FFD5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          StreamBuilder(
                              stream: course,
                              builder: (context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox(
                                      height: 200,
                                      child: Center(
                                          child: CircularProgressIndicator()));
                                }
                                return Positioned(
                                    bottom: 50,
                                    left: 50,
                                    child: Text(
                                        snapshot.data!.get("name") ?? "error",
                                        style: GoogleFonts.nunito(
                                            textStyle: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w600))));
                              }),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.only(top: 80, left: 30),
                              child: Text("Your Transcripts",
                                  style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w400,
                                  )))),
                          StreamBuilder(
                              stream: database.getCourseTranscriptions(
                                  Provider.of<CourseState>(context)
                                      .currentCourseId),
                              builder: (context,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
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

                                        if (transcript
                                            .data()
                                            .containsKey('text')) {
                                          return InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  routes.transcriptPage,
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
                      )),
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
                                        Provider.of<CourseState>(context)
                                            .currentCourseId);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Delete Course"),
                                ),
                              ));
                        }
                        return Container();
                      }),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 80,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (!kIsWeb)
                            CustomPaint(
                              size: Size(MediaQuery.of(context).size.width, 80),
                              painter: BNBCustomPainter(),
                            ),
                          Stack(alignment: const Alignment(0, 0), children: [
                            Center(
                              heightFactor: 0.82,
                              child: FloatingActionButton(
                                backgroundColor: const Color(0xFF61A3FE),
                                child: const Icon(Icons.add_rounded,
                                    color: Colors.white),
                                elevation: 0.1,
                                onPressed: () async {
                                  await Navigator.of(context)
                                      .push(HeroDialogRoute(builder: (context) {
                                    return AudioForm();
                                  }));
                                },
                              ),
                            ),
                          ]),
                          if (!kIsWeb)
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 80,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.home,
                                      color: currentIndex == 0
                                          ? const Color(0xFF61A3FE)
                                          : Colors.grey.shade400,
                                    ),
                                    onPressed: () {
                                      setBottomBarIndex(0);
                                    },
                                    splashColor: Colors.white,
                                  ),
                                  IconButton(
                                      icon: Icon(
                                        Icons.menu_book_rounded,
                                        color: currentIndex == 1
                                            ? const Color(0xFF61A3FE)
                                            : Colors.grey.shade400,
                                      ),
                                      onPressed: () {
                                        setBottomBarIndex(1);
                                      }),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                  ),
                                  IconButton(
                                      icon: Icon(
                                        Icons.bookmark,
                                        color: currentIndex == 2
                                            ? const Color(0xFF61A3FE)
                                            : Colors.grey.shade400,
                                      ),
                                      onPressed: () {
                                        setBottomBarIndex(2);
                                      }),
                                  IconButton(
                                      icon: Icon(
                                        Icons.settings_rounded,
                                        color: currentIndex == 3
                                            ? const Color(0xFF61A3FE)
                                            : Colors.grey.shade400,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, routes.settingsPage);
                                      }),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ))
        : const Center(child: Text("No Course Selected"));
  }
}
