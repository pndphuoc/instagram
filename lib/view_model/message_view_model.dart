import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/services/message_services.dart';
import 'package:instagram/services/user_services.dart';

import '../models/chat_user.dart';
import '../models/message.dart';

class MessageViewModel extends ChangeNotifier {
  MessageViewModel() {
    createConversationIdFromUsers();
  }
  final UserService _userService = UserService();

  final MessageServices _messageServices = MessageServices();
  final StreamController<String> _writingMessageController = StreamController<String>();
  Stream<String> get writingMessageStream => _writingMessageController.stream;

  late String _conversationId;

  String get conversationId => _conversationId;
  List<ChatUser> _users = [];

  List<ChatUser> get users => _users;

  final _messagesController = StreamController<List<Message>>();
  Stream<List<Message>> get messagesStream => _messagesController.stream;

  final StreamController<List<ChatUser>> _usersList = StreamController<List<ChatUser>>();
  Stream<List<ChatUser>> get usersStream => _usersList.stream;

  void onChange(String value) {
    _writingMessageController.sink.add(value);
  }

  void createConversationIdFromUsers() {
    _users.sort((a, b) => a.userId.compareTo(b.userId),);
    List<String> uid = _users.map((e) => e.userId).toList();
    _conversationId = uid.join("_");
  }

  Future<void> sendTextMessage({
    required String senderId,
    required String messageType,
    required String messageContent,
    required DateTime timestamp}) async {
    if (await _messageServices.isExistsConversation(_users.map((e) => e.userId).toList()) == false) {
      await _messageServices.createConversation(_users, _conversationId, messageContent, timestamp);
    }
    await _messageServices.sendTextMessage(conversationId: _conversationId, senderId: senderId, messageContent: messageContent, timestamp: timestamp);
    await updateLastMessageOfConversation(conversationId: _conversationId, content: messageContent, type: messageType, timestamp: timestamp);
  }

  Stream<List<Message>> getMessages({int pageSize = 25, DocumentSnapshot? lastDocument}) {
    return _messageServices.getStreamMessages(conversationId: _conversationId, pageSize: pageSize, lastDocument: lastDocument);
  }

  Stream<Conversation> getConversationData(String conversationId) {
    return _messageServices.getStreamConversationData(conversationId).transform(
      StreamTransformer<DocumentSnapshot<Map<String, dynamic>>, Conversation>.fromHandlers(
        handleData: (snapshot, sink) async {
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

  Stream<List<String>> getConversationIds({required String userId, int pageSize = 20, DocumentSnapshot<Object?>? lastDocument}) {
    return _messageServices.getConversationIds(userId: userId);
  }

  Future<void> updateLastMessageOfConversation({required String conversationId, required String content, required DateTime timestamp, required String type}) async {
    if (type == 'image') {
      content = 'Sent a image';
    } else if (type == 'video') {
      content = 'Sent a video';
    }
    _messageServices.updateLastMessageOfConversation(conversationId: conversationId, content: content, timestamp: timestamp, type: type);
  }

  Stream<String> getOnlineStatus(String userId) {
    return _userService.getLastOnlineTime(userId).transform(
        StreamTransformer.fromHandlers(
            handleData: (snapshot, sink) async {
              if (snapshot.isNaN) return;

              final lastOnline = DateTime.fromMillisecondsSinceEpoch(snapshot);
              final difference = DateTime.now().difference(lastOnline);
              String status = 'Online';
              if (difference.inMinutes < 2) {
                status = "Online";
              } else {
                status = "Online ${difference.inMinutes} minutes ago";
              }
              sink.add(status);
            }
        )
    );
  }


/*  Stream<List<Conversation>> getConversations() {
    return _messageServices.getConversations(userId: FirebaseAuth.instance.currentUser!.uid).transform(
      StreamTransformer<List<dynamic>, List<Conversation>>.fromHandlers(
        handleData: (snapshot, sink) async {
          if (snapshot.isEmpty) return;
          sink.add(await )
        }
      )
    );
  }*/
}