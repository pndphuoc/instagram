import 'package:flutter/cupertino.dart';
import 'package:instagram/repository/dall_e_repository.dart';

import '../models/post.dart';

class AISpaceViewModel extends ChangeNotifier {
  List<Post> _posts = [];
  List<Post> get posts => _posts;
  AISpaceViewModel() {
    getAIPosts();
  }
  bool _isLoadingPosts = false;
  bool get isLoadingPosts => _isLoadingPosts;

  void getAIPosts() async {
    _isLoadingPosts = true;
    notifyListeners();

    _posts = await AISpaceRepository.getPostsInAISpace();

    _isLoadingPosts = false;
    notifyListeners();
  }
}