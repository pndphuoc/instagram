import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:instagram/repository/relationship_repository.dart';

class RelationshipViewModel extends ChangeNotifier {
  List<String> _followerIds = [];

  List<String> get followerIds => _followerIds;

  List<String> _followingIds = [];

  set followerIds(List<String> value) {
    _followerIds = value;
  }

  List<String> get followingIds => _followingIds;

  final ScrollController _followerListController = ScrollController();
  ScrollController get followerListController => _followerListController;

  final ScrollController _followingListController = ScrollController();
  ScrollController get followingListController => _followingListController;

  final _rebuildController = StreamController<bool>.broadcast();

  Stream<bool> get rebuildStream => _rebuildController.stream;


  Future<void> follow(String currentUserId, String currentUserFollowingListId, String targetUserId, String targetUserFollowerListId) async {
    await RelationshipRepository.followUser(currentUserId, currentUserFollowingListId, targetUserId, targetUserFollowerListId);
  }

  Future<void> unfollow(String currentUserId, String currentUserFollowingListId, String targetUserId, String targetUserFollowerListId) async {
    await RelationshipRepository.unfollowUser(currentUserId, currentUserFollowingListId, targetUserId, targetUserFollowerListId);

    _rebuildController.sink.add(true);
  }

  static Future<bool> isFollowing(String userId, String targetUserId) async {
    return await RelationshipRepository.isFollowing(userId, targetUserId);
  }

  Future<List<String>> getFollowingIds(String followingListId) async {
    return await RelationshipRepository.getFollowingIds(followingListId);
  }

  Future<List<String>> getFollowerIds(String followerListId) async {
    return await RelationshipRepository.getFollowerIds(followerListId);
  }

  Future<void> getFollowerAndFollowingIds({required String followerListId, required String followingListId}) async {
    _followerIds = await getFollowerIds(followerListId);
    _followingIds = await getFollowingIds(followingListId);
  }

  @override
  void dispose() {
    _followerListController.dispose();
    _followingListController.dispose();
    _rebuildController.close();
    super.dispose();
  }

  set followingIds(List<String> value) {
    _followingIds = value;
  }
}