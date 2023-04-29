import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/interface/conversation_interface.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/models/user_summary_information.dart';

class ConversationService implements IConversationService {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');
  final CollectionReference _conversationsCollection =
  FirebaseFirestore.instance.collection('conversations');

  @override
  Stream<DocumentSnapshot> getConversationData(
      {required String conversationId}) {
    return _conversationsCollection.doc(conversationId).snapshots();
  }

  @override
  Stream<List<String>> getConversationIds({required String userId,
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
  Future<void> createConversation({required List<UserSummaryInformation> users,
    required String conversationId,
    required String messageContent,
    required DateTime messageTime}) async {
    await _conversationsCollection.doc(conversationId).set({
      'users':
      FieldValue.arrayUnion(users.map((user) => user.toJson()).toList()),
      'userIds': FieldValue.arrayUnion(users.map((user) => user.userId).toList()),
      'uid': conversationId,
      'lastMessageContent': messageContent,
      'lastMessageTime': messageTime,
    });

    //await conversationRef.update();

    for (var user in users) {
      await _usersCollection
          .doc(user.userId)
          .collection('conversations')
          .doc(conversationId)
          .set({
        "conversationId": FieldValue.arrayUnion([conversationId]),
        "lastMessageTime": messageTime,
        "isTurnOffNotification": false
      });
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
  Future<void> updateLastMessageOfConversation({required String conversationId,
    required String content,
    required DateTime timestamp,
    required String type}) async {
    await _conversationsCollection.doc(conversationId).update({
      'lastMessageContent': content,
      'lastMessageTime': timestamp,
      'isSeen': false
    });
    List<String> userIds = conversationId.split("_");
    for (String userId in userIds) {
      await _usersCollection
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .update({'lastMessageTime': timestamp});
    }
  }

  @override
  Future<bool> isSeenStatus(
      {required String conversationId, required String userId}) async {
    final snapshots = await _conversationsCollection
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('status', isEqualTo: 'sent')
        .get();
    return snapshots.size == 0;
  }

  Stream<bool> seenStatusStream(
      {required String conversationId, required String userId}) {
    final snapshots = _conversationsCollection
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId).snapshots();

    return snapshots.map((querySnapshot) {
      final allSeen = querySnapshot.docs.every((doc) =>
      doc['status'] == 'seen');
      return allSeen;
    });
  }

  @override
  Future<void> updateUserInformation(
      {required String userId, required UserSummaryInformation oldData, required UserSummaryInformation newData}) async {
    try {
      final conversations = await _conversationsCollection.where(
          'users', arrayContains: oldData.toJson()).get();

      final batch = FirebaseFirestore.instance.batch();
      for (final conversation in conversations.docs) {
        final users = List<Map<String, dynamic>>.from((conversation.data() as Map<String, dynamic>)['users']);
        final updatedUsers = users.map((user) {
          if (user['userId'] == userId) {
            return newData.toJson();
          } else {
            return user;
          }
        }).toList();

        final conversationRef =
        _conversationsCollection.doc(conversation.id);
        batch.update(conversationRef, {'users': updatedUsers});
      }

      await batch.commit();

    } catch (e) {
      rethrow;
    }
  }
}
