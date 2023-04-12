import 'package:flutter/cupertino.dart';
import 'package:instagram/services/like_services.dart';
import 'package:instagram/services/post_services.dart';

class LikeViewModel extends ChangeNotifier {
  final LikeService _likeService = LikeService();
  final PostService _postService = PostService();

  List<String> _likedBy = [];
  bool _isLiked = false;
  bool _isLikeAnimating = false;

  bool get isLikeAnimating => _isLikeAnimating;

  set isLikeAnimating(bool value) {
    _isLikeAnimating = value;
  }

  set isLiked(bool value) {
    _isLiked = value;
  }

  bool get isLiked => _isLiked;

  List<String> get likeBy => _likedBy;

  Future<void> getLikedByList(String uid) async {
    _likedBy = await _likeService.getLikedByList(uid);
  }

  Future<void> getIsLiked(String likeListId, String userId) async {
    _isLiked = await _likeService.isLiked(likeListId, userId);
    notifyListeners();
  }

  Future<void> like(String likesListId, String userId) async {
    _likeService.like(likesListId, userId);
    _isLiked = true;
    _isLikeAnimating = !_isLikeAnimating;
    notifyListeners();
  }

  Future<void> unlike(String likesListId, String userId) async {
    _likeService.unlike(likesListId, userId);
    _isLiked = false;
    _isLikeAnimating = !_isLikeAnimating;
    notifyListeners();
  }
}