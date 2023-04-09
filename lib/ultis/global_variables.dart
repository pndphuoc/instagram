import 'package:flutter/material.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/screens/news_feed_screen.dart';
import 'package:instagram/screens/personal_profile_screen.dart';

import '../screens/add_post_screen.dart';

const homeScreenItems = [
  NewsFeedScreen(),
  SearchScreen(),
  AddPostScreen(),
  Center(child: Text("notifications", style: TextStyle(color: Colors.white),)),
  PersonalProfileScreen()
];

const String profilePicturesPath = 'profilePics';