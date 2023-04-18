import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:instagram/services/relationship_services.dart';
import 'package:instagram/services/user_services.dart';
import 'package:rxdart/rxdart.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/post_services.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  final RelationshipService _relationshipService = RelationshipService();

  List<Post> posts = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPage = 1;
  final int _pageSize = 12;
  bool _isFollowing = false;

  bool get isFollowing => _isFollowing;

  set isFollowing(bool value) {
    _isFollowing = value;
    _followStateController.sink.add(value);
    _followerController.sink.add(value ? ++_user.followerCount : --_user.followerCount);
    notifyListeners();
  }

  late User _user;

  User get user => _user;


  final _followStateController = StreamController<bool>();
  final StreamController<List<Post>> _postController = BehaviorSubject();
  final _followerController = StreamController<int>();

  Stream<int> get followerStream => _followerController.stream;
  Stream<bool> get followStateStream => _followStateController.stream;
  Stream<List<Post>> get postsStream => _postController.stream;

  bool _hasMorePosts = true;

  bool get hasMorePosts => _hasMorePosts;

  bool get isLoading => _isLoading;

  Future<User> getUserDetailsWithCurrentUser(
      String currentUserId, String targetUserId) async {
    _user = await _userService.getUserDetails(targetUserId);
    _followStateController.sink.add(await _relationshipService.isFollowing(currentUserId, targetUserId));
    _followerController.sink.add(_user.followerCount);
    return _user;
  }

  Future<User> getUserDetails(String userId) async {
    return await _userService.getUserDetails(userId);
  }

  Future<void> getPostThumbnail() async {

  }

  Future<void> getPosts() async {
    if (_isLoading || _currentPage > _totalPage) {
      return;
    }

    _isLoading = true;

    _totalPage = _user.postIds.length ~/ _pageSize + 1;
    int firstIndex = (_currentPage - 1) * _pageSize;
    int lastIndex = firstIndex + _pageSize;
    int postsLength = _user.postIds.length;

    if (postsLength < lastIndex) {
      lastIndex = postsLength;
      _hasMorePosts = false;
    }

    List<Post> newPosts = await Future.wait(_user.postIds
        .sublist(firstIndex, lastIndex)
        .map((postId) => _postService.getPost(postId)));

    _postController.sink.add(newPosts);

    _isLoading = false;
    _currentPage++;
  }

  Future<String> addNewUser(
      {required String email,
      required String username,
      required String uid,
      String displayName = '',
      String bio = '',
      String avatarUrl = ''}) async {
    return await _userService.addNewUser(
        email: email,
        username: username,
        uid: uid,
        displayName: displayName,
        avatarUrl: avatarUrl,
        bio: bio);
  }

  Future<void> isFollowed(String currentUserId, String targetUserId) async {
    _isFollowing =
        await _relationshipService.isFollowing(currentUserId, targetUserId);
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    await _userService.setOnlineStatus(isOnline);
  }

  @override
  void dispose() {
    _postController.close();
    super.dispose();
  }
}
