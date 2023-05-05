import 'dart:convert';

import 'package:http/http.dart' as http;

class ElasticRepository {
  static String endpoint = "https://a5e8ec9e4bf44999a1fe005d7925db89.ent-search.us-central1.gcp.cloud.es.io";
  static String privateKey = "private-rnmssjj681asgqft7hqqx8pq";
  static String apiKey = "cmRwMWI0Y0JnbE5tZlI3aV9mMEw6MVFZeW5qUTNTRFMzSzdzRE5scmUtdw==";
  static String usersIndex = ".ent-search-engine-documents-users";

  static String username = "duyphuoc";
  static String password = "duyphuoc313";

  static Future<List<Map<String, dynamic>>> searchData(
      String index, Map<String, dynamic> query) async {
    final response = await http.post(
      Uri.parse(
          '$endpoint/$index/_search'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'ApiKey $apiKey'
      },
      body: jsonEncode({
        'query': query
      }),
    );
    final json = jsonDecode(response.body);
    final hits = json['hits']['hits'];
    List<Map<String, dynamic>> results = [];
    hits.forEach((hit) {
      results.add(hit['_source'] as Map<String, dynamic>);
    });

    return results;
  }

  static Future<bool> isUsernameExists(String usernameQuery) async {
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
  }
}
