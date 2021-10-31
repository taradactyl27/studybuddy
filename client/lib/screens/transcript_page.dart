import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class TranscriptPage extends StatefulWidget {
  TranscriptPage(
      {Key? key,
      required this.transcript,
      required this.courseId,
      this.tabID = 0})
      : super(key: key);

  final DocumentSnapshot<Object?> transcript;
  final String courseId;
  int tabID;
  @override
  _TranscriptPageState createState() => _TranscriptPageState();
}

class _TranscriptPageState extends State<TranscriptPage> {
  late QuillController _textController;
  late QuillController _notesController;
  late List<QuillController> _controllers;
  int tabID = 0;

  @override
  void initState() {
    super.initState();

    tabID = widget.tabID;

    List<dynamic> initTextData = [
      {'insert': widget.transcript['text'] + '\n'}
    ];

    List<dynamic> initNotesData = [
      {'insert': widget.transcript['studyNotes'] + '\n'}
    ];

    _controllers = List.of(<QuillController>[
      QuillController(
          document: Document.fromJson(initTextData),
          selection: const TextSelection.collapsed(offset: 0)),
      QuillController(
          document: Document.fromJson(initNotesData),
          selection: const TextSelection.collapsed(offset: 0))
    ]);
  }

  @override
  void dispose() {
    _textController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: Text(
            widget.transcript['audioRef'].split('/')[1],
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(primary: Colors.deepOrange),
              onPressed: () {
                setState(() {
                  tabID = 0;
                });
              },
              child: const Text("Original"),
            ),
            TextButton(
              style: TextButton.styleFrom(primary: Colors.deepPurple),
              onPressed: () {
                setState(() {
                  tabID = 1;
                });
              },
              child: const Text("Our Notes"),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                QuillToolbar.basic(
                  controller: _controllers[tabID],
                  toolbarIconSize: 22,
                  showImageButton: false,
                  showVideoButton: false,
                  showCameraButton: false,
                  multiRowsDisplay: false,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      bottom: 10.0,
                      top: 5.0,
                      left: 15.0,
                      right: 15.0,
                    ),
                    child: QuillEditor.basic(
                      controller: _controllers[tabID],
                      readOnly: false, // true for view only mode
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.check, color: Colors.white),
        ));
  }
}
