import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studybuddy/services/storage.dart' as storage;

class AudioForm extends StatefulWidget {
  /// {@macro add_todo_popup_card}
  const AudioForm({Key? key, required this.courseList}) : super(key: key);
  @override
  State<AudioForm> createState() => _AudioFormState();

  final List<dynamic> courseList;
}

var currentUser = FirebaseAuth.instance.currentUser;

class _AudioFormState extends State<AudioForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: 'addaudio',
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
                    FormBuilder(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      skipDisabled: true,
                      child: Column(
                        children: <Widget>[
                          FormBuilderDropdown(
                            name: 'courseID',
                            decoration: const InputDecoration(
                              labelText: 'Course',
                            ),
                            initialValue: widget.courseList.isNotEmpty
                                ? widget.courseList[0].id
                                : '',
                            allowClear: true,
                            hint: const Text('Select Course'),
                            items: widget.courseList
                                .map((course) => DropdownMenuItem(
                                      value: course.id,
                                      child: Text(course.get('name')),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.black45,
                      thickness: 0.4,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        _formKey.currentState!.save();
                        String courseID =
                            _formKey.currentState!.value['courseID'];
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        if (result != null) {
                          await storage.uploadFile(result, courseID);
                          // TODO: pop context with result of operation
                        } else {
                          // User canceled the picker
                        }

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                      ),
                      child: const Text('Choose File',
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
