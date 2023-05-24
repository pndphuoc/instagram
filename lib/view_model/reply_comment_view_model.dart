import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/repository/comment_repository.dart';
import 'package:instagram/repository/like_repository.dart';

import '../models/comment.dart';

class ReplyCommentViewModel {
  String commentListId;
  String commentId;
  late String userId;
  ReplyCommentViewModel(this.commentListId, this.commentId) {
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  List<Comment> _replyComments = [];

  List<Comment> get replyComments => _replyComments;

  DocumentSnapshot? _lastDocument;

  bool _hasMoreToLoad = false;

  int _replyCount = 0;

  int _replyPageSize = 5;

  StreamController<int> replyCountController = StreamController<int>();

  final _replyCommentController = StreamController<List<Comment>>();
  Stream<List<Comment>> get replyCommentsStream =>
      _replyCommentController.stream;

  Future<void> getReplyComments({
    required String commentId,
    int pageSize = 5,
  }) async {
    try {
      final docs = await CommentRepository.getReplyComments(
          commentListId: commentListId,
          commentId: commentId,
          pageSize: pageSize,
          lastDocument: _lastDocument);

      if (docs.isEmpty) {
        return;
      }

      _lastDocument = docs.last;
      _hasMoreToLoad = docs.length == pageSize;

      final comments = await _getCommentListWithLikedCheck(docs);

      if (comments.length < _replyPageSize) {
        _hasMoreToLoad = false;
      }

      _replyCount = _replyCount - _replyPageSize;
      replyCountController.sink.add(_replyCount);
      _replyCommentController.sink.add(comments);
    } catch (e) {
      print('Error: $e');
    } finally {}
  }

  Future<String> addReplyComment(String commentId, Comment replyComment) async {
    String uid = await CommentRepository.addReplyComment(
        commentListId, commentId, replyComment);

    replyComment =
    await CommentRepository.getReplyComment(commentListId, commentId, uid);

    _replyCommentController.sink.add([replyComment]);

    return uid;
  }

  Future<List<Comment>> _getCommentListWithLikedCheck(
      List<DocumentSnapshot<Object?>> docs) async {
    return Future.wait(
      docs.map(
            (data) async {
          final comment = Comment.fromJson(data.data() as Map<String, dynamic>);
          comment.isLiked =
          await LikeRepository.isLiked(comment.likedListId, userId);
          return comment;
        },
      ),
    );
  }

  void hideAllReplyComments(int replyCount) {
    _replyCount = replyCount;
    _lastDocument = null;

    _replyCommentController.sink.add([]);
    replyCountController.sink.add(_replyCount);
  }
}