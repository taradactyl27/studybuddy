import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserTile extends StatefulWidget {
  const UserTile({Key? key, required this.email, required this.permStatus})
      : super(key: key);
  final String email;
  final String permStatus;

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
        title: Text(widget.email.length > 25
            ? widget.email.substring(0, 25) + "..."
            : widget.email),
        subtitle: Text(widget.permStatus),
        isThreeLine: false,
        dense: true,
      ),
    );
  }
}
