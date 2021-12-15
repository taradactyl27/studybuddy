import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/color_constants.dart';
import 'package:studybuddy/services/auth.dart' show User;
import 'package:studybuddy/routes/hero_route.dart';
import 'package:studybuddy/services/course_state.dart';
import 'package:studybuddy/widgets/audio_form.dart';
import 'package:studybuddy/services/database.dart' as database;
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:studybuddy/widgets/flashcard_tile.dart';
import 'package:studybuddy/widgets/sharing_form.dart';
import 'package:studybuddy/widgets/side_menu.dart';
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
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Provider.of<CourseState>(context).currentCourseId != ""
        ? StreamBuilder(
            stream: course,
            builder: (context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return Scaffold(
                  key: _scaffoldKey,
                  drawer: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: const SideMenu(),
                  ),
                  resizeToAvoidBottomInset: false,
                  backgroundColor: kIsWeb &&
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                      ? const Color(0xFF323232)
                      : null,
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endDocked,
                  floatingActionButton: kIsWeb
                      ? null
                      : SpeedDial(
                          iconTheme: const IconThemeData(
                              color: kLightModeIconSecondary),
                          icon: Icons.add,
                          activeIcon: Icons.close,
                          spacing: 10,
                          overlayColor: kOverlayColor,
                          overlayOpacity: 0.6,
                          children: [
                            SpeedDialChild(
                                child: const Icon(Icons.view_carousel),
                                label: 'Create Flashcard Set',
                                onTap: () async {
                                  String cardsetId =
                                      await database.createFlashcardSet(
                                          Provider.of<CourseState>(context,
                                                  listen: false)
                                              .currentCourseId);
                                  Navigator.of(context).pushNamed(
                                      routes.flashcardPage,
                                      arguments: {"cardsetId": cardsetId});
                                }),
                            SpeedDialChild(
                                child: const Icon(Icons.mic_rounded),
                                label: 'Upload Lecture',
                                onTap: () {
                                  Navigator.of(context)
                                      .push(HeroDialogRoute(builder: (context) {
                                    return const AudioForm();
                                  }));
                                }),
                            if (snapshot.data!.exists &&
                                snapshot.data!.get("roles")[uid]["role"] ==
                                    "owner")
                              SpeedDialChild(
                                  onTap: () async {
                                    await database.deleteCourse(
                                        uid,
                                        Provider.of<CourseState>(context,
                                                listen: false)
                                            .currentCourseId);
                                    if (!kIsWeb) Navigator.pop(context);
                                  },
                                  child: const Icon(Icons.delete),
                                  label: "Delete Course",
                                  backgroundColor: kDangerColor,
                                  labelBackgroundColor: kDangerColor)
                          ],
                        ),
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                        onPressed: () {
                          if (kIsWeb) {
                            Provider.of<CourseState>(context, listen: false)
                                .removeCourseStream();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_sharp)),
                    title: snapshot.data!.exists
                        ? Stack(
                            children: [
                              Text(snapshot.data!.get("name") ?? "error",
                                  style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600)))
                            ],
                          )
                        : null,
                    actions: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Provider.of<CourseState>(context, listen: false)
                                .resetCourseStream(Provider.of<CourseState>(
                                        context,
                                        listen: false)
                                    .currentCourseId);
                            await Navigator.of(context)
                                .push(HeroDialogRoute(builder: (context) {
                              return const SharingForm();
                            }));
                          },
                          icon: const Icon(
                            Icons.folder_shared,
                            color: kLightModeIconSecondary,
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
                      padding:
                          const EdgeInsets.only(top: 0, left: 15, right: 15),
                      children: [
                        const SizedBox(height: 15),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Flashcards",
                                  style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w400,
                                  ))),
                              StreamBuilder(
                                  stream: database.getCourseFlashcards(
                                      Provider.of<CourseState>(context)
                                          .currentCourseId),
                                  builder: (context,
                                      AsyncSnapshot<
                                              QuerySnapshot<
                                                  Map<String, dynamic>>>
                                          snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox(
                                          height: 150,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()));
                                    }
                                    if (snapshot.data!.size == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20.0, bottom: 10.0),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(
                                                  top: 15,
                                                  right: 15,
                                                  left: 15,
                                                  bottom: 15,
                                                ),
                                                height: 100,
                                                width: 150,
                                                decoration: const BoxDecoration(
                                                  image: DecorationImage(
                                                      fit: BoxFit.fitHeight,
                                                      image: AssetImage(
                                                          "theme/questions_empty.png")),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Center(
                                                child: SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    "You don't have any uploaded card sets yet. Click the + button on the bottom right to begin!",
                                                    style: GoogleFonts.nunito(),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              )
                                            ]),
                                      );
                                    }
                                    return SizedBox(
                                        height: 150,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: GridView.count(
                                          crossAxisCount: 1,
                                          mainAxisSpacing: 15,
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: false,
                                          padding: const EdgeInsets.all(10.0),
                                          children: snapshot.data!.docs
                                              .map((cardset) {
                                            return InkWell(
                                              onTap: () {
                                                Navigator.of(context).pushNamed(
                                                    routes.flashcardPage,
                                                    arguments: {
                                                      'cardsetId': cardset.id
                                                    });
                                              },
                                              child: FlashCardTile(
                                                name: cardset['name'],
                                              ),
                                            );
                                          }).toList(),
                                        ));
                                  })
                            ]),
                        const SizedBox(height: 20),
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
                                    AsyncSnapshot<
                                            QuerySnapshot<Map<String, dynamic>>>
                                        snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox(
                                        height: 200,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator()));
                                  }
                                  if (snapshot.data!.size == 0) {
                                    return Column(children: [
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.only(
                                          top: 15,
                                          right: 15,
                                          left: 15,
                                          bottom: 15,
                                        ),
                                        height: 200,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.fitHeight,
                                              image: AssetImage(
                                                  "theme/lectures_empty.png")),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Center(
                                        child: SizedBox(
                                          width: 200,
                                          child: Text(
                                            "You don't have any uploaded lectures yet. Click the + button on the bottom right to begin!",
                                            style: GoogleFonts.nunito(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    ]);
                                  }
                                  return SizedBox(
                                      height: 400,
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.all(10.0),
                                        children: snapshot.data!.docs
                                            .map((transcript) {
                                          var data = transcript.data();
                                          final courseID =
                                              Provider.of<CourseState>(context)
                                                  .currentCourseId;

                                          if (data.containsKey('text')) {
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
                        ),
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
                      : null);
            })
        : Container(
            decoration: BoxDecoration(
                color: kIsWeb &&
                        MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                    ? const Color(0xFF323232)
                    : null),
            child: const Center(child: Text("No Course Selected")));
  }
}
