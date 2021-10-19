import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studybuddy/services/database.dart';

class ClassCreationCard extends StatefulWidget {
  /// {@macro add_todo_popup_card}
  const ClassCreationCard({Key? key}) : super(key: key);
  @override
  State<ClassCreationCard> createState() => _ClassCreationCardState();
}

var currentUser = FirebaseAuth.instance.currentUser;

class _ClassCreationCardState extends State<ClassCreationCard> {
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _descriptioncontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: 'add',
          child: Material(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
                side: const BorderSide(width: 3, color: Colors.blue),
                borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _namecontroller,
                      decoration: const InputDecoration(
                        hintText: 'Class Name',
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.white,
                    ),
                    const Divider(
                      color: Colors.black45,
                      thickness: 0.4,
                    ),
                    TextFormField(
                      controller: _descriptioncontroller,
                      decoration: const InputDecoration(
                        hintText: 'Class Description',
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.white,
                      maxLines: 6,
                    ),
                    const Divider(
                      color: Colors.black45,
                      thickness: 0.4,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Database.createCourse(
                                currentUser!.uid,
                                _namecontroller.text,
                                _descriptioncontroller.text)
                            .then((value) {
                          Navigator.pop(context);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                      ),
                      child: const Text('Add',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
