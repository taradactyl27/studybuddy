import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';
import 'package:studybuddy/services/auth.dart' show User;
import 'package:studybuddy/services/database.dart';

class CourseTile extends StatelessWidget {
  const CourseTile({
    Key? key,
    required this.course,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> course;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<User>().uid;
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Material(
        elevation: 5,
        child: SizedBox(
          height: 200,
          width: 200,
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: const BoxDecoration(
                    gradient:
                        LinearGradient(colors: [Colors.blue, Colors.blueGrey])),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Text(course['name'],
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          )),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (course['roles'][uid]['favorite']) {
                        await removeCourseFromFavorite(course.id, uid);
                      } else {
                        await addCourseToFavorite(course.id, uid);
                      }
                    },
                    child: Container(
                        margin: const EdgeInsets.only(top: 7, right: 6),
                        child: course['roles'][uid]['favorite']
                            ? const Icon(Icons.star,
                                color: Colors.amber, size: 20)
                            : const Icon(Icons.star_border, size: 20)),
                  ),
                ],
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: Text(
                      "No description provided for course. Edit one in to personalize to your liking!",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                            color: Colors.black54, fontSize: 12),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
