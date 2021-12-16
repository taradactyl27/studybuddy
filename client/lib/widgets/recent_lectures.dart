import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../routes/routes.dart' as routes;
import '../services/database.dart' as database;

class SearchResult extends StatelessWidget {
  const SearchResult({Key? key, required this.hit}) : super(key: key);
  final Map hit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.insert_drive_file_outlined,
          size: 35,
          color: Colors.lightBlueAccent,
        ),
        title: Text(hit['audioRef'].split('/')[1].split('.')[0]),
        subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                hit['created']['_seconds'] * 1000)
            .toString()),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        isThreeLine: true,
      ),
    );
  }
}
