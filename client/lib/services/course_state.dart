import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:studybuddy/services/database.dart' show getCourseStream;

class CourseState extends ChangeNotifier {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? courseStream;
  String currentCourseName = "";
  String currentCourseId = "";

  void changeCourseStream(String courseId) {
    if (courseId != currentCourseId) {
      print("COURSE CHANGED:" + courseId);
      courseStream = getCourseStream(courseId);
      currentCourseId = courseId;
      notifyListeners();
    }
  }

  void resetCourseStream(String courseId) {
    print("Stream Reset:" + courseId);
    courseStream = getCourseStream(courseId);
    currentCourseId = courseId;
    notifyListeners();
  }
}
