import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/services/like_services.dart';
import 'package:instagram/services/post_services.dart';

import '../models/comment.dart';
import '../models/post.dart';

class LikeViewModel extends ChangeNotifier {
  final LikeService _likeService = LikeService();
  final PostService _postService = PostService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _likedBy = [];
  bool _isLikeAnimating = false;

  bool get isLikeAnimating => _isLikeAnimating;

  set isLikeAnimating(bool value) {
    _isLikeAnimating = value;
  }

  final _likeController = StreamController<bool>();
  Stream<bool> get likeStream => _likeController.stream;

  List<String> get likeBy => _likedBy;

  Future<void> getLikedByList(String uid) async {
    _likedBy = await _likeService.getLikedByList(uid);
  }

  Future<bool> getIsLiked(String likeListId, String userId) async {
    return await _likeService.isLiked(likeListId, userId);
  }

  Future<void> like(String likesListId, String userId) async {
    _likeService.like(likesListId, userId);
    _isLikeAnimating = !_isLikeAnimating;
    notifyListeners();
  }

  Future<void> unlike(String likesListId, String userId) async {
    _likeService.unlike(likesListId, userId);
    _isLikeAnimating = !_isLikeAnimating;
    notifyListeners();
  }

  toggleLikeComment(Comment cmt) {
    if (cmt.isLiked) {
     unlike(
          cmt.likedListId, _auth.currentUser!.uid);
      cmt.likeCount--;
    } else {
      like(
          cmt.likedListId, _auth.currentUser!.uid);
      cmt.likeCount++;
    }

    _likeController.sink.add(!cmt.isLiked);
  }

  toggleLikePost(Post post) {
    if (!post.isLiked) {
      _likeService.like(
          post.likedListId, _auth.currentUser!.uid);
      post.likeCount++;
      post.isLiked = true;
    } else {
      _likeService.unlike(
        post.likedListId,
        _auth.currentUser!.uid,
      );
      post.likeCount--;
      post.isLiked = false;
    }
    _likeController.sink.add(post.isLiked);
  }

}