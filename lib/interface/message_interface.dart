import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/models/message.dart';

import '../models/chat_user.dart';

abstract class IMessageService {
  Future<void> sendTextMessage({required String conversationId, required String senderId, required String messageContent, required DateTime timestamp});
  Stream<List<Message>> getMessages(
      {required String conversationId, int pageSize = 10, DocumentSnapshot? lastDocument});
  Future<Conversation> getConversationData(String conversationId);
  Future<String> createConversation(List<ChatUser> users);
  Future<bool> isExistsConversation(String userId1, String userId2);
  Future<String> getConversationId(String userId1, String userId2);
}