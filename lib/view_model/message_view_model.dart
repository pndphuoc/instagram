import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/services/message_services.dart';

import '../models/chat_user.dart';
import '../models/message.dart';

class MessageViewModel extends ChangeNotifier {
  final MessageServices _messageServices = MessageServices();

  Future<void> sendMessage( {String conversationId = '',
    required String senderId,
    required String messageType,
    required String messageContent,
    required DateTime timestamp}) async {
    await _messageServices.sendMessage(senderId: senderId, messageType: messageType, messageContent: messageContent, timestamp: timestamp);
  }

  Future<void> createConversation(List<ChatUser> users) async {
    await _messageServices.createConversation(users);
  }

  Stream<List<Message>> getMessages({required String conversationId, int pageSize = 10, DocumentSnapshot? lastDocument}) {
    return _messageServices.getMessages(conversationId: conversationId, pageSize: pageSize, lastDocument: lastDocument);
  }
}