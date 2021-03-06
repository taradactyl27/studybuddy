import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/services/course_state.dart';
import 'package:studybuddy/services/database.dart' as database;

class FlashCardCreationForm extends StatefulWidget {
  const FlashCardCreationForm({Key? key, required this.cardsetId})
      : super(key: key);
  final String cardsetId;
  @override
  State<FlashCardCreationForm> createState() => _FlashCardCreationFormState();
}

class _FlashCardCreationFormState extends State<FlashCardCreationForm> {
  final TextEditingController _questioncontroller = TextEditingController();
  final TextEditingController _ansercontroller = TextEditingController();

  String? get _errorText {
    final text = _questioncontroller.value.text;
    if (text.length > 100) {
      return 'Too long';
    }
    return null;
  }

  @override
  void dispose() {
    _questioncontroller.dispose();
    _ansercontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseId = Provider.of<CourseState>(context).currentCourseId;

    return ValueListenableBuilder(
        valueListenable: _questioncontroller,
        builder: (context, TextEditingValue value, __) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Material(
                elevation: 20,
                child: Material(
                  elevation: 20,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _questioncontroller,
                            decoration: InputDecoration(
                              hintText: 'Question',
                              errorText: _errorText,
                              border: InputBorder.none,
                            ),
                            cursorColor: Colors.white,
                          ),
                          const Divider(
                            thickness: 0.4,
                          ),
                          TextFormField(
                            controller: _ansercontroller,
                            decoration: const InputDecoration(
                              hintText: 'Answer',
                              border: InputBorder.none,
                            ),
                            cursorColor: Colors.white,
                            maxLines: 6,
                          ),
                          const Divider(
                            thickness: 0.4,
                          ),
                          ElevatedButton(
                            onPressed: _questioncontroller.value.text.isNotEmpty
                                ? () async {
                                    if (_errorText == null) {
                                      await database.createFlashcard(
                                          courseId,
                                          widget.cardsetId,
                                          _questioncontroller.text,
                                          _ansercontroller.text);
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
