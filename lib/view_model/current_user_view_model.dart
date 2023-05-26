import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user_summary_information.dart';
import '../models/post.dart';
import '../models/user.dart' as model;
import '../repository/like_repository.dart';
import '../repository/post_repository.dart';
import '../repository/user_repository.dart';

class CurrentUserViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  model.User? _user;

  List<Post> _posts = [];

  bool isLoading = false;

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

    for (var uid in _user!.postIds.skip(startIndex).take(_pageSize)) {
      if (!_posts.any((element) => element.uid == uid)) {
        final post = await PostRepository.getPost(uid);
        post.isLiked =
            await LikeRepository.isLiked(post.likedListId, _user!.uid);
        _posts.add(post);
        _posts.sort((a, b) => b.createAt.compareTo(a.createAt),);
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
    await PostRepository.toggleArchivePost(
        postId: postId, isArchive: isArchive);
  }

  List<Post> _archivedPost = [];

  List<Post> get archivedPost => _archivedPost;

  set archivedPost(List<Post> value) {
    _archivedPost = value;
  }

  Future<void> getArchivedPosts(String userId) async {
    _archivedPost = await PostRepository.getArchivedPosts(userId: userId);
  }

  Future<bool> getCurrentUserDetails() async {
    try {
      _user = await UserRepository.getUserDetails(
          FirebaseAuth.instance.currentUser!.uid);

      if (_user == null) return false;

      _chatUser = UserSummaryInformation(
        userId: _user!.uid,
        username: _user!.username,
        avatarUrl: _user!.avatarUrl,
        displayName: _user!.displayName,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    await PostRepository.deletePost(postId);
    _posts.removeWhere((element) => element.uid == postId);
    _postController.sink.add([]);
  }

  Future<void> updatePostCaption(
      {required Post post, required String caption}) async {
    if (post.caption == caption) return;
    isLoading = true;
    notifyListeners();

    await PostRepository.updateCaption(postId: post.uid, caption: caption);
    post.caption = caption;
    isLoading = false;
    notifyListeners();
  }
}
