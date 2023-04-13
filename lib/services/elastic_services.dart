import 'dart:convert';

import 'package:instagram/interface/elastic_interface.dart';
import 'package:http/http.dart' as http;

class ElasticService implements IElasticService {
  String endpoint = "https://a5e8ec9e4bf44999a1fe005d7925db89.ent-search.us-central1.gcp.cloud.es.io";
  String privateKey = "private-rnmssjj681asgqft7hqqx8pq";
  String apiKey = "cmRwMWI0Y0JnbE5tZlI3aV9mMEw6MVFZeW5qUTNTRFMzSzdzRE5scmUtdw==";
  String usersIndex = ".ent-search-engine-documents-users";

  String username = "duyphuoc";
  String password = "duyphuoc313";

  @override
  Future<List<Map<String, dynamic>>> searchData(
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

  @override
  Future<bool> isUsernameExists(String usernameQuery) async {
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
