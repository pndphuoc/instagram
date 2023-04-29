import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as realtime;
import 'package:instagram/interface/message_interface.dart';
import 'package:instagram/models/message.dart';

class MessageServices implements IMessageService {
  final CollectionReference _conversationsCollection =
      FirebaseFirestore.instance.collection('conversations');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final _userStatusDatabaseRef =
      realtime.FirebaseDatabase.instance.ref().child('userStatus');
  final _lastSeenMessageDatabaseRef =
      realtime.FirebaseDatabase.instance.ref().child('lastSeenMessage');

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
  Stream<List<Message>?> getNewMessage({
    required String conversationId,
    required DateTime? lastMessageTimestamp,
  }) {
    CollectionReference messagesCollection =
    FirebaseFirestore.instance.collection('conversations').doc(conversationId).collection('messages');

    Query query = messagesCollection.orderBy('timestamp', descending: true);

    if (lastMessageTimestamp != null) {
      query = query.endBefore([lastMessageTimestamp]).limit(20);
    } else {
      query = query.limit(20);
    }

    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      List<Message> messages = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Message.fromJson(data);
      }).toList();
      return messages;
    });
  }


  Future<List<Message>> getOldMessages(
      {required String conversationId,
      required DateTime? lastMessageTimestamp,
      required limit}) async {
    Query query = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    if (lastMessageTimestamp != null) {
      query = query.startAfter([lastMessageTimestamp]);
    } else {
      query = query.limit(limit);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<Message> messages = querySnapshot.docs
        .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    if (messages.isNotEmpty) {
      lastMessageTimestamp = messages.last.timestamp!;
    }

    return messages;
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
  Future<void> sendImageMessage(
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
  Future<void> sendVideoMessage(
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

  @override
  Stream<bool> isTurnOffNotification({required String userId, required String conversationId}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .snapshots()
        .map((docSnapshot) => docSnapshot.get('isTurnOffNotification') ?? true);
  }

  @override
  Future<void> changeNotificationSetting({required String userId, required String conversationId, required isTurnOffNotification}) async {
    await _usersCollection.doc(userId).collection('conversations').doc(conversationId).update(
        {"isTurnOffNotification": isTurnOffNotification});
  }
}
