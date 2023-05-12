import 'package:flutter/material.dart';
import 'package:instagram/provider/home_screen_provider.dart';
import 'package:provider/provider.dart';

import '../../route/route_name.dart';
import '../../ultis/colors.dart';
import '../../view_model/asset_view_model.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenProvider>(builder: (context, value, child) {
      return BottomNavigationBar(
          currentIndex: value.currentIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 28,
          elevation: 0,
          backgroundColor: mobileBackgroundColor,
          onTap: (index) {
            if (index == 0 && value.currentIndex == 0) {
              value.scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
            }
            if (index == 2) {
              Navigator.pushNamed(context, RouteName.addPost).then((
                  value) =>
                  Provider.of<AssetViewModel>(context, listen: false)
                      .resetAssetViewModel());
            } else {
              Navigator.popUntil(context, (route) => route.settings.name == "/");
              value.currentIndex = index;
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, color: onBackground,),
                activeIcon: Icon(Icons.home, color: onBackground),
                label: 'home',
                backgroundColor: mobileBackgroundColor
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined, color: onBackground,),
                activeIcon: Icon(Icons.search, color: onBackground,),
                label: 'search',
                backgroundColor: mobileBackgroundColor
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline, color: onBackground),
                label: 'add post',
                backgroundColor: mobileBackgroundColor
            ),
            BottomNavigationBarItem(
                icon: Icon(
                    Icons.bar_chart_rounded, color: onBackground),
                label: 'contest',
                backgroundColor: mobileBackgroundColor
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, color: onBackground),
                activeIcon: Icon(Icons.person, color: onBackground),
                label: 'home',
                backgroundColor: mobileBackgroundColor
            ),
          ]
      );
    },);
  }
}
