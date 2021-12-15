import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  final TextEditingController _searchController = TextEditingController();
  int currentIndex = 0;
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
    uid = context.read<User>().uid;
    _searchApiKey = getSearchKey(true);
    _recentlyViewed = database.getRecentActivity(uid);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
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
    if (ModalRoute.of(context)!.isCurrent) {
      print("CURRENT YUH YUH");
    }
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
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: kIsWeb
            ? FloatingActionButtonLocation.endFloat
            : FloatingActionButtonLocation.endDocked,
        floatingActionButton: SpeedDial(
          iconTheme: const IconThemeData(color: Colors.white),
          icon: Icons.add,
          activeIcon: Icons.close,
          spacing: 10,
          overlayColor: Colors.blueGrey,
          overlayOpacity: 0.6,
          children: [
            SpeedDialChild(
                child: const Icon(Icons.my_library_add_rounded,
                    color: Colors.black),
                label: "Add Course",
                onTap: () {
                  Navigator.of(context)
                      .push(HeroDialogRoute(builder: (context) {
                    return const ClassCreationCard();
                  }));
                }),
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
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            padding: const EdgeInsets.only(top: 65, left: 15, right: 15),
            children: [
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
                        return Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              selectionHeightStyle: BoxHeightStyle.tight,
                              onSubmitted: (value) async {
                                submitSearch(snapshot);
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
                                    submitSearch(snapshot);
                                  },
                                  icon: const Icon(Icons.search),
                                ),
                              ),
                              controller: _searchController,
                            ),
                          ),
                        );
                      }),
                ],
              ),
              if (isSearching)
                SearchResultBox(isLoading: isLoading, results: searchResults),
              const SizedBox(height: 20),
              FutureBuilder<List<dynamic>>(
                  future: _recentlyViewed,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return const SizedBox(width: 0.0, height: 0.0);
                      }
                      final recentIDs = snapshot.data!;
                      print("RECENTVIEW CONTEXT");
                      print(context.read<RecentsState>().recentlyViewed);
                      print(_recentlyViewed);
                      return SizedBox(
                        height: 120,
                        child: Column(children: [
                          Text("Recently Viewed",
                              style: GoogleFonts.nunito(
                                  textStyle: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w400,
                              ))),
                          Expanded(
                            child: StreamBuilder(
                                stream:
                                    database.getRecentTranscripts(recentIDs),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox(
                                        height: 200,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator()));
                                  }
                                  return ListView(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    children: orderRecents(
                                            snapshot.data!.docs, recentIDs)
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
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 200),
                                          child: Card(
                                            child: ListTile(
                                              dense: true,
                                              title: Text(transcript['audioRef']
                                                  .split('/')[1]),
                                              subtitle: Text(transcript
                                                  .reference.parent.parent!.id),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }),
                          ),
                        ]),
                      );
                    } else {
                      return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()));
                    }
                  }),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Courses",
                      style: GoogleFonts.nunito(
                          textStyle: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                      ))),
                  StreamBuilder(
                      stream: database.getUserCourseStream(uid),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                              height: 300,
                              child:
                                  Center(child: CircularProgressIndicator()));
                        }
                        return SizedBox(
                          height: 300,
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
                                const EdgeInsets.only(top: 15.0, bottom: 15.0),
                            children: snapshot.data!.docs.map((course) {
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
