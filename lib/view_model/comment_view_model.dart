import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/services/comment_services.dart';
import 'package:instagram/services/like_services.dart';
import 'package:instagram/services/post_services.dart';

import '../models/user_summary_information.dart';

class CommentViewModel extends ChangeNotifier {
  final String commentListId;
  final String commentId;
  late String userId;
  CommentViewModel(this.commentListId, this.commentId) {
    userId = FirebaseAuth.instance.currentUser!.uid;
  }
  final CommentServices _commentServices = CommentServices();
  final PostService _postService = PostService();
  final LikeService _likeService = LikeService();

  final _commentController = StreamController<List<Comment>>();
  final _replyCommentController = StreamController<List<Comment>>();
  final _selectingCommentController = StreamController<bool>();

  Stream<bool> get selectingCommentStream => _selectingCommentController.stream;

  Stream<List<Comment>> get commentsStream => _commentController.stream;

  Stream<List<Comment>> get replyCommentsStream =>
      _replyCommentController.stream;

  bool _hasMoreToLoad = false;

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

  List<Comment> _comments = [];

  List<Comment> get comments => _comments;

  bool get hasMoreToLoad => _hasMoreToLoad;

  set hasMoreToLoad(bool value) {
    _hasMoreToLoad = value;
  }

  DocumentSnapshot? _lastDocument;

  Future<String> addComment(Comment comment) async {
    String uid = await _commentServices.addComment(commentListId, comment);
    //await _postService.addComment(postId);

    comment = await _commentServices.getComment(commentListId, uid);
    _comments.insert(0, comment);
    _commentController.sink.add([]);

    return uid;
  }

  Future<String> addReplyComment(Comment replyComment) async {
    String uid = await _commentServices.addReplyComment(
        commentListId, commentId, replyComment);

    replyComment =
        await _commentServices.getReplyComment(commentListId, commentId, uid);

    _replyCommentController.sink.add([replyComment]);

    return uid;
  }

  Future<void> getComments({
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
      _comments.addAll(comments);

      _commentController.sink.add([]);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getMoreComments({
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
    _comments.addAll(comments);

    _commentController.sink.add([]);
    notifyListeners();
  }

  void hideAllReplyComments(int replyCount) {
    _replyCount = replyCount;
    _lastDocument = null;

    _replyCommentController.sink.add([]);
    replyCountController.sink.add(_replyCount);
  }

  Future<void> getReplyComments({
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

  Future<List<Comment>> _getCommentListWithLikedCheck(
      List<DocumentSnapshot<Object?>> docs) async {
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
      _comments.removeWhere((element) => element.uid == commentId);
      _commentController.sink.add([]);
      return true;
    } catch (e) {
      return false;
    }
  }

  final TextEditingController _commentTextField = TextEditingController();

  TextEditingController get commentTextField => _commentTextField;

  final FocusNode commentFocusNode = FocusNode();

  String _commentRepliedId = '';

  String get commentRepliedId => _commentRepliedId;

  set commentRepliedId(String value) {
    _commentRepliedId = value;
  }

  bool _isReplyingComment = false;

  bool get isReplyingComment => _isReplyingComment;

  set isReplyingComment(bool value) {
    _isReplyingComment = value;
  }

  String _usernameOfCommentIsBeingReplied = '';

  String get usernameOfCommentIsBeingReplied =>
      _usernameOfCommentIsBeingReplied;

  set usernameOfCommentIsBeingReplied(String value) {
    _usernameOfCommentIsBeingReplied = value;
  }

  final _usernameIsBeingReplied = StreamController<String>();

  Stream<String> get usernameIsBeingRepliedStream =>
      _usernameIsBeingReplied.stream;

  List<Comment> replyComments = [];

  void onReplyButtonTap(
      String username, String commentId, List<Comment> displayedReplyComments) {
    replyComments = displayedReplyComments;
    _isReplyingComment = true;
    if (!commentFocusNode.hasFocus) {
      commentFocusNode.requestFocus();
    }
    _commentTextField.text = "@$username ";
    usernameOfCommentIsBeingReplied = username;
    _commentTextField.selection = TextSelection.fromPosition(
        TextPosition(offset: _commentTextField.text.length));
    _commentRepliedId = commentId;
    _usernameIsBeingReplied.sink.add(username);
  }

  void onCancelReplyCommentTap() {
    _commentRepliedId = '';
    _isReplyingComment = false;
    _commentTextField.text = '';
    _usernameIsBeingReplied.sink.add('');
  }

  onPostButtonPressed(
      String commentListId,
      UserSummaryInformation currentUser,
      ScrollController scrollController,
      List<Comment> displayedComments) async {
    if (_commentTextField.text.isEmpty) {
      return;
    }

    final comment = Comment(
      uid: '',
      authorId: currentUser.userId,
      username: currentUser.username,
      avatarUrl: currentUser.avatarUrl,
      content: _commentTextField.text,
      likedListId: '',
      likeCount: 0,
      replyCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    commentFocusNode.unfocus();
    _commentTextField.clear();

    if (!_isReplyingComment) {
      displayedComments.insert(0, comment);
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
      await addComment(comment);
    } else {
      replyComments.insert(0, comment);
      await addReplyComment(comment);
    }

    onCancelReplyCommentTap();
  }

  void onCommentLongPress(Comment cmt) {
    _selectingCommentController.sink.add(true);
  }

  void cancelCommentLongPress() {
    _selectingCommentController.sink.add(false);
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.close();
    _replyCommentController.close();
    _selectingCommentController.close();
  }
}
