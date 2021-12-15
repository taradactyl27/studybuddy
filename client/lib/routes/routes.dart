import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/course.dart';
import 'package:studybuddy/screens/login.dart';
import 'package:studybuddy/screens/register.dart';
import 'package:studybuddy/screens/settings.dart';
import 'package:studybuddy/screens/transcript.dart';
import 'package:studybuddy/screens/layout.dart';

import '../services/auth.dart';

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
        case loginPage:
        case registerPage:
        case homePage:
        case rootUrl:
          return const Layout();
        case settingsPage:
          return const SettingsPage();
        case coursePage:
          return const CoursePage();
        case transcriptPage:
          final arguments = settings.arguments as Map<String, dynamic>;
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
    default:
      return MaterialPageRoute(
        settings: settings,
        builder: build,
      );
  }
}
