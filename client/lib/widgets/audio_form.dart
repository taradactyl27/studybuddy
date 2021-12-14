import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/services/sound_recorder.dart';
import 'package:studybuddy/color_constants.dart';

import 'package:studybuddy/services/storage.dart' as storage;
import 'package:studybuddy/services/database.dart' as database
    show newLectureRef, getUserCourseStream;
import 'package:studybuddy/routes/routes.dart' as routes;

class AudioForm extends StatefulWidget {
  /// {@macro add_todo_popup_card}
  const AudioForm({Key? key}) : super(key: key);
  @override
  State<AudioForm> createState() => _AudioFormState();
}

class _AudioFormState extends State<AudioForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  late TextEditingController _controller;
  double progress = 0;
  File? _pickedFile;
  String fileName = "";
  String fileEnding = "";
  bool filePicked = false;
  bool _editing = false;
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
                                  decoration: InputDecoration(
                                    labelStyle: GoogleFonts.nunito(),
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
                    filePicked
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Material(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.library_music,
                                            size: 30),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 190,
                                          child: TextField(
                                            style: GoogleFonts.nunito(),
                                            controller: _controller,
                                            onSubmitted: (edit) {
                                              setState(() {
                                                fileName = edit;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              border: _editing
                                                  ? null
                                                  : InputBorder.none,
                                            ),
                                            readOnly: !_editing,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        _editing
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    fileName = _controller.text;
                                                    _editing = false;
                                                  });
                                                },
                                                child: const Icon(Icons.check,
                                                    size: 18))
                                            : InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _editing = true;
                                                  });
                                                },
                                                child: const Icon(Icons.edit,
                                                    size: 18)),
                                        InkWell(
                                            onTap: () {
                                              setState(() {
                                                _pickedFile = null;
                                                filePicked = false;
                                              });
                                            },
                                            child: const Icon(Icons.close,
                                                size: 18))
                                      ],
                                    ),
                                  )),
                              const SizedBox(height: 10),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _formKey.currentState!.save();
                                    String courseID = _formKey
                                        .currentState!.value['courseID'];
                                    setState(() {
                                      uploading = true;
                                    });

                                    String audioID =
                                        database.newLectureRef(courseID).id;

                                    UploadTask upload = storage.createUpload(
                                        user,
                                        courseID,
                                        audioID,
                                        _pickedFile!,
                                        "$fileName$fileEnding");

                                    upload.snapshotEvents.listen((event) {
                                      setState(() {
                                        progress = (event.bytesTransferred /
                                            event.totalBytes);
                                      });
                                    });

                                    await upload;
                                    print('audio UPLOAD done!!!');

                                    setState(() {
                                      uploading = false;
                                      progress = 0;
                                    });
                                    // TODO: pop context with result of operation
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: uploading ? 0 : 2,
                                    primary: uploading
                                        ? Colors.transparent
                                        : Colors.blue,
                                  ),
                                  child: uploading
                                      ? LinearProgressIndicator(
                                          value: progress,
                                        )
                                      : const Text('Upload File',
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                ),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles();
                              if (result != null) {
                                setState(() {
                                  _pickedFile = File(result.files.single.path!);
                                  fileName = _pickedFile!.path
                                      .split('/')
                                      .last
                                      .split(".")
                                      .first;
                                  fileEnding =
                                      ".${_pickedFile!.path.split('/').last.split(".").last}";
                                  _controller =
                                      TextEditingController(text: fileName);
                                  filePicked = true;
                                });
                                // TODO: pop context with result of operation
                              } else {
                                // User canceled the picker
                              }
                            },
                            child: uploading
                                ? LinearProgressIndicator(
                                    value: progress,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(10),
                                      dashPattern: const [10, 4],
                                      strokeCap: StrokeCap.round,
                                      color: Colors.blue.shade400,
                                      child: Container(
                                        width: double.infinity,
                                        height: 150,
                                        decoration: BoxDecoration(
                                            color: Colors.blue.shade50
                                                .withOpacity(MediaQuery.of(
                                                                context)
                                                            .platformBrightness ==
                                                        Brightness.light
                                                    ? .3
                                                    : 0.05),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.folder_open,
                                              color: Colors.blue,
                                              size: 48,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              'Select your file',
                                              style: GoogleFonts.nunito(
                                                  textStyle: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors
                                                          .grey.shade400)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                          ),
                    // ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       elevation: 2,
                    //       primary: Colors.blue,
                    //     ),
                    //     onPressed: () async {
                    //       await Navigator.pushNamed(
                    //           context, routes.recordingPage);
                    //     },
                    //     child: const Text('Record',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //         ))),
                    // ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       elevation: 2,
                    //       primary: Colors.blue,
                    //     ),
                    //     onPressed: () async {
                    //       _formKey.currentState!.save();
                    //       String courseID =
                    //           _formKey.currentState!.value['courseID'];

                    //       String temp = recentFilePath;
                    //       //String tempFileName = "test File 1";
                    //       //String tempFileName = tempfilename;
                    //       print("recording file and name updated");

                    //       setState(() {
                    //         uploading = true;
                    //       });
                    //       print("started uploading");

                    //       String audioID = database.newLectureRef(courseID).id;
                    //       File file = File(temp);
                    //       String name = tempfilename;

                    //       UploadTask upload = storage.createUpload(
                    //           user, courseID, audioID, file, name);

                    //       upload.snapshotEvents.listen((event) {
                    //         setState(() {
                    //           progress =
                    //               (event.bytesTransferred / event.totalBytes);
                    //         });
                    //       });

                    //       await upload;
                    //       print('audio UPLOAD done!!!');

                    //       setState(() {
                    //         uploading = false;
                    //         progress = 0;
                    //       });
                    //     },
                    //     child: const Text('Upload Recording',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //         )))
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
