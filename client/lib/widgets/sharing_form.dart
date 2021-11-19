import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/services/database.dart' as database;
import 'package:studybuddy/widgets/user_tile.dart';
import 'package:studybuddy/routes/routes.dart' as routes;

class SharingForm extends StatefulWidget {
  /// {@macro add_todo_popup_card}
  const SharingForm({
    Key? key,
    required this.course,
    required this.isOwner,
  }) : super(key: key);
  final QueryDocumentSnapshot<Object?> course;
  final bool isOwner;

  @override
  State<SharingForm> createState() => _SharingFormState();
}

var currentUser = FirebaseAuth.instance.currentUser;

class _SharingFormState extends State<SharingForm> {
  final TextEditingController _namecontroller = TextEditingController();
  late Future<dynamic> courseUserPermissions;

  @override
  void initState() {
    super.initState();
    print("getting course perms");
    courseUserPermissions = database.getCoursePermList(widget.course.id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<User>().uid;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: 'add',
          child: Material(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
                side: const BorderSide(width: 3, color: Colors.black45),
                borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Users with access to course"),
                    const Divider(
                      height: 10,
                      indent: 1,
                      endIndent: 0,
                      color: Colors.black45,
                      thickness: 0.5,
                    ),
                    FutureBuilder<dynamic>(
                        future: courseUserPermissions,
                        builder: (context, AsyncSnapshot<dynamic> snapshot) {
                          print(snapshot);
                          if (!snapshot.hasData) {
                            return const SizedBox(
                                height: 50,
                                child:
                                    Center(child: CircularProgressIndicator()));
                          } else {
                            return SizedBox(
                                height: 150,
                                child: ListView(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(
                                        bottom: 5, left: 0, right: 0, top: 0),
                                    children:
                                        snapshot.data.keys.map<Widget>((user) {
                                      print(user);
                                      return UserTile(
                                          email: snapshot.data[user]['email'],
                                          permStatus: snapshot.data[user]
                                                  ['role'] ??
                                              "");
                                    }).toList()));
                          }
                        }),
                    if (widget.isOwner)
                      TextFormField(
                        controller: _namecontroller,
                        decoration: const InputDecoration(
                          hintText: 'New User Email',
                          border: InputBorder.none,
                        ),
                        cursorColor: Colors.white,
                      ),
                    widget.isOwner
                        ? ElevatedButton(
                            onPressed: () async {
                              String userEmail = _namecontroller.text;
                              await database.addUserToCourse(
                                  widget.course.id, userEmail);
                              setState(() {
                                courseUserPermissions = database
                                    .getCoursePermList(widget.course.id);
                              });
                            },
                            child: const Text("Add a User"),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              await database.removeUserFromCourse(
                                  widget.course.id, uid);
                              Navigator.of(context).popUntil(
                                  ModalRoute.withName(routes.homePage));
                            },
                            style:
                                ElevatedButton.styleFrom(primary: Colors.red),
                            child: const Text("Leave Course"),
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
