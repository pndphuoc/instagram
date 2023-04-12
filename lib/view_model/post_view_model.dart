import 'package:flutter/foundation.dart';
import 'package:instagram/provider/home_screen_provider.dart';
import 'package:instagram/services/firestorage_services.dart';
import 'package:instagram/services/like_services.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/like_view_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../resources/storage_methods.dart';
import '../services/post_services.dart';

class PostViewModel extends ChangeNotifier {
  final PostService _postService = PostService();
  final CurrentUserViewModel _userViewModel = CurrentUserViewModel();

  List<Post> _posts = [];
  bool _isUploading = false;

  List<Post> get posts => _posts;

  bool get isUploading => _isUploading;

  bool _isEnableShimmer = true;

  bool get isEnableShimmer => _isEnableShimmer;

  set isUploading(bool value) {
    _isUploading = value;
  }

  Future<void> getPosts() async {
    _posts = await _postService.getPosts();
    _isEnableShimmer = false;
    notifyListeners();
  }

  Future<Post> getPost(String postId, LikeViewModel likeViewModel, String userId) async {
    final post = await _postService.getPost(postId);
    await likeViewModel.getIsLiked(post.likedListId, userId);
    return post;
  }

  Future uploadMediasOfPost(AssetViewModel assetViewModel) async {
    _isUploading = true;
    notifyListeners();

    final storageMethods = StorageMethods();

    List<String> urls = [];
    if (assetViewModel.selectedEntities.isEmpty) {
      final entity = assetViewModel.selectedEntity!;
      final file = await entity.fileWithSubtype;

      if (file == null) {
        return;
      }

      if (entity.type == AssetType.image) {
        String url = await storageMethods.uploadPhotoToStorage(
            'photos', file.readAsBytesSync(), true);
        urls.add(url);
        return urls;
      } else if (entity.type == AssetType.video) {
        String url = await storageMethods.uploadVideoToStorage(file);
        urls.add(url);
        return urls;
      }
    }

    for (final entity in assetViewModel.selectedEntities) {
      final file = await entity.fileWithSubtype;
      if (file == null) {
        continue;
      }

      if (entity.type == AssetType.image) {
        String url = await storageMethods.uploadPhotoToStorage(
            'photos', file.readAsBytesSync(), true);
        urls.add(url);
      } else if (entity.type == AssetType.video) {
        String url = await storageMethods.uploadVideoToStorage(file);
        urls.add(url);
      }
    }
    return urls;
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

    final List<String> urls = await uploadMediasOfPost(asset);

    post.mediaUrls = urls;
    String id = await addPost(post);
    await _userViewModel.updatePostInformation(id);
    isUploading = false;
  }
}
