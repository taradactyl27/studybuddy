import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

import 'package:studybuddy/services/api.dart' as api;
import 'package:studybuddy/services/database.dart' as database;
import "../route_observer.dart";

class TranscriptPage extends StatefulWidget {
  const TranscriptPage(
      {Key? key,
      required this.transcript,
      required this.courseId,
      this.tabID = 0})
      : super(key: key);

  final DocumentSnapshot<Map<String, dynamic>> transcript;
  final String courseId;
  final int tabID;
  @override
  _TranscriptPageState createState() => _TranscriptPageState();
}

class _TranscriptPageState extends State<TranscriptPage> with RouteAware {
  late QuillController _textController;
  late QuillController _notesController;
  late List<QuillController> _controllers;
  late DocumentSnapshot<Map<String, dynamic>> transcriptMut;
  late bool isLoading;
  late bool isSaveLoading;
  int tabID = 0;

  @override
  void initState() {
    super.initState();
    isLoading = false;
    isSaveLoading = false;
    tabID = widget.tabID;
    transcriptMut = widget.transcript;
    var data = transcriptMut.data();

    List<dynamic> initTextData = data!.containsKey('deltas')
        ? jsonDecode(data['deltas'])
        : [
            {
              'insert':
                  data['isTranscribing'] ? '' : widget.transcript['text'] + '\n'
            }
          ];

    List<dynamic> initNotesData;
    if (data.containsKey('noteDeltas')) {
      initNotesData = jsonDecode(data['noteDeltas']);
    } else {
      if (data != null && transcriptMut['notesGenerated']) {
        initNotesData = [
          {
            'insert': data['isTranscribing']
                ? ''
                : widget.transcript['studyNotes'] + '\n'
          }
        ];
      } else {
        initNotesData = [
          {'insert': '\n'}
        ];
      }
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
    routeObserver.unsubscribe(this);
    _textController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPush() {
    final transcript = widget.transcript.data()!;
    database.updateTranscriptActivity(
        transcript['owner'], widget.courseId, widget.transcript.id);
  }

  @override
  void didPopNext() {
    final transcript = widget.transcript.data()!;
    database.updateTranscriptActivity(
        transcript['owner'], widget.courseId, widget.transcript.id);
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
          actions: transcriptMut['isTranscribing']
              ? null
              : <Widget>[
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
                          style:
                              TextButton.styleFrom(primary: Colors.deepPurple),
                          onPressed: () {
                            setState(() {
                              tabID = 1;
                            });
                          },
                          child: const Text("Our Notes"),
                        )
                      : TextButton(
                          style:
                              TextButton.styleFrom(primary: Colors.deepPurple),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            String studyNotes = await api
                                .getGeneratedStudyNotes(transcriptMut['text']);
                            await database.uploadStudyNotes(
                                studyNotes, transcriptMut.id, widget.courseId);
                            DocumentSnapshot<Map<String, dynamic>> temp =
                                await database.getTranscription(
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
                          },
                          child: !isLoading
                              ? const Text("Create Notes")
                              : const Center(
                                  child: SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        color: Colors.deepPurple),
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
          onPressed: () async {
            setState(() {
              isSaveLoading = true;
            });
            String transcriptDeltasJson =
                jsonEncode(_controllers[0].document.toDelta().toJson());
            String? notesDeltasJson;
            if (transcriptMut['notesGenerated']) {
              notesDeltasJson =
                  jsonEncode(_controllers[1].document.toDelta().toJson());
            }
            await database.uploadDocumentDeltas(transcriptDeltasJson, 'deltas',
                transcriptMut.id, widget.courseId);
            if (notesDeltasJson != null) {
              await database.uploadDocumentDeltas(notesDeltasJson, 'noteDeltas',
                  transcriptMut.id, widget.courseId);
            }
            setState(() {
              isSaveLoading = false;
            });
          },
          child: isSaveLoading
              ? const Center(
                  child: SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0, color: Colors.white),
                  ),
                )
              : const Icon(Icons.check, color: Colors.white),
        ));
  }
}
