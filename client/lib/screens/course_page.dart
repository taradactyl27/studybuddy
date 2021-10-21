import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key? key, required this.courseId}) : super(key: key);
  final String? courseId;

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: Stack(
          children: [
            Hero(
              transitionOnUserGestures: true,
              tag: {widget.courseId},
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
                  child: Text(widget.courseId ?? "error"),
                ),
              ),
            ),
          ],
        ));
  }
}
