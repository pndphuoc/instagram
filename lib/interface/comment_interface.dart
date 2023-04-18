import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment.dart';

abstract class ICommentService {
  Future<String> addComment(String commentListId, Comment comment);

  Future<String> addReplyComment(String commentListId, String mainCommentId, Comment replyComment);

  Future<void> updateComment(String commentListId, Comment comment);

  Future<void> updateReplyCount(String commentListId, String commentId, bool isIncrease);

  Future<void> deleteComment(String commentListId, String commentId);

  Future<void> likeComment(String commentListId, String commentId);

  Future<void> unlikeComment(String commentListId, String commentId);

  Future<Comment> getComment(String commentListId, String uid);

  Future<Comment> getReplyComment(String commentListId, String commentId, String replyCommentId);

  Future<List<DocumentSnapshot>> getComments(
      {required String commentListId, int pageSize = 10});

  Future<List<DocumentSnapshot>> getReplyComments({required String commentListId, required String commentId, int pageSize = 5});


  Future<List<DocumentSnapshot>> getMoreComments({
    required String commentListId,
    required DocumentSnapshot lastDocument,
    int pageSize = 10,
  });
}
