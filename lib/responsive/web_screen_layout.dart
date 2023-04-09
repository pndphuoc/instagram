import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';

class WebScreenLayout extends StatelessWidget {
  const WebScreenLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: webBackgroundColor,
      body: Center(child: Text("Web layout"),),
    );
  }
}
