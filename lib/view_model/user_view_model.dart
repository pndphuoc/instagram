import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:instagram/services/user_services.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/post_services.dart';

class UserViewModel with ChangeNotifier {
  final UserService _userService = UserService();
  final PostService _postService = PostService();

  List<Post> posts = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPage = 1;
  final int _pageSize = 12;

  //List<Post> get posts => _posts;

  final _postController = StreamController<List<Post>>();
  Stream<List<Post>> get postsStream => _postController.stream;
  late User? _user;

  bool _hasMorePosts = true;
  bool get hasMorePosts => _hasMorePosts;
  bool get isLoading => _isLoading;

  Future<User?> getUserDetails(String id) async {
    _user = await _userService.getUserDetails(id);
    return _user;
  }

  Future<void> getPosts() async {
    if (_isLoading || _user == null || _currentPage > _totalPage) {
      return;
    }

    _isLoading = true;

    _totalPage = _user!.postIds.length ~/ _pageSize + 1;
    int firstIndex = (_currentPage - 1) * _pageSize;
    int lastIndex = firstIndex + _pageSize;
    int postsLength = _user!.postIds.length;

    if (postsLength < lastIndex) {
      lastIndex = postsLength;
      _hasMorePosts = false;
    }

    List<Post> newPosts = await Future.wait(_user!.postIds
        .sublist(firstIndex, lastIndex)
        .map((postId) => _postService.getPost(postId)));

    _postController.sink.add(newPosts);

    _isLoading = false;
    _currentPage++;

  }

  @override
  void dispose() {
    _postController.close();
    super.dispose();
  }
}