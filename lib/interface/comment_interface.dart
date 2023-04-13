import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment.dart';

abstract class ICommentService {
  Future<String> addComment(String commentListId, Comment comment);

  Future<void> updateComment(String commentListId, Comment comment);

  Future<void> deleteComment(String commentListId, String commentId);

  Future<void> likeComment(String commentListId, String commentId);

  Future<void> unlikeComment(String commentListId, String commentId);

  Future<Comment> getComment(String commentListId, String uid);

  Future<List<DocumentSnapshot>> getComments(
      {required String commentListId, int pageSize = 10});

  Future<List<DocumentSnapshot>> getMoreComments({
    required String commentListId,
    required DocumentSnapshot lastDocument,
    int pageSize = 10,
  });
}
