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
  Stream<DocumentSnapshot> getStreamConversationData(String conversationId) {
    return _conversationsCollection.doc(conversationId).snapshots();
  }

  @override
  Stream<List<Message>> getStreamMessages(
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
  Future<void> createConversation(List<ChatUser> users, String conversationId,
      String messageContent, DateTime messageTime) async {
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
      await _usersCollection
          .doc(user.userId)
          .collection('conversations')
          .doc(conversationId)
          .set({
        "conversationId": FieldValue.arrayUnion([conversationId]),
        "lastMessageTime": messageTime
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
  Stream<List<String>> getConversationIds(
      {required String userId,
      int pageSize = 20,
      DocumentSnapshot<Object?>? lastDocument}) {
    Query<Map<String, dynamic>> query = _usersCollection
        .doc(userId)
        .collection('conversations')
        .orderBy('lastMessageTime', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map((snapshot) {
      List<String> ids = [];

      for (DocumentSnapshot<Object?> document in snapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String id = data['conversationId'][0];
        ids.add(id);
      }
      return ids;
    });
  }

  @override
  Future<void> updateLastMessageOfConversation(
      {required String conversationId,
      required String content,
      required DateTime timestamp,
      required String type}) async {
    await _conversationsCollection.doc(conversationId).update({
      'lastMessageContent': content,
      'lastMessageTime': timestamp,
      'isSeen': false
    });
    List<String> userIds = conversationId.split("_");
    for(String userId in userIds) {
      await _usersCollection
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .update({'lastMessageTime': timestamp});
    }
  }
}
