import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/conversation.dart';
import '../models/user_summary_information.dart';

abstract class IConversationService {
  Stream<List<String>> getConversationIds(
      {required String userId,
      int pageSize = 20,
      DocumentSnapshot<Object?>? lastDocument});

  Stream<DocumentSnapshot> getConversationData(
      {required String conversationId});

  Future<void> createConversation(
      {required List<UserSummaryInformation> users,
      required String conversationId,
      required String messageContent,
      required DateTime messageTime});

  Future<bool> isExistsConversation(List<String> userIds);

  Future<void> updateLastMessageOfConversation(
      {required String conversationId,
      required String content,
      required DateTime timestamp,
      required String type});
}
