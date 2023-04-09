import 'dart:convert';

import 'package:instagram/interface/elastic_interface.dart';
import 'package:http/http.dart' as http;

class ElasticService implements IElasticService {
  String endPoint = "https://huet.es.asia-southeast1.gcp.elastic-cloud.com";
  String privateKey = "private-qe78yhgti3u2kde8ms5t7jjh";
  String publicSearchKey = "search-9mhw8iqaq4t4yc9qs2igvwob";
  String cloudId =
      "HueT:YXNpYS1zb3V0aGVhc3QxLmdjcC5lbGFzdGljLWNsb3VkLmNvbTo0NDMkMzNlN2E5NGJiYjQxNDBkZDllMjMzMWE0YjdmMTYyNjYkYjUwN2JjNzRmYzk1NGY0MDg2YmViMDBhZTI4OGVmMGE=";
  String username = "elastic";
  String password = "yZwwmdW7XnrwRAYk2AwvGOog";

  @override
  Future<bool> addDataToIndex(String index, Map<String, dynamic> data) async {
    final bytes = utf8.encode('$username:$password');
    final base64Str = base64.encode(bytes);
    final response = await http.post(
      Uri.parse(
          'https://huet.es.asia-southeast1.gcp.elastic-cloud.com/$index/_doc'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $base64Str'
      },
      body: jsonEncode(data),
    );
    final result = json.decode(response.body);
    if (result["result"] == "created") {
      return true;
    } else {
      return false;
    }

  }

  @override
  Future<List<Map<String, dynamic>>> searchData(
      String index, Map<String, dynamic> query) async {
    final bytes = utf8.encode('$username:$password');
    final base64Str = base64.encode(bytes);
    final response = await http.post(
      Uri.parse(
          'https://huet.es.asia-southeast1.gcp.elastic-cloud.com/$index/_search'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $base64Str'
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
  Future<bool> isUsernameExists(String index, String usernameQuery) async {
    final bytes = utf8.encode('$username:$password');
    final base64Str = base64.encode(bytes);
    final response = await http.post(
      Uri.parse(
          'https://huet.es.asia-southeast1.gcp.elastic-cloud.com/$index/_count'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $base64Str'
      },
      body: jsonEncode({
        'query': {'match': {
            'username': usernameQuery
          }
        }
      }),
    );
    final json = jsonDecode(response.body);
    return json['count'] == 1;
  }
}
