import 'package:flutter/material.dart';
import 'package:instagram/provider/home_screen_provider.dart';
import 'package:instagram/widgets/bottom_navigator_bar.dart';
import 'package:provider/provider.dart';


class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {


  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenProvider>(
      builder: (context, value, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: value.currentIndex,
            children: value.screens,
          ),
          bottomNavigationBar: const BottomNavBar(),
        );
      },);
  }
}
