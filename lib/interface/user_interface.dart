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

  Stream<int> getLastOnlineTime(String userId);

  Stream<String> getOnlineStatus(String userId);

  Stream<bool> hasUnReadMessage(String conversationIds);

  Future<void> updateUserInformationTransaction(
      {required String userId,
      required String newAvatarUrl,
      required String newUsername,
      required String newDisplayName,
      required String newBio,
      dynamic transaction});

  Future<List<String>> getFcmTokens(String userId);
}
