abstract class IRelationshipService {
  Future<void> followUser(String userId, String userBeFollowedId);

  Future<void> unfollowUser(String userId, String userBeUnfollowedId);

  Future<void> blockUser(String userId, String userBeBlockedId);

  Future<void> unblockUser(String userId, String userBeUnblockedId);
}