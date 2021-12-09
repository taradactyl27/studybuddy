import 'package:flutter/material.dart';
import 'package:studybuddy/widgets/bottom_bar_painter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/services/auth.dart' show User, signOut;
import "../services/notifications.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int currentIndex = 3;
  int clicks = 0;

  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<User?>();
    final username = user!.displayName != null && user.displayName!.isNotEmpty
        ? user.displayName!
        : user.email!;
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(username),
              ElevatedButton(
                  onPressed: () async {
                    await signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        routes.loginPage, (route) => false);
                  },
                  child: const Text('Sign Out')),
              ElevatedButton(
                  onPressed: () async {
                    if (clicks == 0) {
                      await flutterLocalNotificationsPlugin.zonedSchedule(
                          0,
                          'scheduled: cyclone ride',
                          'i miss you',
                          tz.TZDateTime.now(tz.local)
                              .add(const Duration(seconds: 10)),
                          platformChannelSpecifics,
                          androidAllowWhileIdle: true,
                          uiLocalNotificationDateInterpretation:
                              UILocalNotificationDateInterpretation
                                  .absoluteTime);
                    } else {
                      clicks += 1;
                      await flutterLocalNotificationsPlugin.show(clicks, 'BONG',
                          'AYYYYYOOOO', platformChannelSpecifics,
                          payload: 'payload here');
                    }
                  },
                  child: const Text('bing'))
            ],
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            child: SizedBox(
                width: size.width,
                height: 80,
                child: Stack(clipBehavior: Clip.none, children: [
                  CustomPaint(
                    size: Size(size.width, 80),
                    painter: BNBCustomPainter(),
                  ),
                  SizedBox(
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
                              Icons.settings_rounded,
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
