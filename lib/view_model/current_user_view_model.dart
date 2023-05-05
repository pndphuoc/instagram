import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user_summary_information.dart';
import '../models/post.dart';
import '../models/user.dart' as model;
import '../services/like_services.dart';
import '../services/post_services.dart';
import '../services/user_services.dart';

class CurrentUserViewModel extends ChangeNotifier {
  final UserService _userServices = UserService();
  final PostService _postService = PostService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LikeService _likeService = LikeService();

  model.User? _user;

  List<Post> _posts = [];

  List<Post> get posts => _posts;

  set posts(List<Post> value) {
    _posts = value;
  }

  UserSummaryInformation? _chatUser;

  UserSummaryInformation get chatUser => _chatUser!;
  bool _hasMorePosts = true;

  model.User? get user => _user;

  bool get hasMorePosts => _hasMorePosts;

  List<bool> _isSeenConversations = [];

  List<bool> get isSeenConversations => _isSeenConversations;

  set isSeenConversations(List<bool> value) {
    _isSeenConversations = value;
    notifyListeners();
  }

  int _totalPage = 1;
  final int _pageSize = 12;

  final StreamController<List<Post>> _postController = BehaviorSubject();

  Stream<List<Post>> get postStream => _postController.stream;

  Stream<model.User> getUserData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .transform(
          StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
              model.User>.fromHandlers(
            handleData: (snapshot, sink) async {
              _user = model.User.fromJson(snapshot.data()!);
              _chatUser = UserSummaryInformation(
                userId: _user!.uid,
                username: _user!.username,
                avatarUrl: _user!.avatarUrl,
                displayName: _user!.displayName,
              );
              await getPosts();
              print("hehe ${_posts.length}");
              sink.add(user!);
            },
            handleError: (error, stackTrace, sink) {
              // Xử lý lỗi nếu có
              print('Error: $error');
            },
          ),
        )
        .distinct();
  }

  Future<void> getPosts([int page = 1]) async {
    _totalPage = (_user!.postIds.length / _pageSize).ceil() + 1;
    if (page > _totalPage) {
      return;
    }
    final startIndex = (page - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    _hasMorePosts = endIndex < _user!.postIds.length;

/*    await Future.wait(_user!.postIds
        .skip(startIndex)
        .take(_pageSize)
        .map((postId) => _postService.getPost(postId))
        .toList());*/
    for (var uid in _user!.postIds.skip(startIndex).take(_pageSize)) {
      if (!_posts.any((element) => element.uid == uid)) {
        final post = await _postService.getPost(uid);
        post.isLiked = await _likeService.isLiked(post.likedListId, _user!.uid);
        _posts.add(post);
      }
    }

    _postController.sink.add([]);
  }

  Future<void> toggleArchivePost(String postId, bool isArchive) async {
    if (isArchive == false) {
      _archivedPost.removeWhere((element) => element.uid == postId);
      notifyListeners();
    } else {
      _posts.removeWhere((element) => element.uid == postId);
    }
    await _postService.toggleArchivePost(postId: postId, isArchive: isArchive);
  }

  List<Post> _archivedPost = [];

  List<Post> get archivedPost => _archivedPost;

  set archivedPost(List<Post> value) {
    _archivedPost = value;
  }

  Future<void> getArchivedPosts(String userId) async {
    _archivedPost = await _postService.getArchivedPosts(userId: userId);
  }

  Future<void> getCurrentUserDetails() async {
    try {
      _user = await _userServices
          .getUserDetails(FirebaseAuth.instance.currentUser!.uid);
      _chatUser = UserSummaryInformation(
        userId: _user!.uid,
        username: _user!.username,
        avatarUrl: _user!.avatarUrl,
        displayName: _user!.displayName,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    await _postService.deletePost(postId);
    _posts.removeWhere((element) => element.uid == postId);
    _postController.sink.add([]);
  }
}
