import 'package:flutter/cupertino.dart';
import 'package:instagram/services/like_services.dart';
import 'package:instagram/services/post_services.dart';

class LikeViewModel extends ChangeNotifier {
  final LikeService _likeService = LikeService();
  final PostService _postService = PostService();

  List<String> _likedBy = [];
  bool _isLikeAnimating = false;

  bool get isLikeAnimating => _isLikeAnimating;

  set isLikeAnimating(bool value) {
    _isLikeAnimating = value;
  }

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
}