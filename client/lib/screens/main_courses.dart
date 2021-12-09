import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
import 'package:studybuddy/widgets/bottom_bar_painter.dart';
import 'package:studybuddy/widgets/course_tile.dart';
import 'package:studybuddy/widgets/search_result.dart';

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
  late Future<String> _searchApiKey;

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
              Container(
                  padding: const EdgeInsets.all(30),
                  height: 100,
                  child: FutureBuilder<String>(
                      future: _searchApiKey,
                      builder: (context, snapshot) {
                        return TextField(
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
                        );
                      })),
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
                  StreamBuilder(
                      stream: database.getUserCourseStream(uid),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                              height: 200,
                              child:
                                  Center(child: CircularProgressIndicator()));
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
              if (isSearching)
                SearchResultBox(isLoading: isLoading, results: searchResults),
              Positioned(
                bottom: 0,
                left: 0,
                child: SizedBox(
                  width: size.width,
                  height: 80,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (!kIsWeb)
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
                            child: StreamBuilder(
                                stream: database.getUserCourseStream(uid),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                  if (!snapshot.hasData) {
                                    return GestureDetector(
                                      onTap: () {
                                        print("loading course data");
                                      },
                                      child: audioButtonContainer,
                                    );
                                  }
                                  if (snapshot.data != null) {
                                    return GestureDetector(
                                      onTap: () async {
                                        print("opening audio form");
                                        await Navigator.of(context).push(
                                            HeroDialogRoute(builder: (context) {
                                          return AudioForm(
                                            courseList: snapshot.data!.docs,
                                          );
                                        }));
                                      },
                                      child: audioButtonContainer,
                                    );
                                  } else {
                                    return GestureDetector(
                                      onTap: () {
                                        print("must create a course first");
                                      },
                                      child: audioButtonContainer,
                                    );
                                  }
                                })),
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
                                  }));
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
                      if (!kIsWeb)
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
