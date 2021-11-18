import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String> getSearchKey() async {
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('algolia-generateSearchKey');
  final result = await callable();
  return result.data['key'];
}

Future<Map> getSearchResults(String key, String query) async {
  // TODO: delete post mvp
  // HttpsCallable callable =
  //     FirebaseFunctions.instance.httpsCallable('algolia-generateSearchKey');
  // final result = await callable();
  // String key = result.data['key'];

  Map<String, String> _headers = <String, String>{
    'X-Algolia-Application-Id': 'STFQQELZGY',
    'X-Algolia-API-Key': key,
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Map reqData = {
    'query': query,
  };

  var response = await http.post(
    Uri.parse('https://stfqqelzgy-dsn.algolia.net/1/indexes/audios/query'),
    headers: _headers,
    body: jsonEncode(reqData),
  );

  Map<String, dynamic> map = json.decode(response.body);
  print(map);
  print(map['hits'].length);
  return map;
}

Future<String> getGeneratedStudyNotes(String promptText) async {
  String? apiKey = dotenv.env['OPEN_AI_KEY'];
  Map reqData = {
    "prompt": promptText + ". To summarize in depth: 1.",
    "max_tokens": 100,
    "temperature": 0.3,
    "stop": ["5."],
  };
  var response = await http.post(
      Uri.parse('https://api.openai.com/v1/engines/davinci/completions'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $apiKey",
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.contentTypeHeader: "application/json",
      },
      body: jsonEncode(reqData));

  Map<String, dynamic> map = json.decode(response.body);
  List<dynamic> resp = map["choices"];
  String studyNotes = "1. " + resp[0]["text"];
  return studyNotes;
}
