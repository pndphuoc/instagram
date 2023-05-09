import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_summary_information.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;

class ElasticRepository {
  static String endpoint =
      "https://instashare.ent.asia-southeast1.gcp.elastic-cloud.com";
  static String privateKey = "search-txdcaef6466jeu1nw7pzze18";
  static String apiKey =
      "cmRwMWI0Y0JnbE5tZlI3aV9mMEw6MVFZeW5qUTNTRFMzSzdzRE5scmUtdw==";
  static String usersIndex = ".ent-search-engine-documents-users";
  static String requestPath = "/api/as/v1/engines/instashare/search.json";

  static Future<List<Map<String, dynamic>>> searchData(
      {required String query, int page = 1}) async {
    final response = await http.post(
      Uri.parse('$endpoint/$requestPath'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $privateKey'
      },
      body: jsonEncode({
        "query": query,
        "page": {"size": 10, "current": page}
      }),
    );
    final json = jsonDecode(response.body);
    final results = json['results'];
    List<Map<String, dynamic>> queryResults = [];

    results.forEach((result) {
      queryResults.add(result as Map<String, dynamic>);
    });

    return queryResults;
  }

/*  static Future<bool> isUsernameExists(String usernameQuery) async {
    final bytes = utf8.encode('$username:$password');
    final base64Str = base64.encode(bytes);
    final response = await http.post(
      Uri.parse(
          '$endpoint/api/as/v1/engines/national-parks-demo/search'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'ApiKey $privateKey'
      },
      body: jsonEncode({
        'query': {'match': {
            'username': usernameQuery
          }
        }
      }),
    );
    print(response.body);
    final json = jsonDecode(response.body);
    return json['count'] == 1;
  }*/
}
