import 'package:flutter/cupertino.dart';
import 'package:instagram/repository/contest_repository.dart';

import '../models/contest.dart';
import '../models/post.dart';

class CommonContestViewModel extends ChangeNotifier {
  List<Contest> _upcomingContests = [];
  List<Contest> _progressingContests = [];
  List<Contest> _expiredContests = [];

  List<Contest> get upcomingContests => _upcomingContests;

  CommonContestViewModel() {
    getContest();
  }
  Future<void> getContest({int page = 0, int pageSize = 10}) async {
    ContestRepository.getUpcomingContest().then((list) {
      _upcomingContests = list;
      notifyListeners();
    });

    ContestRepository.getProgressingContest().then((list) {
      _progressingContests = list;
      notifyListeners();
    });

    ContestRepository.getExpiredContest().then((list) {
      _expiredContests = list;
      notifyListeners();
    });
    notifyListeners();
  }

  List<Post> _posts = [];


  List<Post> get posts => _posts;
  bool isLoadingPosts = false;


  Future<void> getPostsOfContest(String contestId, {int page = 0, int pageSize = 10}) async {
    _posts = await ContestRepository.getPostsOfContest(contestId);
  }



  List<Contest> get progressingContests => _progressingContests;

  List<Contest> get expiredContests => _expiredContests;
}