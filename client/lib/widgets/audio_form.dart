import 'dart:io';
import 'dart:math';
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
  late TextEditingController _controller;
  late FocusNode focusNode;
  double progress = 0;
  File? _pickedFile;
  String fileName = "";
  String fileEnding = "";
  bool filePicked = false;
  bool _editing = false;
  bool uploading = false;

  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(2)) + ' ' + suffixes[i];
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    if (recentFilePath.isNotEmpty) {
      _pickedFile = File(recentFilePath);
      fileName = recentFilePath.split('/').last.split(".").first;
      fileEnding = ".${recentFilePath.split('/').last.split(".").last}";
      _controller = TextEditingController(text: fileName);
      filePicked = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
                                    padding: const EdgeInsets.only(
                                        right: 10.0, left: 10.0, bottom: 10.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15.0),
                                          child: Icon(Icons.library_music,
                                              size: 30,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 42,
                                              width: 190,
                                              child: TextField(
                                                focusNode: focusNode,
                                                style: GoogleFonts.nunito(),
                                                controller: _controller,
                                                onSubmitted: (edit) {
                                                  setState(() {
                                                    fileName = edit;
                                                    _editing = false;
                                                    focusNode.unfocus();
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
                                            Text(
                                                formatBytes(
                                                    _pickedFile!.lengthSync()),
                                                style: GoogleFonts.nunito(
                                                    fontSize: 12))
                                          ],
                                        ),
                                        const SizedBox(width: 5),
                                        _editing
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    fileName = _controller.text;
                                                    focusNode.unfocus();
                                                    _editing = false;
                                                  });
                                                },
                                                child: const Icon(Icons.check,
                                                    size: 18))
                                            : InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _editing = true;
                                                    focusNode.requestFocus();
                                                  });
                                                },
                                                child: const Icon(Icons.edit,
                                                    size: 18)),
                                        const SizedBox(width: 5),
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
                                    setState(() {
                                      uploading = false;
                                      progress = 0;
                                    });
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: uploading ? 0 : 2,
                                    primary:
                                        uploading ? Colors.transparent : null,
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
