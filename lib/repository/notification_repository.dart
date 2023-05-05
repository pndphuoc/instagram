import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class NotificationRepository {

  static Future<void> addFcmToken(String userId, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update(
        {'fcmTokens': FieldValue.arrayUnion([token])});
  }

  static Future<void> removeFcmToken(String userId, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update(
        {'fcmTokens': FieldValue.arrayRemove([token])});
  }

  static final key = "AAAAPXtb97o:APA91bGppxedrQh4896TbX23dYnWiMPGZrgCxzfers8q_QfWrzj40d574jR45Btys-UzjhQhLuc9xHW5DcPzcNhzGfbEOqncXwxnfAbbbHyS1NdiRA0kL4c2hQUTfs4SyWzJeZQbJiOY";

  static Future<void> sendMessageNotification(Map<String, dynamic> data) async {
    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
        'key=$key'
        },
        body: jsonEncode(data));

    }
}
  
