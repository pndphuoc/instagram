import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/interface/relationship_interface.dart';

class RelationshipService implements IRelationshipService {
  final CollectionReference _usersRef = FirebaseFirestore.instance.collection('users');
  final CollectionReference _followerListRef = FirebaseFirestore.instance.collection('followerList');
  final CollectionReference _followingListRef = FirebaseFirestore.instance.collection('followingList');
  final CollectionReference _blockedListRef = FirebaseFirestore.instance.collection('blockedList');


  @override
  Future<void> blockUser(String userId, String userBeBlockedId) {
    // TODO: implement blockUser
    throw UnimplementedError();
  }

  @override
  Future<void> followUser(String currentUserId, String currentUserFollowingListId, String targetUserId, String targetUserFollowerListId) async {
    await _followingListRef.doc(currentUserFollowingListId).update({'followingIds': FieldValue.arrayUnion([targetUserId])});
    await _followerListRef.doc(targetUserFollowerListId).update({'followerIds': FieldValue.arrayUnion([currentUserId])});
    await _usersRef.doc(currentUserId).update({'followingCount': FieldValue.increment(1)});
    await _usersRef.doc(targetUserId).update({'followerCount': FieldValue.increment(1)});
  }

  @override
  Future<void> unblockUser(String userId, String userBeUnblockedId) {
    // TODO: implement unblockUser
    throw UnimplementedError();
  }

  @override
  Future<void> unfollowUser(String currentUserId, String currentUserFollowingListId, String targetUserId, String targetUserFollowerListId) async {
    await _followingListRef.doc(currentUserFollowingListId).update({'followingIds': FieldValue.arrayRemove([targetUserId])});
    await _followerListRef.doc(targetUserFollowerListId).update({'followerIds': FieldValue.arrayRemove([currentUserId])});
    await _usersRef.doc(currentUserId).update({'followingCount': FieldValue.increment(-1)});
    await _usersRef.doc(targetUserId).update({'followerCount': FieldValue.increment(-1)});
  }

  @override
  Future<bool> isFollowing(String userId, String targetUserId) async {
    /*final followerListSnapshot = await _followerListRef.doc(targetUserId).get();
    final followerList = List<String>.from((followerListSnapshot.data() as Map<String, dynamic>)['followerIds'] as List);
    return followerList.contains(userId);*/

    QuerySnapshot snapshot = await _followerListRef.where('userId', isEqualTo: targetUserId).where('followerIds', arrayContains: userId).limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<List<String>> getFollowingIds(String followingListId) async {
    final doc = await _followingListRef.doc(followingListId).get();
    final data = doc.data() as Map<String, dynamic>?;
    final followingIds = data?['followingIds'] as List?;
    return followingIds?.cast<String>() ?? [];
  }


}