import 'package:flutter/material.dart';
import 'package:instagram/route/route_name.dart';
import 'package:instagram/screens/notification_screens/notifications_screen.dart';
import 'package:instagram/screens/post_screens/discover_screen.dart';

import '../screens/contest_screens/contest_list_screen.dart';
import '../screens/post_screens/add_post_screen.dart';
import '../screens/post_screens/news_feed_screen.dart';
import '../screens/profile_screens/personal_profile_screen.dart';

class HomeScreenProvider with ChangeNotifier {

  final ScrollController scrollController = ScrollController();

  final List<Widget> screens = [
    const NewsFeedScreen(),
    const ContestListScreen(),
    Container(),
    const NotificationsScreen(),
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
