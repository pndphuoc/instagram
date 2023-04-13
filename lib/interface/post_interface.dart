

import 'package:instagram/models/comment.dart';

import '../models/post.dart';

abstract class IPostServices {
  Future<List<Post>> getPosts(List<String> followingIds);

  Future<List<Post>> getDiscoverPosts(List<String> followingIds);

  Future<Post> getPost(String postId);

  Future<String> addPost(Post post);

  Future<void> updatePost(Post post);

  Future<void> deletePost(String postId);

  Future<void> addComment(String postId);

  Future<void> deleteComment(String postId);

}
