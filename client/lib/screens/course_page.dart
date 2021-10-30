import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/services/database.dart' as database;
import 'package:studybuddy/widgets/transcript_tile.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({
    Key? key,
    required this.course,
  }) : super(key: key);
  final QueryDocumentSnapshot<Object?> course;

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Hero(
                transitionOnUserGestures: true,
                tag: {widget.course.id},
                child: ClipPath(
                  clipper: WaveClipperTwo(),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF61A3FE), Color(0xFF63FFD5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                            bottom: 50,
                            left: 50,
                            child: Text(widget.course.get('name') ?? "error",
                                style: GoogleFonts.nunito(
                                    textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600)))),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(top: 80, left: 30),
                          child: Text("Your Transcripts",
                              style: GoogleFonts.nunito(
                                  textStyle: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w400,
                              )))),
                      StreamBuilder(
                          stream: database.getCourseTranscriptions(
                              widget.course.get('course_id')),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                  height: 200,
                                  child: Center(child: Text('Loading')));
                            }
                            return SizedBox(
                                height: 400,
                                width: MediaQuery.of(context).size.width,
                                child: GridView.count(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  crossAxisSpacing: 20,
                                  crossAxisCount: 2,
                                  padding: const EdgeInsets.all(10.0),
                                  children:
                                      snapshot.data!.docs.map((transcript) {
                                    return TranscriptTile(
                                      transcript: transcript,
                                      courseId: widget.course.get('course_id'),
                                    );
                                  }).toList(),
                                ));
                          })
                    ],
                  )),
              Positioned(
                  width: MediaQuery.of(context).size.width,
                  bottom: 10,
                  left: 0,
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      onPressed: () async {
                        await database.deleteCourse(widget.course.id);
                        Navigator.pop(context);
                      },
                      child: const Text("Delete Course"),
                    ),
                  )),
            ],
          ),
        ));
  }
}
