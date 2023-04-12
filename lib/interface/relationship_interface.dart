abstract class IRelationshipService {
  Future<void> followUser(String currentUserId, String currentUserFollowingListId, String targetUserId, String targetUserFollowerListId);

  Future<bool> isFollowing(String userId, String targetUserId);

  Future<void> unfollowUser(String currentUserId, String currentUserFollowingListId, String targetUserId, String targetUserFollowerListId);

  Future<void> blockUser(String userId, String userBeBlockedId);

  Future<void> unblockUser(String userId, String userBeUnblockedId);
}