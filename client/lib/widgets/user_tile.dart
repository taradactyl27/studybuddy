import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studybuddy/services/database.dart' as database;

class UserTile extends StatefulWidget {
  const UserTile(
      {Key? key,
      required this.email,
      required this.isOwner,
      required this.uid,
      required this.courseId,
      required this.refreshPermList,
      required this.permStatus})
      : super(key: key);
  final String email;
  final String permStatus;
  final String uid;
  final String courseId;
  final bool isOwner;
  final Function refreshPermList;

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
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
        tileColor: Colors.white,
        leading: const Icon(
          Icons.account_box,
          size: 35,
          color: Colors.lightBlueAccent,
        ),
        title: Text(widget.email.length > 22
            ? widget.email.substring(0, 22) + "..."
            : widget.email),
        subtitle: Text(widget.permStatus),
        isThreeLine: false,
        trailing: widget.isOwner && widget.permStatus == "user"
            ? InkWell(
                onTap: () async {
                  await database.removeUserFromCourse(
                      widget.courseId, widget.uid);
                  widget.refreshPermList();
                },
                child: const Icon(Icons.cancel_rounded,
                    size: 20, color: Colors.red))
            : null,
        dense: true,
      ),
    );
  }
}