import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageDetailsRepository {
  static final _conversationsCollection = FirebaseFirestore.instance
      .collection('conversations');

  static Stream<String> getMessageStatus({required String conversationId, required String messageId}) {
    final messageDocument = _conversationsCollection
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    return messageDocument.snapshots().map((snapshot) => snapshot.get('status'));
  }

  static Future<void> updateStatus({required String conversationId, required String senderId}) async {
    final messageCollection = _conversationsCollection
        .doc(conversationId)
        .collection('messages');

    final snapshot = await messageCollection
        .where('status', isEqualTo: 'sent')
        .where('senderId', isEqualTo: senderId)
        .get();

    final batchUpdate = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batchUpdate.update(doc.reference, {'status': 'seen'});
    }

    await batchUpdate.commit();
  }
  
}