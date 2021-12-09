import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:studybuddy/services/database.dart' show getCourseStream;

class CourseState extends ChangeNotifier {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? courseStream;
  String currentCourseId = "";

  void changeCourseStream(String course_id) {
    if (course_id != currentCourseId) {
      print("COURSE CHANGED:" + course_id);
      courseStream = getCourseStream(course_id);
      currentCourseId = course_id;
      notifyListeners();
    }
  }

  void resetCourseStream(String course_id) {
    print("Stream Reset:" + course_id);
    courseStream = getCourseStream(course_id);
    currentCourseId = course_id;
    notifyListeners();
  }
}
