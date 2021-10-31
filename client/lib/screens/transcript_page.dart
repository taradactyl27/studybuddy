import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class TranscriptPage extends StatefulWidget {
  TranscriptPage({Key? key, required this.transcript, required this.courseId})
      : super(key: key);

  final QueryDocumentSnapshot<Object?> transcript;
  final String courseId;
  @override
  _TranscriptPageState createState() => _TranscriptPageState();
}

class _TranscriptPageState extends State<TranscriptPage> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    dynamic inputText = widget.transcript['text'] + '\n';
    List<dynamic> initData = [
      {'insert': inputText}
    ];
    _controller = QuillController(
        document: Document.fromJson(initData),
        selection: TextSelection.collapsed(offset: 0));
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
        ),
        body: Stack(
          children: [
            Column(
              children: [
                QuillToolbar.basic(
                  controller: _controller,
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
                      controller: _controller,
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
