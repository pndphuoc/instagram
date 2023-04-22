import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:instagram/interface/user_interface.dart';
import 'package:instagram/models/user.dart' as model;

import '../ultis/ultils.dart';

class UserService implements IUserService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _followerListCollection =
      FirebaseFirestore.instance.collection('followerList');
  final CollectionReference _followingListCollection =
      FirebaseFirestore.instance.collection('followingList');
  final CollectionReference _blockedListCollection =
      FirebaseFirestore.instance.collection('blockedList');
  final CollectionReference _usersListCollection =
      FirebaseFirestore.instance.collection('users');
  final _userStatusDatabaseRef =
      FirebaseDatabase.instance.ref().child('userStatus');

  @override
  Future<model.User> getUserDetails(String userId) async {
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

  @override
  Stream<String> getOnlineStatus(String userId) {
    return _userStatusDatabaseRef
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

  @override
  Future<bool> updatePostInformation(String postId) async {
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

  @override
  Future<String> addNewUser(
      {required String email,
      required String username,
      required String uid,
      String displayName = '',
      String bio = '',
      String avatarUrl = ''}) async {
    try {
      DocumentReference followerListRef = _followerListCollection.doc();
      followerListRef.set({"followerIds": [], "userId": uid});

      DocumentReference followingListRef = _followingListCollection.doc();
      followingListRef.set({"followingIds": [], "userId": uid});

      DocumentReference blockedListRef = _blockedListCollection.doc();
      blockedListRef.set({"blockedIds": [], "userId": uid});

      DocumentReference newUserRef = _usersListCollection.doc(uid);

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
      );
      await newUserRef.set(user.toJson());
      return newUserRef.id;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> setOnlineStatus(bool isOnline) async {
    if (isOnline) {
      _userStatusDatabaseRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .set({'online': isOnline, 'lastOnline': ServerValue.timestamp});
    }
  }

  @override
  Stream<int> getLastOnlineTime(String userId) {
    return _userStatusDatabaseRef
        .child("$userId/lastOnline")
        .onValue
        .map((event) => event.snapshot.value as int);
  }
}
