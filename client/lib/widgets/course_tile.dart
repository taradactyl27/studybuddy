import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseTile extends StatelessWidget {
  const CourseTile({
    Key? key,
    required this.course,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> course;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      child: SizedBox(
        height: 200,
        width: 200,
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: const BoxDecoration(
                  gradient:
                      LinearGradient(colors: [Colors.blue, Colors.blueGrey])),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
