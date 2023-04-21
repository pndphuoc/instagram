import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/services/conversation_services.dart';

import '../models/conversation.dart';

class ConversationViewModel extends ChangeNotifier {
  final ConversationService _conversationService = ConversationService();

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;


  Stream<Conversation> getConversationData(String conversationId) {
    return _conversationService.getConversationData(conversationId: conversationId).transform(
      StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
          Conversation>.fromHandlers(
        handleData: (snapshot, sink) async {
          if (snapshot.data() == null) {
            return;
          }

          sink.add(Conversation.fromJson(snapshot.data()!));
        },
        handleError: (error, stackTrace, sink) {
          print('Error: $error');
        }
      ),
    );
  }

  Stream<List<String>> getConversationIds(
      {required String userId,
        int pageSize = 20,
        DocumentSnapshot<Object?>? lastDocument}) {
    return _conversationService.getConversationIds(userId: userId);
  }

  Future<void> updateLastMessageOfConversation(
      {required String conversationId,
        required String content,
        required DateTime timestamp,
        required String type}) async {
    if (type == 'image') {
      content = 'Sent a image';
    } else if (type == 'video') {
      content = 'Sent a video';
    }
    _conversationService.updateLastMessageOfConversation(
        conversationId: conversationId,
        content: content,
        timestamp: timestamp,
        type: type);
  }

}