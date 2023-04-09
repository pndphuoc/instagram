abstract class ILikeService {
  Future<void> like(String uid, String userId);
  Future<void> unlike(String uid, String userId);
  Future<bool> isLiked(String uid, String userId);
  Future<List<String>> getLikedByList(String uid);
}