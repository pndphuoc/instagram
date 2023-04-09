import 'package:flutter/cupertino.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/services/comment_services.dart';
import 'package:instagram/services/post_services.dart';

class CommentViewModel extends ChangeNotifier {
  final CommentServices _commentServices = CommentServices();
  final PostService _postService = PostService();

  Future<String> addComment(String postId, String commentListId, Comment comment) async {
    String uid = await _commentServices.addComment(commentListId, comment);
    await _postService.addComment(postId);
    return uid;
  }

  Future<List<Comment>> getComments({required String commentListId, int page = 0, int pageSize = 10}) async {
    return await _commentServices.getComments(commentListId: commentListId, page: page, pageSize: pageSize);
  }
}