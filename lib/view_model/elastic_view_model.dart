import 'package:flutter/cupertino.dart';
import 'package:instagram/models/user_summary_information.dart';
import 'package:instagram/repository/elastic_repository.dart';

class ElasticViewModel extends ChangeNotifier {
  List<UserSummaryInformation> _searchResults = [];

  List<UserSummaryInformation> get searchResults => _searchResults;

  set searchResults(List<UserSummaryInformation> value) {
    _searchResults = value;
  }

  Future<void> searchData(String query) async {
    final res = await ElasticRepository.searchData(query: query);
    _searchResults = res.map((e) => UserSummaryInformation.fromJsonElastic(e)).toList();
    notifyListeners();
  }
}