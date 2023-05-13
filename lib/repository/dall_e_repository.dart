import 'dart:convert';
import 'package:http/http.dart' as http;

class DallERepository {
  static String apiKey = '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';
  static Future<List<String>> generateImages({required String prompt,required int quantity, required String size}) async {
    String url = 'https://api.openai.com/v1/images/generations';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    Map<String, dynamic> body = {
      'prompt': prompt,
      'n': quantity,
      'size': size,
    };
    String jsonBody = jsonEncode(body);
    http.Response response = await http.post(Uri.parse(url), headers: headers, body: jsonBody);
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> data = jsonResponse['data'];
    List<String> urls = data.map((image) => image['url'] as String).toList();
    return urls;
  }
}