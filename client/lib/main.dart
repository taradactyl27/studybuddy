import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../services/course_state.dart';
import '../services/recents_state.dart';
import 'routes/routes.dart';
import "route_observer.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();

  if (dotenv.get('EMULATE_FUNCTIONS', fallback: '') == 'y') {
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }

  if (dotenv.get('EMULATE_FIRESTORE', fallback: '') == 'y') {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

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
        ChangeNotifierProxyProvider<User, RecentsState>(
          create: (_) => RecentsState(),
          update: (_, user, recentsState) => recentsState!..update(user.uid),
        )
      ],
      child: MaterialApp(
        title: 'Study Buddy',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        onGenerateRoute: controller,
        initialRoute: rootUrl,
      ),
    );
  }
}
