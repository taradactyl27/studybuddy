import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/course.dart';
import 'package:studybuddy/screens/favorites.dart';
import 'package:studybuddy/screens/flashcards.dart';
import 'package:studybuddy/screens/login.dart';
import 'package:studybuddy/screens/register.dart';
import 'package:studybuddy/screens/recording.dart';
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
const String recordingPage = '/recording';
const String flashcardPage = '/flashcard';

Route<dynamic> controller(RouteSettings settings) {
  // routing logic
  Widget build(BuildContext context) {
    User? user = context.watch<User?>();
    if (user != null) {
      switch (settings.name) {
        case rootUrl:
        case loginPage:
        case registerPage:
        case homePage:
          return const Layout();
        case settingsPage:
          return const SettingsPage();
        case coursePage:
          return const CoursePage();
        case favoritesPage:
          return const Favorites();
        case flashcardPage:
          final arguments = settings.arguments as Map<String, dynamic>;
          return FlashcardPage(
            cardsetId: arguments["cardsetId"],
          );
        case transcriptPage:
          final arguments = settings.arguments as Map<String, dynamic>;
          return TranscriptPage(
            transcript: arguments["transcript"],
            courseId: arguments["course_id"],
          );
        case recordingPage:
          return const RecordingPage();
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
