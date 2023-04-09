import 'package:flutter/material.dart';
import 'package:instagram/route/route_name.dart';
import 'package:instagram/screens/discover_screen.dart';

import '../screens/add_post_screen.dart';
import '../screens/news_feed_screen.dart';
import '../screens/personal_profile_screen.dart';

class HomeScreenProvider with ChangeNotifier {
  final List<Widget> screens = [
    const NewsFeedScreen(),
    const DiscoverScreen(),
    const AddPostScreen(),
    const Center(child: Text("notifications", style: TextStyle(color: Colors.white),)),
    const PersonalProfileScreen()
  ];
  final PageController pageController = PageController();

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  bool _isDiscoverScreen = true;
  bool get isDiscoverScreen => _isDiscoverScreen;

  set isDiscoverScreen(bool value) {
    _isDiscoverScreen = value;
    notifyListeners();
  }

}
