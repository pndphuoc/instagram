import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/services/comment_services.dart';
import 'package:instagram/services/like_services.dart';
import 'package:instagram/services/post_services.dart';

class CommentViewModel extends ChangeNotifier {
  final CommentServices _commentServices = CommentServices();
  final PostService _postService = PostService();
  final LikeService _likeService = LikeService();

  final _commentController = StreamController<List<Comment>>();
  final StreamController<List<Comment>> _replyCommentController =
      StreamController<List<Comment>>();

  Stream<List<Comment>> get commentsStream => _commentController.stream;

  Stream<List<Comment>> get replyCommentsStream =>
      _replyCommentController.stream;

  bool _hasMoreToLoad = false;
  bool _isPostReplyComment = false;
  int _replyCount = 0;
  bool _hasMoreReplyCount = true;

  bool get hasMoreReplyCount => _hasMoreReplyCount;

  set hasMoreReplyCount(bool value) {
    _hasMoreReplyCount = value;
  }

  int _replyPageSize = 5;

  StreamController<int> replyCountController = StreamController<int>();

  int get replyPageSize => _replyPageSize;

  int get replyCount => _replyCount;

  set replyCount(int value) {
    _replyCount = value;
  }

  String? _commentRepliedId;

  final StreamController<String> _usernameOfCommentReplied =
      StreamController<String>();

  StreamController<String> get usernameOfCommentReplied =>
      _usernameOfCommentReplied;

  String get commentRepliedId => _commentRepliedId ?? "";

  set commentRepliedId(String value) {
    _commentRepliedId = value;
  }

  bool get isPostReplyComment => _isPostReplyComment;

  set isPostReplyComment(bool value) {
    _isPostReplyComment = value;
  }

  List<Comment> _comments = [];

  List<Comment> get comments => _comments;

  List<Comment> _replyComments = [];

  List<Comment> get replyComments => _replyComments;

  set replyComments(List<Comment> value) {
    _replyComments = value;
  }

  bool get hasMoreToLoad => _hasMoreToLoad;

  set hasMoreToLoad(bool value) {
    _hasMoreToLoad = value;
  }

  DocumentSnapshot? _lastDocument;

  Future<String> addComment(String commentListId, Comment comment) async {
    String uid = await _commentServices.addComment(commentListId, comment);
    //await _postService.addComment(postId);

    comment = await _commentServices.getComment(commentListId, uid);

    _commentController.sink.add([]);

    return uid;
  }

  Future<String> addReplyComment(
      String commentListId, String commentId, Comment replyComment) async {
    String uid = await _commentServices.addReplyComment(
        commentListId, commentId, replyComment);

    replyComment =
        await _commentServices.getReplyComment(commentListId, commentId, uid);

    _replyCommentController.sink.add([replyComment]);

    return uid;
  }

  Future<void> getComments({
    required String commentListId,
    required userId,
    int pageSize = 10,
  }) async {
    try {
      final docs = await _commentServices.getComments(
        commentListId: commentListId,
        pageSize: pageSize,
      );

      if (docs.isEmpty) {
        return;
      }

      _lastDocument = docs.last;

      if (docs.length < pageSize) {
        _hasMoreToLoad = false;
      } else {
        _hasMoreToLoad = true;
      }

      final comments = await Future.wait(
        docs.map(
          (data) async {
            final comment =
                Comment.fromJson(data.data() as Map<String, dynamic>);
            comment.isLiked =
                await _likeService.isLiked(comment.likedListId, userId);
            return comment;
          },
        ),
      );

      _commentController.sink.add(comments);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getMoreComments({
    required String commentListId,
    required String likeListId,
    required String userId,
    int pageSize = 10,
  }) async {
    if (!_hasMoreToLoad) {
      return;
    }

    final docs = await _commentServices.getMoreComments(
      commentListId: commentListId,
      lastDocument: _lastDocument!,
      pageSize: pageSize,
    );
    if (docs.isEmpty) {
      _hasMoreToLoad = false;
      _commentController.sink.add([]);
      notifyListeners();
      return;
    }
    _lastDocument = docs.last;

    _hasMoreToLoad = docs.length == pageSize;

    final comments = await Future.wait(docs.map((doc) async {
      final comment = Comment.fromJson(doc.data() as Map<String, dynamic>);
      comment.isLiked = await _likeService.isLiked(comment.likedListId, userId);
      return comment;
    }));

    _commentController.sink.add(comments);
    notifyListeners();
  }

  void hideAllReplyComments(int replyCount) {
    _replyCount = replyCount;
    _lastDocument = null;
    _replyCommentController.sink.add([]);
    _replyComments = [];
    replyCountController.sink.add(_replyCount);
  }

  Future<void> getReplyComments({
    required String commentListId,
    required String commentId,
    required userId,
    int pageSize = 5,
  }) async {
    try {
      final docs = await _commentServices.getReplyComments(
          commentListId: commentListId,
          commentId: commentId,
          pageSize: pageSize,
          lastDocument: _lastDocument);

      if (docs.isEmpty) {
        return;
      }

      _lastDocument = docs.last;
      _hasMoreToLoad = docs.length == pageSize;

      final comments = await _getCommentListWithLikedCheck(docs, userId);

      if (comments.length < _replyPageSize) {
        _hasMoreToLoad = false;
      }

      _replyCount = _replyCount - _replyPageSize;
      replyCountController.sink.add(_replyCount);

      _replyComments.addAll(comments);
      _replyCommentController.sink.add(_replyComments);
    } catch (e) {
      print('Error: $e');
    } finally {}
  }

  Future<List<Comment>> _getCommentListWithLikedCheck(
      List<DocumentSnapshot<Object?>> docs, String userId) async {
    return Future.wait(
      docs.map(
        (data) async {
          final comment = Comment.fromJson(data.data() as Map<String, dynamic>);
          comment.isLiked =
              await _likeService.isLiked(comment.likedListId, userId);
          return comment;
        },
      ),
    );
  }

  Future<void> likeComment(String commentListId, String commentId) async {
    await _commentServices.likeComment(commentListId, commentId);
  }

  Future<void> unlikeComment(String commentListId, String commentId) async {
    await _commentServices.unlikeComment(commentListId, commentId);
  }

  Future<bool> deleteComment(
      String commentListId, String commentId, String postId) async {
    try {
      await _commentServices.deleteComment(commentListId, commentId);
      await _postService.deleteComment(postId);
      return true;
    } catch (e) {
      return false;
    }
  }



  @override
  void dispose() {
    super.dispose();
    _commentController.close();
    _replyCommentController.close();
  }
}
