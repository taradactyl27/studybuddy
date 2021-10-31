import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes/routes.dart';
import '../screens/home_page.dart';
import '../screens/loading_page.dart';
import '../screens/login_page.dart';
import '../services/auth.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // void redirectToAuth(BuildContext context, String routeName) {
  //   // Navigator.of(context).pushReplacementNamed(routeName);
  //   WidgetsBinding.instance!.addPostFrameCallback((_) async {
  //     Navigator.of(context).pushReplacementNamed(routeName);
  //   });
  // }

  // void redirectToUnAuth(BuildContext context, String routeName) {
  //   // Navigator.of(context)
  //   //       .pushNamedAndRemoveUntil(loginPage, (route) => false);

  //   WidgetsBinding.instance!.addPostFrameCallback((_) async {
  //     Navigator.of(context)
  //         .pushNamedAndRemoveUntil(routeName, (route) => false);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<User?>();
    return Scaffold(
      body: Center(
        child: user == null ? const HomePage() : const LoginPage(),
      ),
    );
  }
}
