import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/services/database.dart' as database;
import 'package:flutter/material.dart';
import 'package:studybuddy/routes/routes.dart' as routes;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

List<int> intervals = [5, 10, 60, 300, 600, 1800];
int index = 0;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

final IOSInitializationSettings initializationSettingsIOS =
    const IOSInitializationSettings();

final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');

const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

Future<void> configureLocalTimeZone() async {
  if (kIsWeb) {
    return;
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

// payload = transcriptID + courseID
void selectNotification(String? payload) async {
  if (payload == null) {
    print('no payload');
  }

  String courseID = payload!.split('/')[0];
  String transcriptID = payload.split('/')[1];
  index += 1;
  final transcript = await database.getTranscription(transcriptID, courseID);
  navigatorKey.currentState!.pushNamed(routes.transcriptPage,
      arguments: {'transcript': transcript, 'course_id': courseID});
  print("end notif");
  send(courseID);
}

void enableNotification(bool enabled, String courseID) async {
  if (enabled) {
    await send(courseID);
  } else {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('canceled');
  }
}

Future<void> send(String courseID) async {
  final transcript = await database.getRandomTranscription(courseID);
  String transcriptID = transcript.docs.first.id;
  print(transcriptID);
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Time to study!',
      'ur buddies @ studybuddy',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: intervals[index])),
      platformChannelSpecifics,
      payload: '$courseID/$transcriptID',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
  print(intervals[index]);
}
