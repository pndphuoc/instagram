

import 'package:instagram/models/comment.dart';

import '../models/post.dart';

abstract class IPostServices {
  Future<List<Post>> getPosts();

  Future<Post> getPost(String postId);

  Future<String> addPost(Post post);

  Future<void> updatePost(Post post);

  Future<void> deletePost(String postId);

  Future<void> likePost(String postId, String userId);

  Future<void> unlikePost(String postId, String userId);

  Future<String> addComment(String postId, Comment cmt);

  Future<bool> deleteComment(String postId, String commentId);

  Future<bool> updateComment(String postId, Comment cmt);

  Future<void> getComments({int page = 0, int size = 20});
}
