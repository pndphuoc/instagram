import '../models/post.dart';
import '../models/user.dart';

abstract class IUserService {
  Future<User?> getUserDetails(String userId);

  Future<bool> updatePostInformation(String postId);

  Future<String> addNewUser({
    required String uid,
    required String email,
    required String username,
    String displayName = '',
    String bio = '',
    String avatarUrl = '',
  });

  Future<void> setOnlineStatus(bool isOnline);
}