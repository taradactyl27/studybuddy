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
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Container(
          height: 100,
          width: 150,
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(course['name'],
                      style: GoogleFonts.nunito(
                        textStyle:
                            const TextStyle(color: Colors.black, fontSize: 18),
                      ))
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
