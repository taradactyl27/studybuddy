import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/course_page.dart';
import 'package:studybuddy/screens/home_page.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/screens/register_page.dart';
import 'package:studybuddy/screens/settings_page.dart';
import 'package:studybuddy/screens/transcript_page.dart';

import '../services/auth.dart';
import 'dashboard_route.dart';

const String rootUrl = '/';
const String loginPage = '/login';
const String registerPage = '/register';
const String homePage = '/home';
const String coursePage = '/courses';
const String settingsPage = '/settings';
const String transcriptPage = '/transcript';

Route<dynamic> controller(RouteSettings settings) {
  // routing logic
  StatefulWidget build(BuildContext context) {
    User? user = context.watch<User?>();
    if (user != null) {
      switch (settings.name) {
        case rootUrl:
        case loginPage:
        case registerPage:
        case homePage:
          return const HomePage();
        case settingsPage:
          return const SettingsPage();
        case coursePage:
          final arguments = settings.arguments as Map;
          return CoursePage(course: arguments["course"]);
        case transcriptPage:
          final arguments = settings.arguments as Map;
          return TranscriptPage(
            transcript: arguments["transcript"],
            courseId: arguments["course_id"],
          );
        default:
          return const Scaffold(
            body: Center(
              child: Text("404 Goofy ???"),
            ),
          );
      }
    } else {
      switch (settings.name) {
        case registerPage:
          return const RegisterPage();
        default:
          return const LoginPage();
      }
    }
  }

  // route wrappers
  switch (settings.name) {
    case settingsPage:
      return DashboardPageRoute(
        builder: build,
      );
    default:
      return MaterialPageRoute(
        settings: settings,
        builder: build,
      );
  }
}
