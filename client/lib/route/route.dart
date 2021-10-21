import 'package:flutter/material.dart';
import 'package:studybuddy/screens/course_page.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/screens/home_page.dart';
import 'package:studybuddy/screens/settings_page.dart';
import 'package:studybuddy/screens/register_page.dart';

const String loginPage = 'login';
const String landingPage = 'landing';
const String settingsPage = 'settings';
const String registerPage = 'register';
const String coursePage = 'coursePage';

Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    case settingsPage:
      return MaterialPageRoute(builder: (context) => SettingsPage());
    case loginPage:
      return MaterialPageRoute(builder: (context) => LoginPage());
    case landingPage:
      return MaterialPageRoute(builder: (context) => HomePage());
    case registerPage:
      return MaterialPageRoute(builder: (context) => RegisterPage());
    case coursePage:
      final arguments = settings.arguments as Map;
      return MaterialPageRoute(
          builder: (context) => CoursePage(courseId: arguments["course_id"]));
    default:
      throw ('HOWD YOU GET HERE');
  }
}
