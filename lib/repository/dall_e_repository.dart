import 'dart:convert';
import 'package:http/http.dart' as http;

class DallERepository {
  static String apiKey = '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';
  static generateImages({required String prompt, int quantity = 2, String size = '1024x1024'}) async {
    String url = 'https://api.openai.com/v1/images/generations';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    Map<String, dynamic> body = {
      'prompt': prompt,
      'n': 1,
      'size': size,
    };
    String jsonBody = jsonEncode(body);
    http.Response response = await http.post(Uri.parse(url), headers: headers, body: jsonBody);
    print(response.body);
  }
}