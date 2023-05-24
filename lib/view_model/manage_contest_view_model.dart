import 'package:flutter/material.dart';
import 'package:instagram/repository/contest_repository.dart';

import '../models/contest.dart';

class ManageContestViewModel extends ChangeNotifier {
  List<Contest> _joinedContest = [];
  List<Contest> get joinedContest => _joinedContest;
  late String userId;
  List<Contest> _ownContest = [];
  List<Contest> get ownContest => _ownContest;
  ManageContestViewModel(this.userId) {
    getJoinedContest();
    getOwnContest();
  }

  Future<void> getJoinedContest() async {
    _joinedContest = await ContestRepository.getJoinedContest(userId: userId);
    notifyListeners();
  }

  Future<void> getOwnContest() async {
    _ownContest = await ContestRepository.getOwnContest(userId: userId);
    notifyListeners();
  }
}