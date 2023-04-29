import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/services/conversation_services.dart';
import 'package:instagram/services/message_services.dart';
import 'package:rxdart/rxdart.dart';

import '../models/conversation.dart';

class ConversationViewModel extends ChangeNotifier {
  final ConversationService _conversationService = ConversationService();
  final MessageServices _messageServices = MessageServices();

  final _statusController = StreamController<bool>();
  final _unseenMessageController = StreamController<bool>();
  Stream<bool> get hasUnseenMessage => _unseenMessageController.stream;
  Stream<bool> get statusStream => _statusController.stream;

  Stream<Conversation> getConversationData(String conversationId) {
    Stream<Conversation> conversationStream = _conversationService
        .getConversationData(conversationId: conversationId)
        .map((snapshot) {
          Conversation conversation =
              Conversation.fromJson(snapshot.data() as Map<String, dynamic>);
          return conversation;
        })
        .distinct();

    Stream<bool> seenStatusStream = _conversationService.seenStatusStream(
        conversationId: conversationId,
        userId: FirebaseAuth.instance.currentUser!.uid);

    return Rx.combineLatest2(conversationStream, seenStatusStream,
        (Conversation conversation, bool isSeen) {
      conversation.isSeen = isSeen;
      return conversation;
    });
  }

  Stream<bool> isTurnOffNotificationStream({required String conversationId}) {
    return _messageServices.isTurnOffNotification(userId: FirebaseAuth.instance.currentUser!.uid, conversationId: conversationId);
  }

  Future<void> changeNotificationSetting({required String conversationId, required isTurnOffNotification}) async {
    await _messageServices.changeNotificationSetting(userId: FirebaseAuth.instance.currentUser!.uid, conversationId: conversationId, isTurnOffNotification: isTurnOffNotification);
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

  @override
  void dispose() {
    _statusController.close();
    super.dispose();
  }
}
