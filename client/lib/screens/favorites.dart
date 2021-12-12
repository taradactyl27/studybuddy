import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/services/database.dart' as database;
import 'package:studybuddy/services/auth.dart' show User, signOut;
import 'package:studybuddy/services/course_state.dart';
import 'package:studybuddy/widgets/course_tile.dart';
import 'package:studybuddy/widgets/side_menu.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final uid = context.read<User>().uid;
    return Scaffold(
        key: _scaffoldKey,
        drawer: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: const SideMenu(),
        ),
        bottomNavigationBar: kIsWeb
            ? null
            : BottomAppBar(
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
        body: ListView(
          padding: const EdgeInsets.only(top: 95, left: 15, right: 15),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Favorited Courses",
                    style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w400,
                    ))),
                StreamBuilder(
                    stream: database.getUserFavoritesStream(uid),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                            height: 500,
                            child: Center(child: CircularProgressIndicator()));
                      }
                      return SizedBox(
                        height: 500,
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
                                Provider.of<CourseState>(context, listen: false)
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
        ));
  }
}
