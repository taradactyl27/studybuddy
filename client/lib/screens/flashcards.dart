import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/services/course_state.dart';
import 'package:studybuddy/widgets/side_menu.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FlashcardPage extends StatefulWidget {
  FlashcardPage({Key? key}) : super(key: key);

  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: const SideMenu(),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: kIsWeb
          ? null
          : SpeedDial(
              iconTheme: const IconThemeData(color: Colors.white),
              icon: Icons.menu_open,
              activeIcon: Icons.close,
              spacing: 10,
              overlayColor: Colors.blueGrey,
              overlayOpacity: 0.6,
              children: [
                SpeedDialChild(
                    child: const Icon(Icons.mic_rounded, color: Colors.black),
                    label: 'Add a Card',
                    onTap: () {}),
                SpeedDialChild(
                    backgroundColor: Colors.redAccent,
                    labelBackgroundColor: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.black),
                    label: 'Delete Card Set',
                    onTap: () async {}),
              ],
            ),
      bottomNavigationBar: !kIsWeb
          ? BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8.0,
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
                  ]))
          : null,
    );
  }
}
