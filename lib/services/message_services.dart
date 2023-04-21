import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as realtime;
import 'package:instagram/interface/message_interface.dart';
import 'package:instagram/models/message.dart';

class MessageServices implements IMessageService {
  final CollectionReference _conversationsCollection =
      FirebaseFirestore.instance.collection('conversations');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final _userStatusDatabaseRef = realtime.FirebaseDatabase.instance.ref().child('userStatus');

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
  Future<void> sendImageMessage({required String conversationId, required String senderId, required String messageContent, required DateTime timestamp}) async {
    try {
      final messageRef = _conversationsCollection
          .doc(conversationId)
          .collection('messages')
          .doc();

      // Tạo một message mới
      final message = Message(
          id: messageRef.id,
          senderId: senderId,
          type: 'image',
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
  Future<void> sendVideoMessage({required String conversationId, required String senderId, required String messageContent, required DateTime timestamp}) async {
    try {
      final messageRef = _conversationsCollection
          .doc(conversationId)
          .collection('messages')
          .doc();

      // Tạo một message mới
      final message = Message(
          id: messageRef.id,
          senderId: senderId,
          type: 'video',
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


}
