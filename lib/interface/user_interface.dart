import '../models/post.dart';
import '../models/user.dart';

abstract class IUserService {
  Future<User?> getUserDetails(String userId);

  Future<bool> updatePostInformation(String postId);

}