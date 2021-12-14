import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/color_constants.dart';

import 'package:studybuddy/services/storage.dart' as storage;
import 'package:studybuddy/services/database.dart' as database
    show newLectureRef, getUserCourseStream;

class AudioForm extends StatefulWidget {
  /// {@macro add_todo_popup_card}
  const AudioForm({Key? key}) : super(key: key);
  @override
  State<AudioForm> createState() => _AudioFormState();
}

class _AudioFormState extends State<AudioForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  double progress = 0;
  bool uploading = false;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<User>();
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
                    FormBuilder(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      skipDisabled: true,
                      child: Column(
                        children: <Widget>[
                          StreamBuilder(
                              stream: database.getUserCourseStream(user.uid),
                              builder: (context,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox(
                                      height: 50,
                                      child: Center(
                                          child: CircularProgressIndicator()));
                                }
                                return FormBuilderDropdown(
                                  name: 'courseID',
                                  decoration: const InputDecoration(
                                    labelText: 'Course',
                                  ),
                                  allowClear: true,
                                  hint: Text('Select Course',
                                      style: GoogleFonts.nunito()),
                                  items: snapshot.data!.docs
                                      .map((course) => DropdownMenuItem(
                                            value: course.id,
                                            child: Text(course.get('name'),
                                                style: GoogleFonts.nunito()),
                                          ))
                                      .toList(),
                                );
                              }),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
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
                          setState(() {
                            uploading = true;
                          });
                          String audioID = database.newLectureRef(courseID).id;

                          UploadTask upload = storage.createUpload(
                              user, courseID, audioID, result);

                          upload.snapshotEvents.listen((event) {
                            setState(() {
                              progress =
                                  (event.bytesTransferred / event.totalBytes);
                            });
                          });

                          await upload;
                          print('audio UPLOAD done!!!');

                          setState(() {
                            uploading = false;
                            progress = 0;
                          });
                          // TODO: pop context with result of operation
                        } else {
                          // User canceled the picker
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: uploading ? 0 : 2,
                        primary: uploading ? kBgLightColor : kPrimaryColor,
                      ),
                      child: uploading
                          ? LinearProgressIndicator(
                              value: progress,
                            )
                          : Text('Choose File',
                              style: GoogleFonts.nunito(
                                textStyle:
                                    const TextStyle(color: kLightTextColor),
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
