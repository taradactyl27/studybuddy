import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:http/http.dart' as http;
import 'package:studybuddy/services/database.dart' as database;

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
  late DocumentSnapshot<Object?> transcriptMut;
  late bool isLoading;
  int tabID = 0;

  @override
  void initState() {
    super.initState();

    tabID = widget.tabID;

    isLoading = false;

    transcriptMut = widget.transcript;

    List<dynamic> initTextData = [
      {'insert': transcriptMut['text'] + '\n'}
    ];
    List<dynamic> initNotesData;
    if (transcriptMut['notesGenerated']) {
      initNotesData = [
        {'insert': transcriptMut['studyNotes'] + '\n'}
      ];
    } else {
      initNotesData = [
        {'insert': '\n'}
      ];
    }

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
            transcriptMut['audioRef'].split('/')[1],
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
            transcriptMut['notesGenerated']
                ? TextButton(
                    style: TextButton.styleFrom(primary: Colors.deepPurple),
                    onPressed: () {
                      setState(() {
                        tabID = 1;
                      });
                    },
                    child: const Text("Our Notes"),
                  )
                : TextButton(
                    style: TextButton.styleFrom(primary: Colors.deepPurple),
                    onPressed: () {
                      setState(() async {
                        setState(() {
                          isLoading = true;
                        });
                        String? apiKey = dotenv.env['OPEN_AI_KEY'];
                        Map reqData = {
                          "prompt": transcriptMut['text'] +
                              ". To summarize in depth: 1.",
                          "max_tokens": 100,
                          "temperature": 0.7,
                          "stop": ["5."],
                        };
                        var response = await http.post(
                            Uri.parse(
                                'https://api.openai.com/v1/engines/davinci/completions'),
                            headers: {
                              HttpHeaders.authorizationHeader: "Bearer $apiKey",
                              HttpHeaders.acceptHeader: "application/json",
                              HttpHeaders.contentTypeHeader: "application/json",
                            },
                            body: jsonEncode(reqData));
                        Map<String, dynamic> map = json.decode(response.body);
                        print(map);
                        List<dynamic> resp = map["choices"];
                        String studyNotes = "1. " + resp[0]["text"];
                        await database.uploadStudyNotes(
                            studyNotes, transcriptMut.id, widget.courseId);
                        DocumentSnapshot temp =
                            await database.getCourseTranscription(
                                transcriptMut.id, widget.courseId);
                        setState(() {
                          transcriptMut = temp;
                          List<dynamic> initNotesData = [
                            {'insert': transcriptMut['studyNotes'] + '\n'}
                          ];
                          _controllers[1] = QuillController(
                              document: Document.fromJson(initNotesData),
                              selection:
                                  const TextSelection.collapsed(offset: 0));
                          isLoading = false;
                          tabID = 1;
                        });
                      });
                    },
                    child: !isLoading
                        ? const Text("Create Notes")
                        : const Center(
                            child: SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.0, color: Colors.deepPurple),
                            ),
                          ),
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
