import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/interface/message_interface.dart';
import 'package:instagram/models/chat_user.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/models/message.dart';

class MessageServices implements IMessageService {
  final CollectionReference _conversationsCollection =
      FirebaseFirestore.instance.collection('conversations');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Stream<DocumentSnapshot> getConversationData(String conversationId) {
    return _conversationsCollection.doc(conversationId).snapshots();
  }

  @override
  Stream<List<Message>> getMessages(
      {required String conversationId,
      int pageSize = 10,
      DocumentSnapshot? lastDocument}) {
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
  Future<void> createConversation(List<ChatUser> users, String conversationId, String messageContent, DateTime messageTime) async {
    final conversationRef = _conversationsCollection.doc(conversationId).set({
      'users':
      FieldValue.arrayUnion(users.map((user) => user.toJson()).toList()),
      'uid': conversationId,
      'lastMessageContent': messageContent,
      'lastMessageTime': messageTime,
      'isSeen': false
    });

    //await conversationRef.update();

    for (var user in users) {
      await _usersCollection.doc(user.userId).update({
        "conversationsIds": FieldValue.arrayUnion([conversationId])
      });
    }
  }

  @override
  Future<void> sendTextMessage(
      {required String conversationId,
      required String senderId,
      required String messageContent,
      required DateTime timestamp}) async {
    try {
      final messageRef = _conversationsCollection
          .doc(conversationId)
          .collection('messages')
          .doc();

      // Tạo một message mới
      final message = Message(
          id: messageRef.id,
          senderId: senderId,
          type: 'text',
          content: messageContent,
          timestamp: timestamp,
          status: 'sent');

      // Thêm message vào mảng messages của document conversation
      await messageRef.set(message.toJson());
    } catch (error) {
      // Xử lý lỗi nếu có
      print('Error sending message: $error');
    }
  }

  @override
  Future<bool> isExistsConversation(List<String> userIds) async {
    userIds.sort(
      (a, b) => a.compareTo(b),
    );
    final String uid = userIds.join("_");
    final docRef = await _conversationsCollection.doc(uid).get();
    return docRef.exists;
  }

  @override
  Future<String> getConversationId(String userId1, String userId2) async {
    final List<String> userIds = [userId1, userId2]..sort();
    final QuerySnapshot conversationsQuery = await _conversationsCollection
        .where('userIds', isEqualTo: userIds)
        .limit(1)
        .get();
    return conversationsQuery.docs.first.id;
  }
}
