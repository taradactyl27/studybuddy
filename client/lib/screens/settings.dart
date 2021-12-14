import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/color_constants.dart';
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
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
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20.0, bottom: 20.0, top: 80.0),
            children: [
              Text("Account",
                  style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w400))),
              const SizedBox(height: 20),
              Material(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(children: [
                    user.photoURL == null || user.photoURL!.isEmpty
                        ? const Icon(Icons.account_circle_rounded, size: 48)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              user.photoURL.toString(),
                              height: 48,
                            )),
                    const SizedBox(width: 20),
                    Text(username,
                        style: GoogleFonts.nunito(
                            textStyle: const TextStyle(fontSize: 16))),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              Text("Personalize",
                  style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w400))),
              const SizedBox(height: 100),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: kPrimaryColor, minimumSize: const Size(230, 44)),
                onPressed: () async {
                  await signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      routes.loginPage, (route) => false);
                },
                child: Text('Sign Out',
                    style:
                        GoogleFonts.nunito(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ));
  }
}
