import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../models/post.dart';

class AISpaceRepository {
  static final CollectionReference _postsRef = FirebaseFirestore.instance.collection('posts');
  static String apiKey = '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';
  
  static Future<List<String>> generateImagesFromDallE({required String prompt,required int quantity, required String size}) async {
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
    print(data);
    return urls;
  }
  
  static Future<List<Post>> getPostsInAISpace() async {
    final snap = await _postsRef
        .where('isShareToAISpace', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .orderBy('createAt', descending: true)
        .orderBy('likeCount', descending: true)
        .get();

    return snap.docs.map((e) => Post.fromJson(e.data() as Map<String, dynamic>)).toList();
  }
}