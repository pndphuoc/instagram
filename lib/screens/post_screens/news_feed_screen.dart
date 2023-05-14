import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/provider/home_screen_provider.dart';
import 'package:instagram/screens/message_screens/chat_screen.dart';
import 'package:instagram/screens/notification_screens/notifications_screen.dart';
import 'package:instagram/screens/post_screens/ai_space_news_feed_screen.dart';
import 'package:instagram/screens/post_screens/following_news_feed.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:instagram/widgets/post_widgets/post_card.dart';
import 'package:instagram/widgets/shimmer_widgets/post_shimmer.dart';
import 'package:instagram/widgets/post_widgets/uploading_post_card.dart';
import 'package:provider/provider.dart';

import '../../ultis/ultils.dart';
import '../../view_model/notification_controller.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(context),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FollowingNewsFeedScreen(),
          AISpaceNewsFeedScreen()
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Image.asset(
        'assets/logo.png',
        width: MediaQuery.of(context).size.width / 3,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: TabBar(
          dividerColor: const Color.fromRGBO(246, 200, 200, 1.0),
          indicatorColor: const Color.fromRGBO(246, 200, 200, 1.0),
          controller: _tabController,
          tabs: [
            SizedBox(
                height: 30,
                child: Text("Following", style: Theme.of(context).textTheme.labelLarge,)),
            SizedBox(
                height: 30,
                child: Text("AI Space", style: Theme.of(context).textTheme.labelLarge,)),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                  const NotificationsScreen(),
                  transitionsBuilder: (context, animation,
                      secondaryAnimation, child) {
                    return buildSlideTransition(animation, child);
                  },
                  transitionDuration:
                  const Duration(milliseconds: 150),
                  reverseTransitionDuration:  const Duration(milliseconds: 150),
                ),
              );
            },
            child: Consumer<CurrentUserViewModel>(
              builder: (context, value, child) {
                return StreamBuilder(
                  //stream: value.hasUnReadMessage(),
                  initialData: false,
                  builder: (context, snapshot) {
                    return Badge(
                      smallSize: 10,
                      isLabelVisible: snapshot.data!,
                      child: const Icon(Icons.favorite_border, color: Colors.white,),
                    );
                  },);
              },
            ),
          ),
        )
,
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                      const ChatScreen(),
                  transitionsBuilder: (context, animation,
                      secondaryAnimation, child) {
                    return buildSlideTransition(animation, child);
                  },
                  transitionDuration:
                  const Duration(milliseconds: 150),
                  reverseTransitionDuration:  const Duration(milliseconds: 150),
                ),
              );
            },
            child: Consumer<CurrentUserViewModel>(
              builder: (context, value, child) {
                return StreamBuilder(
                    //stream: value.hasUnReadMessage(),
                    initialData: false,
                    builder: (context, snapshot) {
                      return Badge(
                        smallSize: 10,
                        isLabelVisible: snapshot.data!,
                        child: const Icon(Icons.mail_outline_rounded, color: Colors.white,),
                      );
                    },);
              },
            ),
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
