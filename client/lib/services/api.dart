import 'dart:async';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

Future<String> getSearchKey([bool devMode = false]) async {
  if (devMode) {
    return "";
  }
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('algolia-generateSearchKey');
  final result = await callable();
  return result.data['key'];
}

Future<Map> getSearchResults(String key, String query) async {
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
