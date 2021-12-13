import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/services/course_state.dart';

import '../services/auth.dart';
import 'routes/routes.dart';

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
        ChangeNotifierProvider(create: (_) => CourseState())
      ],
      child: MaterialApp(
        title: 'Study Buddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all<TextStyle>(
                  const TextStyle(fontSize: 18)),
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.all(13),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
          ),
        ),
        onGenerateRoute: controller,
        initialRoute: rootUrl,
      ),
    );
  }
}
