import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:instagram/models/user.dart' as model;

import '../ultis/ultils.dart';

class UserRepository {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<model.User> getUserDetails(String userId) async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return model.User.fromJson(snap.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  static Stream<String> getOnlineStatus(String userId) {
    return FirebaseDatabase.instance.ref().child('userStatus')
        .child("$userId/lastOnline")
        .onValue
        .map((event) => event.snapshot.value as int)
        .transform(
            StreamTransformer.fromHandlers(handleData: (snapshot, sink) async {
      if (snapshot.isNaN) return;

      final lastOnline = DateTime.fromMillisecondsSinceEpoch(snapshot);
      final difference = DateTime.now().difference(lastOnline);
      String status = 'Online';
      if (difference.inMinutes < 2) {
        status = "Online";
      } else {
        status = "Online ${getElapsedTime(lastOnline)} ago";
      }
      sink.add(status);
    }));
  }

  static Future<bool> updatePostInformation(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({
        'postsCount': FieldValue.increment(1),
        'postIds': FieldValue.arrayUnion([postId])
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> addNewUser(
      {required String email,
      required String username,
      required String uid,
      String displayName = '',
      String bio = '',
      String avatarUrl = ''}) async {
    try {

      DocumentReference followerListRef = FirebaseFirestore.instance.collection('followerList').doc();
      followerListRef.set({"followerIds": [], "userId": uid});

      DocumentReference followingListRef = FirebaseFirestore.instance.collection('followingList').doc();
      followingListRef.set({"followingIds": [], "userId": uid});

      DocumentReference blockedListRef = FirebaseFirestore.instance.collection('blockedList').doc();
      blockedListRef.set({"blockedIds": [], "userId": uid});

      DocumentReference newUserRef = FirebaseFirestore.instance.collection('users').doc(uid);

      final user = model.User(
        uid: uid,
        username: username,
        displayName: displayName,
        email: email,
        bio: bio,
        followerListId: followerListRef.id,
        followerCount: 0,
        followingListId: followingListRef.id,
        followingCount: 0,
        savedPostIds: [],
        blockedListId: blockedListRef.id,
        avatarUrl: avatarUrl,
        postIds: [],
        createdAt: DateTime.now(),
        fcmTokens: []
      );
      await newUserRef.set(user.toJson());
      return newUserRef.id;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> setOnlineStatus({required String userId, required bool isOnline}) async {
    if (isOnline) {
      FirebaseDatabase.instance.ref().child('userStatus')
          .child(userId)
          .set({'online': isOnline, 'lastOnline': ServerValue.timestamp});
    }
  }

  static Stream<int> getLastOnlineTime(String userId) {
    return FirebaseDatabase.instance.ref().child('userStatus')
        .child("$userId/lastOnline")
        .onValue
        .map((event) => event.snapshot.value as int);
  }

  static Stream<bool> hasUnReadMessage(String conversationIds) {
    // TODO: implement hasUnReadMessage
    throw UnimplementedError();
  }

 static Future<void> updateUserInformationTransaction(
      {required String userId,
        required String newAvatarUrl,
        required String newUsername,
        required String newDisplayName,
        required String newBio,
        dynamic transaction}) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final data = {
        'avatarUrl': newAvatarUrl,
        'username': newUsername,
        'displayName': newDisplayName,
        'bio': newBio,
      };
      if (transaction != null) {
        transaction.update(userRef, data);
      } else {
        await userRef.update(data);
      }
      print('User information updated successfully');
    } catch (error) {
      print('Error updating user information: $error');
    }
  }

  static Future<List<String>> getFcmTokens(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return List<String>.from((doc.data() as Map<String, dynamic>)['fcmTokens']).toList();
  }

}
