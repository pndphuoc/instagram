import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/models/message.dart';

import '../models/user_summary_information.dart';

abstract class IMessageService {
  Future<void> sendTextMessage({required String conversationId, required String senderId, required String messageContent, required DateTime timestamp});
  Future<void> sendImageMessage({required String conversationId, required String senderId, required String messageContent, required DateTime timestamp});
  Future<void> sendVideoMessage({required String conversationId, required String senderId, required String messageContent, required DateTime timestamp});

  Stream<List<Message>> getStreamMessages(
      {required String conversationId, int pageSize = 10, DocumentSnapshot? lastDocument});
  Stream<Message?> getNewMessage({required String conversationId, required DateTime? lastMessageTimestamp});
  Future<void> setLastSeenMessage({required String conversationId, required userId, required String lastSeenMessageTime});
  Stream<DateTime> fetchLastSeenMessageTimeStream({required String conversationId, required String userId});
  Future<DateTime?> getLastSeenMessageTime({required String conversationId, required String userId});
 }