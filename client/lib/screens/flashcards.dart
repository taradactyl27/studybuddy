import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/services/course_state.dart';
import 'package:studybuddy/widgets/flashcardcreation.dart';
import 'package:studybuddy/widgets/side_menu.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:studybuddy/routes/hero_route.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/services/database.dart' as database;




class FlashcardPage extends StatefulWidget {
  FlashcardPage({Key? key, required this.cardsetId}) : super(key: key);
  final String cardsetId;
  

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
                    onTap: () {
                        Navigator.of(context)
                      .push(HeroDialogRoute(builder: (context) {
                    return FlashCardCreationForm(cardsetId: widget.cardsetId,);
                  }));}),
                SpeedDialChild(
                    backgroundColor: Colors.redAccent,
                    labelBackgroundColor: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.black),
                    label: 'Delete Card Set',
                    onTap: () async {await database.deleteFlashcardset(
                                        Provider.of<CourseState>(context, listen: false)
                                    .currentCourseId, widget.cardsetId);
                                        
                                    Navigator.pop(context);})
              ],
            ),
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView(
                padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
                children: [
                  const SizedBox(height: 15),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Flashcards",
                            style: GoogleFonts.nunito(
                                textStyle: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w400,
                            ))),
                        const SizedBox(
                          height: 200,
                        )
                      ]),
                ],
              ),
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
