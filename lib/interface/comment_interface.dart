import '../models/comment.dart';

abstract class ICommentService {
  Future<String> addComment(String commentListId, Comment comment);

  Future<void> updateComment(String commentListId, Comment comment);

  Future<void> deleteComment(String commentListId, String commentId);

  Future<Comment> getComment(String commentListId, String uid);

  Future<List<Comment>> getComments({required String commentListId, int page = 0, int pageSize = 10});
}