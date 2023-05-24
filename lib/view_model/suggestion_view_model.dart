import 'package:flutter/cupertino.dart';
import 'package:instagram/repository/suggestion_repository.dart';

import '../models/user.dart';

class SuggestionViewModel extends ChangeNotifier {
  late String _currentUserId;
  SuggestionViewModel(String currentUserId) {
    _currentUserId = currentUserId;
    getUsersSuggested();
  }
  List<User> _usersSuggested = [];

  List<User> get usersSuggested => _usersSuggested;

  void getUsersSuggested() async {
    _usersSuggested = await SuggestionRepository().getSuggestedUsers();
    notifyListeners();
  }

  void onFollowTap(String userId) async {

  }
}