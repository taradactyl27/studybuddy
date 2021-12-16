import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/color_constants.dart';
import 'package:studybuddy/services/course_state.dart';
import 'package:studybuddy/services/database.dart' as database;
import 'package:studybuddy/widgets/user_tile.dart';
import 'package:studybuddy/routes/routes.dart' as routes;

class SharingForm extends StatefulWidget {
  const SharingForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SharingForm> createState() => _SharingFormState();
}

class _SharingFormState extends State<SharingForm> {
  final TextEditingController _namecontroller = TextEditingController();
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<User>().uid;
    Stream<DocumentSnapshot<Map<String, dynamic>>>? currentCourse =
        Provider.of<CourseState>(context).courseStream;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Material(
            elevation: 20,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder(
                    stream: currentCourse,
                    builder: (context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                            height: 50,
                            child: Center(child: CircularProgressIndicator()));
                      }
                      Map<String, dynamic> roleList =
                          snapshot.data!.get('roles');
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Users with access to course",
                              style: GoogleFonts.nunito()),
                          const Divider(
                            height: 10,
                            indent: 1,
                            endIndent: 0,
                            thickness: 0.5,
                          ),
                          SizedBox(
                              height: 150,
                              child: ListView(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(
                                      bottom: 5, left: 0, right: 0, top: 0),
                                  children: snapshot.data!
                                      .get('roles')
                                      .keys
                                      .map<Widget>((user) {
                                    return UserTile(
                                      email: roleList[user]['email'],
                                      permStatus: roleList[user]['role'] ?? "",
                                      isOwner: roleList[uid]['role'] == "owner",
                                      uid: user,
                                      courseId:
                                          Provider.of<CourseState>(context)
                                              .currentCourseId,
                                    );
                                  }).toList())),
                          Divider(),
                          if (roleList[uid]['role'] == 'owner')
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, bottom: 8),
                              child: TextFormField(
                                controller: _namecontroller,
                                decoration: InputDecoration(
                                  hintStyle: GoogleFonts.nunito(),
                                  hintText: 'Type New User Email Here',
                                ),
                                cursorColor: kBgLightColor,
                              ),
                            ),
                          roleList[uid]['role'] == 'owner'
                              ? SizedBox(
                                  width: 150,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      String userEmail = _namecontroller.text;
                                      try {
                                        await database.addUserToCourse(
                                            Provider.of<CourseState>(context,
                                                    listen: false)
                                                .currentCourseId,
                                            userEmail);
                                      } catch (exception) {
                                        //HANDLE EXCEPTIONS IN SHARING
                                      }
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                                    child: isLoading
                                        ? const Center(
                                            child: SizedBox(
                                              height: 15,
                                              width: 15,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  color: kBgLightColor),
                                            ),
                                          )
                                        : Text("Add a User",
                                            style: GoogleFonts.nunito(
                                              textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: kLightTextColor),
                                            )),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    await database.removeUserFromCourse(
                                        Provider.of<CourseState>(context,
                                                listen: false)
                                            .currentCourseId,
                                        uid);
                                    Navigator.of(context).popUntil(
                                        ModalRoute.withName(routes.homePage));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: kDangerColor),
                                  child: Text("Leave Course",
                                      style: GoogleFonts.nunito(
                                        textStyle: const TextStyle(
                                            color: kDarkTextColor),
                                      )),
                                )
                        ],
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
