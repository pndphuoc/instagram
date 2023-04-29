import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/message.dart';


abstract class IMessageService {
  Future<void> sendTextMessage({required String conversationId, required String senderId, required String messageContent, required DateTime timestamp});
  Future<void> sendImageMessage({required String conversationId, required String senderId, required String messageContent, required DateTime timestamp});
  Future<void> sendVideoMessage({required String conversationId, required String senderId, required String messageContent, required DateTime timestamp});

  Stream<List<Message>> getStreamMessages(
      {required String conversationId, int pageSize = 10, DocumentSnapshot? lastDocument});
  Stream<List<Message>?> getNewMessage({required String conversationId, required DateTime? lastMessageTimestamp});
  Stream<bool> isTurnOffNotification({required String userId, required String conversationId});
  Future<void> changeNotificationSetting({required String userId, required String conversationId, required isTurnOffNotification});
}