import 'package:flutter/material.dart';
import 'package:studybuddy/screens/course_page.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/screens/home_page.dart';
import 'package:studybuddy/screens/settings_page.dart';
import 'package:studybuddy/screens/register_page.dart';
import 'dashboard_route.dart';

const String loginPage = 'login';
const String landingPage = 'landing';
const String settingsPage = 'settings';
const String registerPage = 'register';
const String coursePage = 'coursePage';

Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    case settingsPage:
      return DashboardPageRoute(builder: (_) => SettingsPage());
    case loginPage:
      return MaterialPageRoute(builder: (_) => LoginPage());
    case landingPage:
      return MaterialPageRoute(builder: (_) => HomePage());
    case registerPage:
      return MaterialPageRoute(builder: (_) => RegisterPage());
    case coursePage:
      final arguments = settings.arguments as Map;
      return MaterialPageRoute(
          builder: (_) => CoursePage(course: arguments["course"]));
    default:
      throw ('HOWD YOU GET HERE');
  }
}
