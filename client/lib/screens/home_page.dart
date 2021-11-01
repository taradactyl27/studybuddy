import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:studybuddy/routes/hero_route.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/screens/audio_form.dart';
import 'package:studybuddy/screens/class_creation_card.dart';
import 'package:studybuddy/services/database.dart' as database;
import 'package:studybuddy/services/auth.dart' show User;
import 'package:studybuddy/services/storage.dart' as storage;
import 'package:studybuddy/widgets/bottom_bar_painter.dart';
import 'package:studybuddy/widgets/course_tile.dart';
import 'package:studybuddy/widgets/search_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  bool isSearching = false;
  bool isLoading = true;
  bool toggle = false;
  Map searchResults = {};
  final TextEditingController _searchController = TextEditingController();
  late String uid;
  late Future<List<dynamic>> _courseIds;
  late AnimationController _controller;
  late Animation _animation;

  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
        reverseDuration: const Duration(milliseconds: 275));
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _controller.addListener(() {
      setState(() {});
    });
    uid = context.read<User>().uid;
    _courseIds = database.getUserCourseList(uid);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshCourses() {
    setState(() {
      _courseIds = database.getUserCourseList(uid);
    });
  }

  Alignment alignment1 = const Alignment(0.0, -1.3);
  Alignment alignment2 = const Alignment(0.0, -1.3);
  double size1 = 50;
  double size2 = 50;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        setState(() {
          isSearching = false;
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: const EdgeInsets.only(top: 55),
          child: Stack(
            children: [
              // Positioned(
              //     top: 50,
              //     left: 5,
              //     // child: Container(
              //     //     padding: const EdgeInsets.all(25),
              //     //     child: Column(children: [
              //     //       Text('Welcome back,',
              //     //           style: GoogleFonts.nunito(
              //     //               textStyle: const TextStyle(fontSize: 24))),
              //     //       Text(currentUser!.displayName ?? "anonymous",
              //     //           style: GoogleFonts.nunito(
              //     //               textStyle: const TextStyle(fontSize: 24)))
              //     //     ]))),
              Container(
                  padding: const EdgeInsets.all(30),
                  height: 100,
                  child: TextField(
                    onSubmitted: (value) async {
                      setState(() {
                        isSearching = true;
                        isLoading = true;
                      });
                      Map results = await storage
                          .getSearchResults(_searchController.text);
                      setState(() {
                        searchResults = results;
                        isLoading = false;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Search...",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          setState(() {
                            isSearching = true;
                            isLoading = true;
                          });
                          Map results = await storage
                              .getSearchResults(_searchController.text);
                          setState(() {
                            searchResults = results;
                            isLoading = false;
                          });
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ),
                    controller: _searchController,
                  )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 80, left: 30),
                    child: Text("Your Courses",
                        style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w400,
                        ))),
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: _courseIds,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          return StreamBuilder(
                              stream: database.getCourseStream(snapshot.data),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox(
                                      height: 200,
                                      child: Center(
                                          child: CircularProgressIndicator()));
                                }
                                return SizedBox(
                                  height: 400,
                                  child: GridView.count(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    crossAxisSpacing: 20,
                                    crossAxisCount: 2,
                                    padding: const EdgeInsets.all(30.0),
                                    children: snapshot.data!.docs.map((course) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                                  context, routes.coursePage,
                                                  arguments: {'course': course})
                                              .then((value) {
                                            _refreshCourses();
                                          });
                                        },
                                        child: CourseTile(
                                          course: course,
                                          refreshCourses: _refreshCourses,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              });
                        } else {
                          return const SizedBox(
                              height: 200,
                              child: Center(child: Text('Add a course!')));
                        }
                      } else {
                        return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()));
                      }
                    },
                  ),
                ],
              ),
              if (isSearching)
                Positioned(
                    top: 45,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                        margin: const EdgeInsets.all(30),
                        height: 300,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black45),
                            borderRadius: BorderRadius.circular(15.0)),
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : ListView(
                                padding: const EdgeInsets.only(
                                    bottom: 0, left: 0, right: 0, top: 5),
                                shrinkWrap: true,
                                children:
                                    searchResults['hits'].map<Widget>((hit) {
                                  return InkWell(
                                      onTap: () async {
                                        print(hit['objectID']);
                                        print(hit['course']);
                                        DocumentSnapshot transcript =
                                            await database
                                                .getCourseTranscription(
                                                    hit['objectID'],
                                                    hit['course']);
                                        print(transcript.exists);
                                        Navigator.pushNamed(
                                            context, routes.transcriptPage,
                                            arguments: {
                                              'transcript': transcript,
                                              'course_id': hit['course'],
                                            });
                                      },
                                      child: SearchField(hit: hit));
                                }).toList(),
                              ))),
              Positioned(
                bottom: 0,
                left: 0,
                child: SizedBox(
                  width: size.width,
                  height: 80,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(size.width, 80),
                        painter: BNBCustomPainter(),
                      ),
                      Stack(alignment: const Alignment(0, -1.4), children: [
                        AnimatedAlign(
                            duration: toggle
                                ? const Duration(milliseconds: 275)
                                : const Duration(milliseconds: 850),
                            alignment: alignment1,
                            curve: toggle ? Curves.easeIn : Curves.easeOut,
                            child: FutureBuilder<List<dynamic>>(
                              future: _courseIds,
                              builder: (context, snapshot) {
                                var audioButtonContainer = AnimatedContainer(
                                  duration: const Duration(milliseconds: 275),
                                  curve:
                                      toggle ? Curves.easeIn : Curves.easeOut,
                                  height: size1,
                                  width: size1,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF63FFD5),
                                    borderRadius: BorderRadius.circular(40.0),
                                  ),
                                  child: const Icon(Icons.mic_rounded,
                                      color: Colors.white),
                                );
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  if (snapshot.data!.isNotEmpty) {
                                    return StreamBuilder(
                                        stream: database
                                            .getCourseStream(snapshot.data),
                                        builder: (context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (!snapshot.hasData) {
                                            return GestureDetector(
                                              onTap: () {
                                                print("loading course data");
                                              },
                                              child: audioButtonContainer,
                                            );
                                          }
                                          return GestureDetector(
                                            onTap: () async {
                                              print("opening audio form");
                                              await Navigator.of(context).push(
                                                  HeroDialogRoute(
                                                      builder: (context) {
                                                return AudioForm(
                                                  courseList:
                                                      snapshot.data!.docs,
                                                );
                                              }));
                                            },
                                            child: audioButtonContainer,
                                          );
                                        });
                                  } else {
                                    return GestureDetector(
                                      onTap: () {
                                        print("must create a course first");
                                      },
                                      child: audioButtonContainer,
                                    );
                                  }
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      print("loading course ids");
                                    },
                                    child: audioButtonContainer,
                                  );
                                }
                              },
                            )),
                        AnimatedAlign(
                            duration: toggle
                                ? const Duration(milliseconds: 275)
                                : const Duration(milliseconds: 850),
                            alignment: alignment2,
                            curve: toggle ? Curves.easeIn : Curves.easeOut,
                            child: Hero(
                              tag: 'add',
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Navigator.of(context)
                                      .push(HeroDialogRoute(builder: (context) {
                                    return const ClassCreationCard();
                                  })).then((value) {
                                    _refreshCourses();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 275),
                                  curve:
                                      toggle ? Curves.easeIn : Curves.easeOut,
                                  height: size2,
                                  width: size2,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF63FFD5),
                                    borderRadius: BorderRadius.circular(40.0),
                                  ),
                                  child: const Icon(
                                      Icons.my_library_add_rounded,
                                      color: Colors.white),
                                ),
                              ),
                            )),
                        Transform.rotate(
                          angle: _animation.value * pi * (3 / 4),
                          child: FloatingActionButton(
                              backgroundColor: const Color(0xFF61A3FE),
                              child: const Icon(Icons.add_rounded,
                                  color: Colors.white),
                              elevation: 0.1,
                              onPressed: () {
                                setState(() {
                                  if (!toggle) {
                                    toggle = !toggle;
                                    _controller.forward();
                                    Future.delayed(
                                        const Duration(milliseconds: 10), () {
                                      alignment1 = const Alignment(-0.35, -2.5);
                                    });
                                    Future.delayed(
                                        const Duration(milliseconds: 10), () {
                                      alignment2 = const Alignment(0.35, -2.5);
                                    });
                                  } else {
                                    toggle = !toggle;
                                    _controller.reverse();
                                    alignment1 = const Alignment(0, -1.3);
                                    alignment2 = const Alignment(0, -1.3);
                                  }
                                });
                              }),
                        ),
                      ]),
                      SizedBox(
                        width: size.width,
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                              width: size.width * 0.20,
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
        ),
      ),
    );
  }
}
