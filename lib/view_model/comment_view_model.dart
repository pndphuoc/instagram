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

  Stream<List<Comment>> get commentsStream => _commentController.stream;


  bool _hasMoreToLoad = false;
  bool _isLoading = false;
  List<Comment> _comments = [];

  List<Comment> get comments => _comments;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
  }

  bool get hasMoreToLoad => _hasMoreToLoad;

  set hasMoreToLoad(bool value) {
    _hasMoreToLoad = value;
  }

  DocumentSnapshot? _lastDocument;

  Future<String> addComment(
      String postId, String commentListId, Comment comment) async {
    String uid = await _commentServices.addComment(commentListId, comment);
    //await _postService.addComment(postId);

    comment = await _commentServices.getComment(commentListId, uid);

    _commentController.sink.add([]);

    return uid;
  }

  Future<void> getComments({
    required String commentListId,
    required userId,
    int pageSize = 10,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final docs = await _commentServices.getComments(
        commentListId: commentListId,
        pageSize: pageSize,
      );

      if (docs.isEmpty) {
        isLoading = false;
        notifyListeners();
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
    } finally {
      isLoading = false;
      notifyListeners();
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


  Future<void> likeComment(String commentListId, String commentId) async {
    await _commentServices.likeComment(commentListId, commentId);
  }

  Future<void> unlikeComment(String commentListId, String commentId) async {
    await _commentServices.unlikeComment(commentListId, commentId);
  }

  Future<bool> deleteComment(String commentListId, String commentId, String postId) async {
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
  }
}
