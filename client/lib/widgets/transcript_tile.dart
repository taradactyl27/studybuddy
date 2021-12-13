import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studybuddy/color_constants.dart';

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

  @override
  Widget build(BuildContext context) {
    bool hasText = widget.transcript.data().containsKey('text');
    DateTime date = widget.transcript['created'].toDate();
    return Card(
      child: ListTile(
        tileColor: hasText ? kLightTextColor : kInactiveTileColor,
        leading: const Icon(
          Icons.insert_drive_file_outlined,
          size: 35,
          color: kPrimaryColor,
        ),
        title: Text(widget.transcript['audioRef'].split('/')[1].split('.')[0]),
        subtitle: Column(
          children: [
            Wrap(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(DateFormat.yMMMMEEEEd().format(date)),
                Text(DateFormat.Hms().format(date))
              ],
            ),
            Visibility(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("gone transcribin'. check back soon"),
                  const Text(
                      "(it's not like YOU ever actually study right after class)"),
                  Text("status: " +
                      (widget.transcript.data().containsKey("status")
                          ? widget.transcript['status']
                          : "stealing ur data...")),
                ],
              ),
              visible: !hasText,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        isThreeLine: true,
      ),
    );
  }
}
