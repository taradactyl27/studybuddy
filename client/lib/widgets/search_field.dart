import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({Key? key, required this.hit}) : super(key: key);
  final Map hit;
  

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.insert_drive_file_outlined,size:35,color: Colors.lightBlueAccent,), 
        title: Text(hit['audioRef'].split('/')[1].split('.')[0]),
        subtitle: Text(
          DateTime.fromMillisecondsSinceEpoch(hit['created']['_seconds'] * 1000).toString()
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded),
        isThreeLine: true,
      ),
    );
  }
}