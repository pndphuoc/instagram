import 'package:firebase_messaging/firebase_messaging.dart';

abstract class INotificationService {
  static Future<void> addFcmToken(String userId, String token) async {}
  static Future<void> removeFcmToken(String userId, String token) async {}
  Future<void> pushNotificationForFCM(RemoteMessage message);
}