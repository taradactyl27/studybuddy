import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../services/database.dart' as database;

class TranscriptTile extends StatefulWidget {
  const TranscriptTile(
      {Key? key, required this.transcript, required this.courseId})
      : super(key: key);
  final QueryDocumentSnapshot<Map<String, dynamic>> transcript;
  final String courseId;

  @override
  State<TranscriptTile> createState() => _TranscriptTileState();
}

class _TranscriptTileState extends State<TranscriptTile> {
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  void generateNotes() async {
    setState(() {
      isLoading = true;
    });
    String? apiKey = dotenv.env['OPEN_AI_KEY'];
    Map reqData = {
      "prompt": widget.transcript['text'] + ". To summarize in depth: 1.",
      "max_tokens": 100,
      "temperature": 0.7,
      "stop": ["5."],
    };
    var response = await http.post(
        Uri.parse('https://api.openai.com/v1/engines/davinci/completions'),
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
        studyNotes, widget.transcript.id, widget.courseId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 180,
        width: 180,
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          borderRadius: const BorderRadius.all(
              Radius.circular(20.0) //                 <--- border radius here
              ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.transcript['audioRef'].split('/')[1]),
            widget.transcript['isTranscribing']
                ? (!widget.transcript['notesGenerated']
                    ? ElevatedButton(
                        onPressed: generateNotes,
                        child: !isLoading
                            ? const Text("Create Notes")
                            : const Center(
                                child: SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.0, color: Colors.black),
                                ),
                              ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          print(await database.getStudyNotes(
                              widget.transcript.id, widget.courseId));
                        },
                        child: const Text("Print Notes"),
                      ))
                : const Text(
                    "gone transcribin' ... watch some tiktoks and come back "),
          ],
        ));
  }
}
