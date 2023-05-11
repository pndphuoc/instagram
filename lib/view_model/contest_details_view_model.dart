import 'package:flutter/cupertino.dart';
import 'package:instagram/repository/contest_repository.dart';

import '../models/contest.dart';
import '../models/post.dart';

class ContestDetailsViewModel extends ChangeNotifier {
  late String contestId;
  Contest? contestDetails;
  ContestDetailsViewModel({required this.contestId}) {
    getContestDetails();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Post> _top10PostOfContest = [];
  List<Post> get top10PostOfContest => _top10PostOfContest;

  Future<void> getContestDetails() async {
    _isLoading = true;
    notifyListeners();

    contestDetails = await ContestRepository.getContestDetail(contestId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getTop10PostOfContest() async {
    _isLoading = true;
    notifyListeners();

    _top10PostOfContest = await ContestRepository.getTop10PostOfContest(contestId);

    _isLoading = false;
    notifyListeners();
  }

}