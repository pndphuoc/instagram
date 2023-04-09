import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/post.dart';
import '../models/user.dart' as model;
import '../services/post_services.dart';
import '../services/user_services.dart';

class CurrentUserViewModel extends ChangeNotifier {
  final UserService _userServices = UserService();
  final PostService _postService = PostService();

  model.User? _user;
  bool _isNewUser = false;
  List<Post> _ownPosts = [];
  bool _hasMorePosts = true;
  int _page = 0;
  int _sizePage = 12;

  model.User? get user => _user;

  bool get isNewUser => _isNewUser;

  bool get hasMorePosts => _hasMorePosts;

  List<Post> get ownPosts => _ownPosts;

  Future<void> getCurrentUserDetails() async {
    _user = await _userServices.getUserDetails(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<bool> updatePostInformation(String postId) async {
    try {
      await _userServices.updatePostInformation(postId);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getOwnPosts() async {
    if (_page == 0) {
      _ownPosts = [];
    }
    int firstIndex = _page * _sizePage;
    int lastIndex = firstIndex + _sizePage - 1;
    int postsLength = _user!.postIds.length;

    if (postsLength < lastIndex) {
      lastIndex = postsLength - 1;
      _hasMorePosts = false;
    }
    for (int index = firstIndex; index <= lastIndex; index++) {
      Post newPost = await _postService.getPost(_user!.postIds[index]);
      _ownPosts.add(newPost);
    }
    _page++;
  }

  void removeData() {
    _ownPosts = [];
    _user = null;
    _hasMorePosts = true;
    _page = 0;
  }
}
