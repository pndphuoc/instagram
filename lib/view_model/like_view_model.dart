import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/repository/like_repository.dart';

import '../models/comment.dart';
import '../models/post.dart';

class LikeViewModel extends ChangeNotifier {
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
    _likedBy = await LikeRepository.getLikedByList(uid);
  }

  Future<bool> getIsLiked(String likeListId, String userId) async {
    return await LikeRepository.isLiked(likeListId, userId);
  }

  Future<void> like(String likesListId, String userId) async {
    LikeRepository.like(likesListId, userId);
    _isLikeAnimating = !_isLikeAnimating;
    notifyListeners();
  }

  Future<void> unlike(String likesListId, String userId) async {
    LikeRepository.unlike(likesListId, userId);
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

  Future<bool> toggleLikePost(Post post) async {
    if (!post.isLiked) {
      await LikeRepository.like(
          post.likedListId, _auth.currentUser!.uid);
      post.likeCount++;
      post.isLiked = true;
    } else {
      await LikeRepository.unlike(
        post.likedListId,
        _auth.currentUser!.uid,
      );
      post.likeCount--;
      post.isLiked = false;
    }
    _likeController.sink.add(post.isLiked);
    return post.isLiked;
  }

}