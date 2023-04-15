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

  Message? _message;

  Message get message => _message!;

  set message(Message value) {
    _message = value;
  }

  String _conversationId = '';

  String get conversationId => _conversationId;

  set conversationId(String value) {
    _conversationId = value;
  }

  List<ChatUser> _users = [];

  List<ChatUser> get users => _users;

  set users(List<ChatUser> value) {
    _users = value;
  }

  final _messagesController = StreamController<List<Message>>();
  Stream<List<Message>> get messagesStream => _messagesController.stream;

  final StreamController<List<ChatUser>> _usersList = StreamController<List<ChatUser>>();
  Stream<List<ChatUser>> get usersStream => _usersList.stream;

  void onChange(String value) {
    _writingMessageController.sink.add(value);
  }

  String createConversationIdFromUsers() {
    _users.sort((a, b) => a.userId.compareTo(b.userId),);
    List<String> uid = _users.map((e) => e.userId).toList();
    return uid.join("_");
  }

  Stream<List<Message>> getMessage(String conversationId) {
    checkExistsMessage(conversationId);
    return _messageServices.getMessages(conversationId: conversationId);
  }
  
  Future<void> checkExistsMessage(String conversationId) async {
    final messageRef = await FirebaseFirestore.instance.collection('conversations').doc(conversationId).collection('messages').get();
  }

  Future<void> sendTextMessage({String conversationId = '',
    required String senderId,
    required String messageType,
    required String messageContent,
    required DateTime timestamp}) async {
    String conversationId = createConversationIdFromUsers();
    if (await _messageServices.isExistsConversation(_users.map((e) => e.userId).toList()) == false) {
      await _messageServices.createConversation(_users, conversationId);
    }
    await _messageServices.sendTextMessage(conversationId: conversationId, senderId: senderId, messageContent: messageContent, timestamp: timestamp);
  }

  Future<void> createConversation(List<ChatUser> users) async {
    await _messageServices.createConversation(users, conversationId);
  }

  Stream<List<Message>> getMessages({required String conversationId, int pageSize = 10, DocumentSnapshot? lastDocument}) {
    return _messageServices.getMessages(conversationId: conversationId, pageSize: pageSize, lastDocument: lastDocument);
  }

  Stream<Conversation> getConversationData() {
    print("hahaha");
    final String conversationId = createConversationIdFromUsers();
    print(conversationId);
    return _messageServices.getConversationData(conversationId).transform(
      StreamTransformer<DocumentSnapshot<Map<String, dynamic>>, Conversation>.fromHandlers(
        handleData: (snapshot, sink) {
          if (snapshot.data() == null) {
            return;
          }
          sink.add(Conversation.fromJson(snapshot.data()!));
        },
        handleError: (error, stackTrace, sink) {
          // Xử lý lỗi nếu có
          print('Error: $error');
        },
      ),
    );
  }

  Future<bool> isExistsConversation(List<String> userIds) async {
    return await _messageServices.isExistsConversation(userIds);
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