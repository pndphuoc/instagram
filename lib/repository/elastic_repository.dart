import 'dart:convert';

import 'package:http/http.dart' as http;


class ElasticRepository {
  static String endpoint =
      "https://instashare-b93c47.ent.asia-southeast1.gcp.elastic-cloud.com";
  static String privateKey = "search-bae599cfmwuzhspfy4hbdyuy";
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
}
