import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/interface/message_interface.dart';
import 'package:instagram/models/chat_user.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/models/message.dart';

import '../models/message_content.dart';

class MessageServices implements IMessageService {
  final CollectionReference _conversationsCollection =
      FirebaseFirestore.instance.collection('conversations');

  @override
  Future<String> createConversation(List<ChatUser> users) async {
    final conversationRef = _conversationsCollection.doc();
    await conversationRef.set({'userIds': FieldValue.arrayUnion(users.map((user) => user.userId).toList())});
    await conversationRef.update({'users': FieldValue.arrayUnion(users.map((user) => user.toJson()).toList())});
    return conversationRef.id;
  }

  @override
  Future<void> sendMessage(
      {String conversationId = '',
      required String senderId,
      required String messageType,
      required String messageContent,
      required DateTime timestamp}) async {
    try {
      // Lấy reference của document conversation cần gửi tin nhắn vào
      final messageRef = _conversationsCollection.doc(conversationId).collection('messages').doc();

      // Tạo một message mới
      final message = Message(
        id: messageRef.id,
        senderId: senderId,
        type: messageType,
        content: messageContent,
        timestamp: timestamp,
        status: 'sent'
      );

      // Thêm message vào mảng messages của document conversation
      await messageRef.set(message.toJson());
    } catch (error) {
      // Xử lý lỗi nếu có
      print('Error sending message: $error');
    }
  }

  @override
  Stream<List<Message>> getMessages({required String conversationId, int pageSize = 10, DocumentSnapshot? lastDocument}) {
    CollectionReference messagesCollection = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');

    Query query = messagesCollection
        .orderBy('timestamp', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  @override
  Future<bool> isExistsConversation(String userId1, String userId2) async {
    final List<String> userIds = [userId1, userId2];
    final QuerySnapshot conversationsQuery = await _conversationsCollection
        .where('userIds', isEqualTo: userIds)
        .get();
    print(conversationsQuery.docs.length);
    return conversationsQuery.docs.isNotEmpty;
  }

  @override
  Future<String> getConversationId(String userId1, String userId2) async {
    final List<String> userIds = [userId1, userId2];
    final QuerySnapshot conversationsQuery = await _conversationsCollection
        .where('userIds', isEqualTo: userIds).limit(1)
        .get();
    return conversationsQuery.docs.first.id;
  }
}
