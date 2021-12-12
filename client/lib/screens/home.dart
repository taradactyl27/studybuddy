import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/color_constants.dart';

import 'package:studybuddy/routes/hero_route.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/services/course_state.dart';
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

import '../responsive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  int currentIndex = 0;
  bool isSearching = false;
  bool isLoading = true;
  bool toggle = false;
  Map searchResults = {};
  late String uid;
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
  }

  @override
  void dispose() {
    super.dispose();
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
          iconTheme: const IconThemeData(color: kLightModeIconSecondary),
          icon: Icons.add,
          activeIcon: Icons.close,
          spacing: 10,
          overlayColor: kOverlayColor,
          overlayOpacity: 0.6,
          children: [
            SpeedDialChild(
                child: const Icon(Icons.my_library_add_rounded,
                    color: kLightModeIcon),
                label: "Add Course",
                onTap: () {
                  Navigator.of(context)
                      .push(HeroDialogRoute(builder: (context) {
                    return const ClassCreationCard();
                  }));
                }),
            SpeedDialChild(
                child: const Icon(Icons.mic_rounded, color: kLightModeIcon),
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
                                labelStyle: GoogleFonts.nunito(
                                  textStyle:
                                      const TextStyle(color: kDarkTextColor),
                                ),
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
                          ),
                        );
                      }),
                ],
              ),
              if (isSearching)
                SearchResultBox(isLoading: isLoading, results: searchResults),
              const SizedBox(height: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Recently Edited",
                    style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w400,
                    ))),
                const SizedBox(height: 200)
              ]),
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
