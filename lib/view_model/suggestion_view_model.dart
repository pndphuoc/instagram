import 'package:flutter/cupertino.dart';
import 'package:instagram/repository/suggestion_repository.dart';

import '../models/user.dart';

class SuggestionViewModel extends ChangeNotifier {
  List<User> _usersSuggested = [];

  List<User> get usersSuggested => _usersSuggested;

  void getUsersSuggested() async {
    _usersSuggested = await SuggestionRepository().getSuggestedUsers();
    notifyListeners();
  }
}