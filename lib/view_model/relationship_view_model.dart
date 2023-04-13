import 'package:flutter/cupertino.dart';
import 'package:instagram/services/relationship_services.dart';

class RelationshipViewModel extends ChangeNotifier {
  final RelationshipService _relationshipService = RelationshipService();

  Future<void> follow(String currentUserId, String currentUserFollowingListId, String targetUserId, String targetUserFollowerListId) async {
    await _relationshipService.followUser(currentUserId, currentUserFollowingListId, targetUserId, targetUserFollowerListId);
  }

  Future<void> unfollow(String currentUserId, String currentUserFollowingListId, String targetUserId, String targetUserFollowerListId) async {
    await _relationshipService.unfollowUser(currentUserId, currentUserFollowingListId, targetUserId, targetUserFollowerListId);
  }

  Future<bool> isFollowing(String userId, String targetUserId) async {
    return await _relationshipService.isFollowing(userId, targetUserId);
  }

  Future<List<String>> getFollowingIds(String followingListId) async {
    return await _relationshipService.getFollowingIds(followingListId);
  }
}