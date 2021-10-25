import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/route/hero_route.dart';
import 'package:studybuddy/route/route.dart' as route;
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/screens/class_creation_card.dart';
import 'package:studybuddy/services/database.dart';
import 'package:studybuddy/widgets/bottom_bar_painter.dart';
import 'package:studybuddy/widgets/course_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late Future<List<dynamic>> _courseIds;
  bool toggle = false;
  final TextEditingController _searchController = TextEditingController();
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
    _courseIds = Database.getUserCourseList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshCourses() {
    setState(() {
      _courseIds = Database.getUserCourseList();
    });
  }

  Alignment alignment1 = const Alignment(0.0, -1.3);
  Alignment alignment2 = const Alignment(0.0, -1.3);
  double size1 = 50;
  double size2 = 50;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
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
                child: CupertinoTextField(
                    controller: _searchController, placeholder: "Search...")),
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
                            stream: Database.getCourseStream(snapshot.data),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox(
                                    height: 200,
                                    child: Center(child: Text('Loading')));
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
                                                context, route.coursePage,
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
                          height: 200, child: Center(child: Text('Loading')));
                    }
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: size.width,
                height: 80,
                child: Stack(
                  overflow: Overflow.visible,
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
                          child: GestureDetector(
                            onTap: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles();
                              if (result != null) {
                                Database.uploadFile(result.files.single.path,
                                    result.files.first.name);
                              } else {
                                // User canceled the picker
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 275),
                              curve: toggle ? Curves.easeIn : Curves.easeOut,
                              height: size1,
                              width: size1,
                              decoration: BoxDecoration(
                                color: const Color(0xFF63FFD5),
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              child: const Icon(Icons.mic_rounded,
                                  color: Colors.white),
                            ),
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
                                curve: toggle ? Curves.easeIn : Curves.easeOut,
                                height: size2,
                                width: size2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF63FFD5),
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                child: const Icon(Icons.my_library_add_rounded,
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
                                    alignment1 = const Alignment(-0.35, -3.5);
                                  });
                                  Future.delayed(
                                      const Duration(milliseconds: 10), () {
                                    alignment2 = const Alignment(0.35, -3.5);
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
                    Container(
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
                                Icons.notifications,
                                color: currentIndex == 3
                                    ? const Color(0xFF61A3FE)
                                    : Colors.grey.shade400,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, route.settingsPage);
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
    );
  }
}
