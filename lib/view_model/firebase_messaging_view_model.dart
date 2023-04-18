import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:instagram/services/firebase_messaging_services.dart';

class FirebaseMessagingViewModel {
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();
  Future<String?> getToken() async {
    return await _messagingService.getToken();
  }

  Future<void> setupFirebaseMessaging() async {
    await _messagingService.setupFirebaseMessaging();
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    _handleBackgroundMessage(message);
  }
}