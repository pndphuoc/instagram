import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram/services/firebase_storage_services.dart';
import 'package:instagram/services/like_services.dart';
import 'package:instagram/services/relationship_services.dart';
import 'package:instagram/services/user_services.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:instagram/view_model/like_view_model.dart';
import 'package:mime/mime.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import '../models/media.dart';
import '../models/user.dart' as user;
import '../models/post.dart';
import '../services/post_services.dart';

class PostViewModel extends ChangeNotifier {
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final LikeService _likeService = LikeService();
  final RelationshipService _relationshipService = RelationshipService();
  final FireBaseStorageService _firebaseStorageService = FireBaseStorageService();

  List<Post> _posts = [];
  bool _isUploading = false;

  List<Post> get posts => _posts;

  bool get isUploading => _isUploading;

  bool _isEnableShimmer = true;

  bool get isEnableShimmer => _isEnableShimmer;

  set isUploading(bool value) {
    _isUploading = value;
  }

  Future<void> getPosts(String followingListId) async {
    List<String> followingIds = await _relationshipService.getFollowingIds(followingListId);
    _posts = await _postService.getPosts(followingIds);
    for (var element in _posts) {
      element.isLiked = await _likeService.isLiked(element.likedListId, FirebaseAuth.instance.currentUser!.uid);
    }
    _isEnableShimmer = false;
    notifyListeners();
  }

  Future<Post> getPost(String postId, LikeViewModel likeViewModel, String userId) async {
    final post = await _postService.getPost(postId);
    post.isLiked = await likeViewModel.getIsLiked(post.likedListId, userId);
    return post;
  }

  Future<List<Post>> getDiscoverPosts(String followingListId) async {
    List<String> followingIds = await _relationshipService.getFollowingIds(followingListId);

    List<Post> discoverPosts = await _postService.getDiscoverPosts(followingIds);
    for (var element in discoverPosts) {
      element.isLiked = await _likeService.isLiked(element.likedListId, FirebaseAuth.instance.currentUser!.uid);
    }

    discoverPosts.shuffle();

    return discoverPosts;
  }


  Future uploadMediasOfPost(AssetViewModel assetViewModel) async {
    _isUploading = true;
    notifyListeners();
    List<Media> medias = [];

    if (assetViewModel.file != null) {
      String filePath = assetViewModel.file!.path; // đường dẫn đến file cần xác định

      String? mimeType = lookupMimeType(filePath);

      if (mimeType != null) {
        if (mimeType.startsWith('image/')) {
          String url = await _firebaseStorageService.uploadFile(
              assetViewModel.file!, postsPhotosPath, isVideo: false);
          medias.add(Media(url: url, type: 'image'));
        } else if (mimeType.startsWith('video/')) {
          String url = await _firebaseStorageService.uploadFile(
              assetViewModel.file!, postVideosPath, isVideo: true);
          medias.add(Media(url: url, type: 'video'));
        } else {
          print('Unsupported format');
        }
      } else {
        print('File type cannot be determined');
      }
      return medias;
    }


    if (assetViewModel.selectedEntities.isEmpty) {
      final entity = assetViewModel.selectedEntity!;
      final file = await entity.fileWithSubtype;

      if (file == null) {
        return;
      }

      if (entity.type == AssetType.image) {
        String url = await _firebaseStorageService.uploadFile(
            file, postsPhotosPath, isVideo: false);
        medias.add(Media(url: url, type: 'image'));
        return medias;
      } else if (entity.type == AssetType.video) {
        String url = await _firebaseStorageService.uploadFile(
            file, postsPhotosPath, isVideo: true);
        medias.add(Media(url: url, type: 'video'));
        return medias;
      }
    }

    for (final entity in assetViewModel.selectedEntities) {
      final file = await entity.fileWithSubtype;
      if (file == null) {
        continue;
      }

      if (entity.type == AssetType.image) {
        String url = await _firebaseStorageService.uploadFile(
            file, postsPhotosPath, isVideo: false);
        medias.add(Media(url: url, type: 'image'));
      } else if (entity.type == AssetType.video) {
        String url = await _firebaseStorageService.uploadFile(
            file, postsPhotosPath, isVideo: true);
        medias.add(Media(url: url, type: 'video'));
      }
    }
    return medias;
  }

  Future<String> addPost(Post post) async {
    String newPostId = await _postService.addPost(post);

    Post newPost = await _postService.getPost(newPostId);

    _isUploading = false;
    _posts.removeAt(0);
    _posts.insert(0, newPost);
    notifyListeners();

    return newPostId;
  }


  Future<void> updatePost(Post post) async {
    await _postService.updatePost(post);
    final index = _posts.indexWhere((p) => p.uid == post.uid);
    _posts[index] = post;
    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    await _postService.deletePost(postId);
    _posts.removeWhere((p) => p.uid == postId);
    notifyListeners();
  }

  void handleUploadNewPost(Post post, AssetViewModel asset) async {
    posts.insert(0, post);
    isUploading = true;
    final List<Media> medias = await uploadMediasOfPost(asset);
    post.medias = medias;
    String id = await addPost(post);
    await _userService.updatePostInformation(id);
    isUploading = false;
  }

  void onUploadButtonTap(String caption, user.User user, AssetViewModel assetViewModel) {
    Post post = Post(
        caption: caption,
        userId: user.uid,
        username: user.username,
        avatarUrl: user.avatarUrl,
        likeCount: 0,
        commentCount: 0,
        createAt: DateTime.now(),
        medias: [],
        uid: '',
        commentListId: '',
        isDeleted: false,
        likedListId: '',
        updateAt: DateTime.now(),
        viewedListId: '');

    handleUploadNewPost(post, assetViewModel);

  }

  void onPageChanged() {

  }

  @override
  void dispose() {
    _posts = [];
    _isUploading = false;
    super.dispose();
  }
}
