import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/services/auth.dart' show User, signOut;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
    User? user = context.watch<User?>();
    final username = user!.displayName != null && user.displayName!.isNotEmpty
        ? user.displayName!
        : user.email!;
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
            ],
          ),
        ),
      ],
    ));
  }
}
