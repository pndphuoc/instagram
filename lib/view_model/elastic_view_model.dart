import 'package:flutter/cupertino.dart';
import 'package:instagram/models/search_result.dart';
import 'package:instagram/services/elastic_services.dart';

class ElasticViewModel extends ChangeNotifier {
  final ElasticService _elasticService = ElasticService();
  List<SearchResult> _searchResults = [];

  List<SearchResult> get searchResults => _searchResults;

  set searchResults(List<SearchResult> value) {
    _searchResults = value;
  }

  Future<void> searchData(String index, Map<String, dynamic> query) async {
    final res = await _elasticService.searchData(index, query);
    _searchResults = res.map((e) => SearchResult.fromJson(e)).toList();
  }

  Future<bool> isUsernameExists(String index, String username) async {
    final result = await _elasticService.isUsernameExists(username);
    return result;
  }
}