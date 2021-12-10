import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseTile extends StatelessWidget {
  const CourseTile({
    Key? key,
    required this.course,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> course;

  @override
  Widget build(BuildContext context) {
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
                  Container(
                      margin: const EdgeInsets.only(top: 7, right: 6),
                      child: const Icon(Icons.star_border, size: 20)),
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
