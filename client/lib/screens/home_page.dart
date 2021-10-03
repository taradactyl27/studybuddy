import 'package:flutter/material.dart';
import 'package:studybuddy/route/route.dart' as route;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("YOU HAVE SIGNED IN"),
        ],
      )
    );
  }
}