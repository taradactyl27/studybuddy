import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/services/course_state.dart';

import '../services/course_state.dart';
import '../services/notifications.dart';
import 'routes/routes.dart';
import "route_observer.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
  await configureLocalTimeZone();

  if (dotenv.get('EMULATE_FUNCTIONS', fallback: '') == 'y') {
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }

  if (dotenv.get('EMULATE_FIRESTORE', fallback: '') == 'y') {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>(
          initialData: null,
          create: (_) => FirebaseAuth.instance.userChanges(),
          updateShouldNotify: (oldUser, newUser) {
            return oldUser != newUser;
          },
        ),
        ChangeNotifierProvider(create: (_) => CourseState()),
      ],
      child: MaterialApp(
        title: 'Study Buddy',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark)),
          brightness: Brightness.light,
          colorScheme: const ColorScheme.light(),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light)),
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          applyElevationOverlayColor: true,
        ),
        themeMode: ThemeMode.system,
        navigatorKey: navigatorKey,
        onGenerateRoute: controller,
        initialRoute: rootUrl,
      ),
    );
  }
}
