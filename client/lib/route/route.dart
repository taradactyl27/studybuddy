import 'package:flutter/material.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/screens/home_page.dart';
import 'package:studybuddy/screens/settings_page.dart';

const String loginPage = 'login';
const String landingPage = 'landing';
const String settingsPage = 'settings';

Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    case settingsPage:
      return MaterialPageRoute(builder: (context) => SettingsPage());
    case loginPage:
      return MaterialPageRoute(builder: (context) => LoginPage());
    case landingPage:
      return MaterialPageRoute(builder: (context) => HomePage());
    default:
      throw ('HOWD YOU GET HERE');
  }
}
