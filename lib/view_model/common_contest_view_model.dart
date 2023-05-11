import 'package:flutter/cupertino.dart';
import 'package:instagram/repository/contest_repository.dart';

import '../models/contest.dart';

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
      print("upcoming");
      _upcomingContests = list;
      print("${_upcomingContests.length}");
      notifyListeners();
    });

    ContestRepository.getProgressingContest().then((list) {
      print("progressing");
      _progressingContests = list;
      print("${_progressingContests.length}");
      notifyListeners();
    });

    ContestRepository.getExpiredContest().then((list) {
      print("expired");
      _expiredContests = list;
      print("${_expiredContests.length}");
      notifyListeners();
    });
    notifyListeners();
  }

  List<Contest> get progressingContests => _progressingContests;

  List<Contest> get expiredContests => _expiredContests;
}