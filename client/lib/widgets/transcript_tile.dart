import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:studybuddy/services/database.dart' as database;

class TranscriptTile extends StatefulWidget {
  const TranscriptTile(
      {Key? key, required this.transcript, required this.courseId})
      : super(key: key);
  final QueryDocumentSnapshot<Object?> transcript;
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

  @override
  Widget build(BuildContext context) {
   return Card(
      child: ListTile(
        leading: const Icon(
          Icons.insert_drive_file_outlined,
          size: 35,
          color: Colors.lightBlueAccent,
        ),
        title: Text(widget.transcript['audioRef'].split('/')[1].split('.')[0]),
        subtitle: Text((widget.transcript['created'].toDate().toString())),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        isThreeLine: true,
      ),
    );
  }
}
