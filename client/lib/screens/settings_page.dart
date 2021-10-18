import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/route/hero_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:studybuddy/route/route.dart' as route;
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/widgets/bottom_bar_painter.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int currentIndex = 3;
  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false);
            },
            child: const Text('Sign Out'),
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            child: Container(
                width: size.width,
                height: 80,
                child: Stack(overflow: Overflow.visible, children: [
                  CustomPaint(
                    size: Size(size.width, 80),
                    painter: BNBCustomPainter(),
                  ),
                  Container(
                    width: size.width,
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.home,
                            color: currentIndex == 0
                                ? const Color(0xFF61A3FE)
                                : Colors.grey.shade400,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          splashColor: Colors.white,
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.menu_book_rounded,
                              color: currentIndex == 1
                                  ? const Color(0xFF61A3FE)
                                  : Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setBottomBarIndex(1);
                            }),
                        Container(
                          width: size.width * 0.20,
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              color: currentIndex == 2
                                  ? const Color(0xFF61A3FE)
                                  : Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setBottomBarIndex(2);
                            }),
                        IconButton(
                            icon: Icon(
                              Icons.notifications,
                              color: currentIndex == 3
                                  ? const Color(0xFF61A3FE)
                                  : Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setBottomBarIndex(3);
                            }),
                      ],
                    ),
                  )
                ])))
      ],
    ));
  }
}
