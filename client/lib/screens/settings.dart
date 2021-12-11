import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:studybuddy/services/auth.dart' show User, signOut;
import 'package:studybuddy/widgets/side_menu.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<User?>();
    final username = user!.displayName != null && user.displayName!.isNotEmpty
        ? user.displayName!
        : user.email!;
    return Scaffold(
        key: _scaffoldKey,
        drawer: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: const SideMenu(),
        ),
        bottomNavigationBar: kIsWeb
            ? null
            : BottomAppBar(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                    ),
                  ])),
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
