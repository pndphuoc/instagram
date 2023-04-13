import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/message.dart';

import '../models/chat_user.dart';

abstract class IMessageService {
  Future<void> sendMessage({String conversationId = '', required String senderId, required String messageType, required String messageContent, required DateTime timestamp});
  Stream<List<Message>> getMessages(
      {required String conversationId, int pageSize = 10, DocumentSnapshot? lastDocument});
  Future<String> createConversation(List<ChatUser> users);
}