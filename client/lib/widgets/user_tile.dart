import 'package:flutter/material.dart';
import 'package:studybuddy/color_constants.dart';
import 'package:studybuddy/services/database.dart' as database;

class UserTile extends StatefulWidget {
  const UserTile(
      {Key? key,
      required this.email,
      required this.isOwner,
      required this.uid,
      required this.courseId,
      required this.permStatus})
      : super(key: key);
  final String email;
  final String permStatus;
  final String uid;
  final String courseId;
  final bool isOwner;

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
      elevation: 2,
      child: ListTile(
        leading: const Icon(
          Icons.account_box,
          size: 35,
          color: kPrimaryColor,
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
                },
                child: const Icon(Icons.cancel_rounded,
                    size: 20, color: kDangerColor))
            : null,
        dense: true,
      ),
    );
  }
}
