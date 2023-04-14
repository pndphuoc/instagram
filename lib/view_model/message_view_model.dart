import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/services/message_services.dart';

import '../models/chat_user.dart';
import '../models/message.dart';

class MessageViewModel extends ChangeNotifier {
  final MessageServices _messageServices = MessageServices();
  final StreamController<String> _writingMessageController = StreamController<String>();
  Stream<String> get writingMessageStream => _writingMessageController.stream;

  final _messagesController = StreamController<List<Message>>();
  Stream<List<Message>> get messagesStream => _messagesController.stream;

  final StreamController<List<ChatUser>> _usersList = StreamController<List<ChatUser>>();
  Stream<List<ChatUser>> get usersStream => _usersList.stream;

  void onChange(String value) {
    _writingMessageController.sink.add(value);
  }

  Stream<List<Message>> getMessage(String conversationId) {
    checkExistsMessage(conversationId);
    return _messageServices.getMessages(conversationId: conversationId);
  }
  
  Future<void> checkExistsMessage(String conversationId) async {
    final messageRef = await FirebaseFirestore.instance.collection('conversations').doc(conversationId).collection('messages').get();
  }

  Future<void> sendMessage({String conversationId = '',
    required String senderId,
    required String messageType,
    required String messageContent,
    required DateTime timestamp}) async {

    await _messageServices.sendTextMessage(conversationId: conversationId, senderId: senderId, messageContent: messageContent, timestamp: timestamp);
  }

  Future<String> createConversation(List<ChatUser> users) async {
    return await _messageServices.createConversation(users);
  }

  Stream<List<Message>> getMessages({required String conversationId, int pageSize = 10, DocumentSnapshot? lastDocument}) {
    return _messageServices.getMessages(conversationId: conversationId, pageSize: pageSize, lastDocument: lastDocument);
  }

  Future<bool> isExistsConversation(String userId1, String userId2) async {
    return await _messageServices.isExistsConversation(userId1, userId2);
  }

  Future<String> getConversationId(String userId1, String userId2) async {
    return await _messageServices.getConversationId(userId1, userId2);
  }

/*  Future<Conversation> sendTheFirstTextMessage(List<ChatUser> users, Message message) async {
    String conversationId = await _messageServices.createConversation(users);
    await _messageServices.sendTextMessage(senderId: message.senderId, messageContent: message.content, timestamp: message.timestamp);
    return await _messageServices.getConversationData(conversationId);
  }*/


}