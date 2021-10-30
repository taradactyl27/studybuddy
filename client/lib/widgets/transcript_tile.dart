import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TranscriptTile extends StatelessWidget {
  const TranscriptTile({Key? key, required this.transcript}) : super(key: key);
  final QueryDocumentSnapshot<Object?> transcript;

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
            Text(transcript['audioRef']),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Create Notes"),
            )
          ],
        ));
  }
}
