import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/list_extensions.dart';
import 'package:flash_card/flash_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/color_constants.dart';
import 'package:studybuddy/services/course_state.dart';
import 'package:studybuddy/widgets/flashcardcreation.dart';
import 'package:studybuddy/widgets/side_menu.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:studybuddy/routes/hero_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/services/database.dart' as database;

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({Key? key, required this.cardsetId}) : super(key: key);
  final String cardsetId;

  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _controller;
  FocusNode? focusNode;
  bool _editing = false;
  int index = 0;

  void resetIndex() {
    setState(() {
      index = 0;
    });
  }

  void incrementIndex(int maxLen) {
    setState(() {
      index += 1;
      if (index > maxLen - 1) {
        index = 0;
      }
    });
  }

  void decrementIndex(int maxLen) {
    setState(() {
      index -= 1;
      if (index < 0) {
        index = maxLen - 1;
      }
    });
  }

  @override
  void initState() {
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: database.getFlashcard(
            Provider.of<CourseState>(context, listen: false).currentCourseId,
            widget.cardsetId),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          _controller = TextEditingController(
              text: snapshot.data!.exists ? snapshot.data!.get('name') : "");
          List<Widget> cards = snapshot.data!.exists
              ? List<dynamic>.from(snapshot.data!.get('cards'))
                  .mapIndexed<Widget>((index, card) {
                  return FlashCard(
                      key: Key(index.toString()),
                      width: 300,
                      height: 300,
                      frontWidget:
                          Center(child: Text(card["answer"] ?? 'empty')),
                      backWidget: Stack(
                        children: [
                          Positioned(
                              top: 0,
                              right: 0,
                              child: InkWell(
                                  onTap: () async {
                                    int oldIndex = index;
                                    resetIndex();
                                    await database.deleteFlashcard(
                                        Provider.of<CourseState>(context,
                                                listen: false)
                                            .currentCourseId,
                                        widget.cardsetId,
                                        snapshot.data!.get("cards")[oldIndex]);
                                    print(index);
                                  },
                                  child: const Icon(Icons.delete_outline,
                                      color: kDangerColor))),
                          Center(child: Text(card["question"] ?? 'empty')),
                        ],
                      ));
                }).toList()
              : [];
          return Scaffold(
            key: _scaffoldKey,
            drawer: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: const SideMenu(),
            ),
            resizeToAvoidBottomInset: false,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            floatingActionButton: kIsWeb
                ? null
                : SpeedDial(
                    iconTheme:
                        const IconThemeData(color: kLightModeIconSecondary),
                    icon: Icons.menu_open,
                    activeIcon: Icons.close,
                    spacing: 10,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.25,
                    children: [
                      SpeedDialChild(
                          child: const Icon(Icons.mic_rounded),
                          label: 'Add a Card',
                          onTap: () {
                            Navigator.of(context)
                                .push(HeroDialogRoute(builder: (context) {
                              return FlashCardCreationForm(
                                cardsetId: widget.cardsetId,
                              );
                            }));
                          }),
                      SpeedDialChild(
                          backgroundColor: kDangerColor,
                          labelBackgroundColor: kDangerColor,
                          child: const Icon(Icons.delete),
                          label: 'Delete Card Set',
                          onTap: () async {
                            await database.deleteFlashcardset(
                                Provider.of<CourseState>(context, listen: false)
                                    .currentCourseId,
                                widget.cardsetId);

                            Navigator.pop(context);
                          })
                    ],
                  ),
            appBar: AppBar(
              title: Row(
                children: [
                  SizedBox(
                    height: 67,
                    width: 120,
                    child: TextField(
                      focusNode: focusNode,
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 28),
                      controller: _controller,
                      onSubmitted: (edit) async {
                        await database.updateCardSetName(
                            Provider.of<CourseState>(context, listen: false)
                                .currentCourseId,
                            widget.cardsetId,
                            edit);
                        setState(() {
                          _editing = false;
                          focusNode!.unfocus();
                        });
                      },
                      decoration: InputDecoration(
                        border: _editing ? null : InputBorder.none,
                      ),
                      readOnly: !_editing,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _editing
                      ? InkWell(
                          onTap: () async {
                            await database.updateCardSetName(
                                Provider.of<CourseState>(context, listen: false)
                                    .currentCourseId,
                                widget.cardsetId,
                                _controller.text);
                            setState(() {
                              focusNode!.unfocus();
                              _editing = false;
                            });
                          },
                          child: const Icon(Icons.check,
                              size: 22, color: Colors.white))
                      : InkWell(
                          onTap: () {
                            setState(() {
                              _editing = true;
                              focusNode!.requestFocus();
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 4.0),
                            child:
                                Icon(Icons.edit, size: 22, color: Colors.white),
                          )),
                ],
              ),
              leading: IconButton(
                  onPressed: () {
                    if (kIsWeb) {
                      Provider.of<CourseState>(context, listen: false)
                          .removeCourseStream();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_sharp,
                      color: Colors.white)),
            ),
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView(
                padding: const EdgeInsets.only(
                    top: 10, left: 15, right: 15, bottom: 10),
                children: [
                  const SizedBox(height: 55),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Flashcards",
                            style: GoogleFonts.nunito(
                                textStyle: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w400,
                            ))),
                        cards.isEmpty
                            ? Column(children: [
                                const SizedBox(height: 60),
                                Container(
                                  padding: const EdgeInsets.only(
                                    top: 15,
                                    right: 15,
                                    left: 15,
                                    bottom: 15,
                                  ),
                                  height: 150,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.fitHeight,
                                        image: AssetImage(
                                            "theme/questions_empty.png")),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: SizedBox(
                                    width: 200,
                                    child: Text(
                                      "You haven't created any cards yet. Click the + button on the bottom right to begin!",
                                      style: GoogleFonts.nunito(
                                          fontStyle: FontStyle.italic),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              ])
                            : GestureDetector(
                                onHorizontalDragEnd: (dragEndDetails) {
                                  if (dragEndDetails.primaryVelocity! < 0) {
                                    incrementIndex(cards.length);
                                  } else if (dragEndDetails.primaryVelocity! >
                                      0) {
                                    decrementIndex(cards.length);
                                  }
                                },
                                child: SizedBox(
                                    height: 350,
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(child: cards[index])),
                              ),
                        if (cards.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      index -= 1;
                                      if (index < 0) {
                                        index = cards.length - 1;
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.chevron_left),
                                  label: Text('Prev',
                                      style: GoogleFonts.nunito())),
                              Text('${index + 1} / ${cards.length}',
                                  style: GoogleFonts.nunito()),
                              OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      index += 1;
                                      if (index > cards.length - 1) {
                                        index = 0;
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.chevron_right),
                                  label: Text('Next',
                                      style: GoogleFonts.nunito())),
                            ],
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
        });
  }
}
