import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/course_page.dart';
import 'package:studybuddy/screens/home_page.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/screens/register_page.dart';
import 'package:studybuddy/screens/settings_page.dart';

import '../services/auth.dart';

const String rootUrl = '/';
const String loginPage = '/login';
const String registerPage = '/register';
const String homePage = '/home';
const String coursePage = '/courses';
const String settingsPage = '/settings';

Route<dynamic> controller(RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (context) {
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
    },
  );
}
