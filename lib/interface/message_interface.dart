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
  Stream<DocumentSnapshot> getStreamConversationData(String conversationId);
  Future<void> createConversation(List<UserSummaryInformation> users, String conversationId, String messageContent, DateTime messageTime);
  Future<bool> isExistsConversation(List<String> userIds);
  Stream<List<String>> getConversationIds({required String userId, int pageSize = 20, DocumentSnapshot? lastDocument});
  Future<void> updateLastMessageOfConversation({required String conversationId, required String content, required DateTime timestamp, required String type});
}