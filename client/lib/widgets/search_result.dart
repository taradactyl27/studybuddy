import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/color_constants.dart';

import '../routes/routes.dart' as routes;
import '../services/database.dart' as database;

class SearchResultBox extends StatelessWidget {
  const SearchResultBox(
      {Key? key, required this.results, required this.isLoading})
      : super(key: key);
  final bool isLoading;
  final Map results;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 15,
      child: Container(
        margin: const EdgeInsets.all(15),
        height: 300,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding:
                    const EdgeInsets.only(bottom: 0, left: 0, right: 0, top: 5),
                shrinkWrap: true,
                children: results['hits'].map<Widget>((hit) {
                  return InkWell(
                      onTap: () async {
                        DocumentSnapshot<Map<String, dynamic>> transcript =
                            await database.getTranscription(
                                hit['objectID'], hit['course']);
                        Navigator.pushNamed(context, routes.transcriptPage,
                            arguments: {
                              'transcript': transcript,
                              'course_id': hit['course'],
                            });
                      },
                      child: SearchResult(hit: hit));
                }).toList(),
              ),
      ),
    );
  }
}

class SearchResult extends StatelessWidget {
  const SearchResult({Key? key, required this.hit}) : super(key: key);
  final Map hit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.insert_drive_file_outlined,
          size: 35,
          color: kPrimaryColor,
        ),
        title: Text(
          hit['audioRef'].split('/')[1].split('.')[0],
          style: GoogleFonts.nunito(),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateTime.fromMillisecondsSinceEpoch(hit['created']['_seconds'] * 1000)
              .toString(),
          style: GoogleFonts.nunito(),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        isThreeLine: false,
      ),
    );
  }
}
