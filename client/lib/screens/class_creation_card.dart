import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/services/database.dart' as database;

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

  String? get _errorText {
    final text = _namecontroller.value.text;

    if (text.length > 20) {
      return 'Too long';
    }
    return null;
  }

  @override
  void dispose() {
    _namecontroller.dispose();
    _descriptioncontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _namecontroller,
        builder: (context, TextEditingValue value, __) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Hero(
                tag: 'add',
                child: Material(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 3, color: Colors.black45),
                      borderRadius: BorderRadius.circular(32)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _namecontroller,
                            decoration: InputDecoration(
                              hintText: 'Class Name',
                              errorText: _errorText,
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
                            onPressed: _namecontroller.value.text.isNotEmpty
                                ? () async {
                                    if (_errorText == null) {
                                      await database.createCourse(
                                          _namecontroller.text,
                                          _descriptioncontroller.text);
                                      Navigator.pop(context);
                                    }
                                  }
                                : null,
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
        });
  }
}
