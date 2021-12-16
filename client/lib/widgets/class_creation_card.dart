import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/services/database.dart' as database;

class ClassCreationCard extends StatefulWidget {
  const ClassCreationCard({Key? key}) : super(key: key);
  @override
  State<ClassCreationCard> createState() => _ClassCreationCardState();
}

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
    final uid = context.read<User>().uid;
    final email = context.read<User>().email;
    return ValueListenableBuilder(
        valueListenable: _namecontroller,
        builder: (context, TextEditingValue value, __) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Material(
                  elevation: 20,
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
                            thickness: 0.4,
                          ),
                          ElevatedButton(
                            onPressed: _namecontroller.value.text.isNotEmpty
                                ? () async {
                                    if (_errorText == null) {
                                      await database.createCourse(
                                          uid,
                                          email!,
                                          _namecontroller.text,
                                          _descriptioncontroller.text);
                                      Navigator.pop(context);
                                    }
                                  }
                                : null,
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
