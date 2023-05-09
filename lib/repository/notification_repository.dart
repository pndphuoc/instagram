import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/models/notification.dart';

class NotificationRepository {
  static final CollectionReference _notificationsRef =
  FirebaseFirestore.instance.collection('notifications');

  static Future<void> addFcmToken(String userId, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update(
        {'fcmTokens': FieldValue.arrayUnion([token])});
  }

  static Future<void> removeFcmToken(String userId, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update(
        {'fcmTokens': FieldValue.arrayRemove([token])});
  }

  static const key = "AAAAPXtb97o:APA91bGppxedrQh4896TbX23dYnWiMPGZrgCxzfers8q_QfWrzj40d574jR45Btys-UzjhQhLuc9xHW5DcPzcNhzGfbEOqncXwxnfAbbbHyS1NdiRA0kL4c2hQUTfs4SyWzJeZQbJiOY";

  static Future<void> sendMessageNotification(Map<String, dynamic> data) async {
    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
        'key=$key'
        },
        body: jsonEncode(data));
    }

    static Stream<List<Notification>> getNotifications(String userId) {
      return _notificationsRef
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs.map(
            (doc) => Notification.fromJson(doc.data() as Map<String, dynamic>),
      ).toList());
    }

    static Future<void> addNotification({required Notification notification}) async {
      final ref = _notificationsRef.doc();
      notification.id = ref.id;

      await _notificationsRef.add(notification.toJson());
    }

}
  
