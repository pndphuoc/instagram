import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:instagram/repository/contest_repository.dart';
import 'package:mime/mime.dart';

import '../models/contest.dart';
import '../models/media.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../repository/firebase_storage_repository.dart';
import '../repository/post_repository.dart';
import '../ultis/global_variables.dart';

class CommonContestViewModel extends ChangeNotifier {
  List<Contest> _upcomingContests = [];
  List<Contest> _progressingContests = [];
  List<Contest> _expiredContests = [];

  List<Contest> get upcomingContests => _upcomingContests;

  bool isLoading = true;
  CommonContestViewModel() {
    getContest();
  }
  Future<void> getContest({int page = 0, int pageSize = 10, bool isRefresh = false}) async {
    if (isRefresh) {
      _upcomingContests = [];
      _progressingContests = [];
      _expiredContests = [];
    }
    isLoading = true;
    notifyListeners();

    ContestRepository.getContests().then((value) {
      classifyContests(value);
    });

    isLoading = false;
    notifyListeners();
  }

  List<Post> _posts = [];

  void classifyContests(List<Contest> contests) {
    for(final contest in contests) {
      if (DateTime.now().isBefore(contest.endTime) && DateTime.now().isAfter(contest.startTime)) {
        _progressingContests.add(contest);
      } else if (DateTime.now().isBefore(contest.startTime)) {
        _upcomingContests.add(contest);
      } else {
        _expiredContests.add(contest);
      }
    }
    notifyListeners();
  }

  List<Post> get posts => _posts;
  bool isLoadingPosts = false;

  Future<void> getPostsOfContest(String contestId, {int page = 0, int pageSize = 10}) async {
    _posts = await ContestRepository.getPostsOfContest(contestId);
  }

  List<Contest> get progressingContests => _progressingContests;

  List<Contest> get expiredContests => _expiredContests;
}