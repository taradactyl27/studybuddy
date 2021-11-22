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
    return Hero(
      transitionOnUserGestures: true,
      tag: {course.id},
      child: ClipPath(
        clipper: SideCutClipper(),
        child: Container(
          height: 80,
          width: 80,
          margin: const EdgeInsets.only(bottom: 32),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF61A3FE), Color(0xFF63FFD5)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: [const Color(0xFF61A3FE), const Color(0xFF63FFD5)]
                    .last
                    .withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(4, 4),
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(course['name'],
                    style: GoogleFonts.nunito(
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 21),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
