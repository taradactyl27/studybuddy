import 'package:flutter/material.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/screens/home_page.dart';

const String loginPage = 'login';
const String landingPage = 'landing';

Route<dynamic> controller(RouteSettings settings){
  switch (settings.name){
    case loginPage:
      return MaterialPageRoute(builder: (context) => LoginPage());
    case landingPage:
      return MaterialPageRoute(builder: (context) => HomePage());
    default:
      throw('HOWD YOU GET HERE');
  }

}