import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import '../models/post.dart';
import '../models/user.dart' as model;
import '../services/post_services.dart';
import '../services/user_services.dart';

class CurrentUserViewModel extends ChangeNotifier {
  final UserService _userServices = UserService();
  final PostService _postService = PostService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  model.User? _user;

  bool _hasMorePosts = true;

  model.User? get user => _user;

  bool get hasMorePosts => _hasMorePosts;

  int _totalPage = 1;
  final int _pageSize = 12;

  final StreamController<List<Post>> _postController = BehaviorSubject();

  Stream<List<Post>> get postStream => _postController.stream;

  Stream<model.User> getUserData(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().transform(
          StreamTransformer<DocumentSnapshot<Map<String, dynamic>>, model.User>.fromHandlers(
            handleData: (snapshot, sink) {
              _user = model.User.fromJson(snapshot.data()!);
              sink.add(user!);
            },
            handleError: (error, stackTrace, sink) {
              // Xử lý lỗi nếu có
              print('Error: $error');
            },
          ),
        );
  }

  Future<void> getPosts([int page = 1]) async {
    if (page > _totalPage) {
      return;
    }

    _totalPage = (_user!.postIds.length / _pageSize).ceil();
    final startIndex = (page - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    _hasMorePosts = endIndex < _user!.postIds.length;

    final newPosts = await Future.wait(_user!.postIds
        .skip(startIndex)
        .take(_pageSize)
        .map((postId) => _postService.getPost(postId))
        .toList());
    _postController.sink.add(newPosts);

  }

  Future<void> getCurrentUserDetails() async {
    try {
      _user = await _userServices
          .getUserDetails(FirebaseAuth.instance.currentUser!.uid);
      getPosts();
    } catch (e) {
      rethrow;
    }
  }
}
