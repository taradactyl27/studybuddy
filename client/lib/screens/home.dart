import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/color_constants.dart';
import 'package:studybuddy/routes/hero_route.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/services/course_state.dart';
import 'package:studybuddy/services/recents_state.dart';
import 'package:studybuddy/widgets/audio_form.dart';
import 'package:studybuddy/widgets/class_creation_card.dart';
import 'package:studybuddy/services/database.dart' as database;
import 'package:studybuddy/services/auth.dart' show User;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:studybuddy/services/api.dart'
    show getSearchResults, getSearchKey;
import 'package:studybuddy/widgets/course_tile.dart';
import 'package:studybuddy/widgets/search_result.dart';
import 'package:studybuddy/widgets/side_menu.dart';

import "../route_observer.dart";
import '../responsive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with RouteAware, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _searchController;
  late AnimationController _controller;
  int currentIndex = 0;
  bool filterFavorites = false;
  bool isSearching = false;
  bool isLoading = true;
  bool toggle = false;
  Map searchResults = {};
  late String uid;
  late Future<List<dynamic>> _recentlyViewed;
  late Future<String> _searchApiKey;

  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: 0.5,
    );
    uid = context.read<User>().uid;
    _searchApiKey = getSearchKey();
    _recentlyViewed = database.getRecentActivity(uid);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPush() {
    setState(() {
      _recentlyViewed = database.getRecentActivity(uid);
    });
  }

  @override
  void didPopNext() {
    setState(() {
      _recentlyViewed = database.getRecentActivity(uid);
    });
  }

  List<dynamic> orderRecents(
      List<QueryDocumentSnapshot<Object?>> docs, List<dynamic> ids) {
    return ids
        .map((id) => docs.firstWhere((doc) => doc.id == id.split("/").last))
        .toList();
  }

  void _retryKey() {
    setState(() {
      _searchApiKey = getSearchKey();
    });
  }

  void submitSearch(AsyncSnapshot<String> snapshot) async {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData && snapshot.data != "") {
        setState(() {
          isSearching = true;
          isLoading = true;
        });
        Map results =
            await getSearchResults(snapshot.data!, _searchController.text);
        setState(() {
          searchResults = results;
          isLoading = false;
        });
      } else {
        print("retrying algolia key!!");
        _retryKey();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (ModalRoute.of(context)!.isCurrent) {
    //   print("CURRENT YUH YUH");
    // }
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
        key: _scaffoldKey,
        drawer: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: const SideMenu(),
        ),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: kIsWeb
            ? FloatingActionButtonLocation.endFloat
            : FloatingActionButtonLocation.endDocked,
        floatingActionButton: SpeedDial(
          iconTheme: const IconThemeData(color: kLightModeIconSecondary),
          icon: Icons.add,
          activeIcon: Icons.close,
          spacing: 10,
          overlayColor: Theme.of(context).colorScheme.secondary,
          overlayOpacity: 0.1,
          children: [
            SpeedDialChild(
                child: const Icon(Icons.my_library_add_rounded),
                label: "Add Course",
                onTap: () {
                  Navigator.of(context)
                      .push(HeroDialogRoute(builder: (context) {
                    return const ClassCreationCard();
                  }));
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
            SpeedDialChild(
                child: const Icon(Icons.mode_standby),
                label: "Record Lecture",
                onTap: () {
                  Navigator.of(context).pushNamed(routes.recordingPage);
                }),
          ],
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            padding: const EdgeInsets.only(left: 15, right: 15),
            children: [
              const SizedBox(height: 65),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (kIsWeb && !Responsive.isDesktop(context))
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                    ),
                  if (kIsWeb && !Responsive.isDesktop(context))
                    const SizedBox(width: 20),
                  FutureBuilder<String>(
                      future: _searchApiKey,
                      builder: (context, snapshot) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width - 30,
                          height: 40,
                          child: TextField(
                            onTap: () {
                              print("clicking works");
                            },
                            selectionHeightStyle: BoxHeightStyle.tight,
                            onSubmitted: (value) async {
                              submitSearch(snapshot);
                            },
                            decoration: InputDecoration(
                              labelText: "Search...",
                              labelStyle: GoogleFonts.nunito(),
                              fillColor: kBgLightColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: const BorderSide(),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  submitSearch(snapshot);
                                },
                                icon: const Icon(Icons.search),
                              ),
                            ),
                            controller: _searchController,
                          ),
                        );
                      }),
                ],
              ),
              const SizedBox(height: 20),
              if (isSearching)
                SearchResultBox(isLoading: isLoading, results: searchResults),
              if (isSearching) const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recently Viewed",
                      style: GoogleFonts.nunito(
                          textStyle: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                      ))),
                ],
              ),
              FutureBuilder<List<dynamic>>(
                  future: _recentlyViewed,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(top: 20.0, bottom: 20.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                            "theme/viewed_empty.png")),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: SizedBox(
                                    width: 175,
                                    child: Text(
                                      "Your recently viewed transcripts will automatically pop up here!",
                                      style: GoogleFonts.nunito(
                                          fontStyle: FontStyle.italic),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              ]),
                        );
                      }
                      final recentIDs = snapshot.data!;
                      return SizedBox(
                        height: 170,
                        child: StreamBuilder(
                            stream: database.getRecentTranscripts(recentIDs),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox(
                                    height: 170,
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              }
                              return ListView(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                children:
                                    orderRecents(snapshot.data!.docs, recentIDs)
                                        .map((transcript) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, routes.transcriptPage,
                                          arguments: {
                                            'transcript': transcript,
                                            'course_id': transcript
                                                .reference.parent.parent!.id
                                          });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 15),
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: Material(
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.light
                                            ? null
                                            : const Color(0xFF424242),
                                        elevation: 6,
                                        child: SizedBox(
                                          height: 150,
                                          width: 140,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                      height: 60,
                                                      child: Center(
                                                        child: Icon(
                                                            Icons
                                                                .chrome_reader_mode_outlined,
                                                            size: 60,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary
                                                                .withOpacity(
                                                                    0.7)),
                                                      )),
                                                  const Divider(
                                                    height: 10,
                                                    thickness: 1,
                                                  ),
                                                  Text(
                                                    transcript['audioRef']
                                                        .split('/')[1]
                                                        .split('.')
                                                        .first,
                                                    style: GoogleFonts.nunito(
                                                        fontWeight:
                                                            FontWeight.w700),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "Created: ${DateFormat.yMMMMEEEEd().format(transcript['created'].toDate())}",
                                                    style: GoogleFonts.nunito(
                                                        fontSize: 12),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }),
                      );
                    } else {
                      return const SizedBox(
                          height: 170,
                          child: Center(child: CircularProgressIndicator()));
                    }
                  }),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Your Courses",
                          style: GoogleFonts.nunito(
                              textStyle: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w400,
                          ))),
                      InkWell(
                          onTap: () {
                            setState(() {
                              if (filterFavorites) {
                                _controller.reverse(from: 0.5);
                              } else {
                                _controller.forward(from: 0.0);
                              }
                              filterFavorites = !filterFavorites;
                            });
                          },
                          child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(_controller),
                              child: const Icon(Icons.filter_list, size: 24)))
                    ],
                  ),
                  StreamBuilder(
                      stream: database.getUserCourseStream(uid),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                              height: 375,
                              child:
                                  Center(child: CircularProgressIndicator()));
                        }
                        if (snapshot.data!.size == 0) {
                          return Column(children: [
                            const SizedBox(height: 35),
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
                                    image:
                                        AssetImage("theme/courses_empty.png")),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                width: 200,
                                child: Text(
                                  "You are not a part of any course yet. Click the + button on the bottom right to begin!",
                                  style: GoogleFonts.nunito(
                                      fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ]);
                        }
                        List<QueryDocumentSnapshot<Object?>> list =
                            snapshot.data!.docs;
                        if (filterFavorites) {
                          list.sort((a, b) {
                            if (b['roles'][uid]['favorite']) {
                              return 1;
                            } else {
                              return -1;
                            }
                          });
                        }
                        return SizedBox(
                          height: 375,
                          child: GridView.count(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            crossAxisCount:
                                MediaQuery.of(context).size.width < 940 &&
                                        MediaQuery.of(context).size.width > 600
                                    ? 1
                                    : 2,
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 15.0),
                            children: list.map((course) {
                              return InkWell(
                                onTap: () {
                                  Provider.of<CourseState>(context,
                                          listen: false)
                                      .changeCourseStream(course.id);
                                  if (!kIsWeb) {
                                    Navigator.pushNamed(
                                      context,
                                      routes.coursePage,
                                    );
                                  }
                                },
                                child: CourseTile(
                                  course: course,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      })
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: kIsWeb
            ? null
            : BottomAppBar(
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
                    ])),
      ),
    );
  }
}
