import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/relationship_view_model.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:instagram/widgets/follower_list_tab_bar_widget.dart';
import 'package:instagram/widgets/following_list_tab_bar_widget.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';

class FollowerFollowingListScreen extends StatefulWidget {
  final String followingListId;
  final String followerListId;
  final String? username;
  final int initialIndex;

  const FollowerFollowingListScreen(
      {Key? key, required this.followingListId, this.username, required this.followerListId, this.initialIndex = 0})
      : super(key: key);

  @override
  State<FollowerFollowingListScreen> createState() =>
      _FollowerFollowingListScreenState();
}

class _FollowerFollowingListScreenState
    extends State<FollowerFollowingListScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin  {
  late CurrentUserViewModel _currentUserViewModel;
  late TabController _tabController;
  final RelationshipViewModel _relationshipViewModel = RelationshipViewModel();
  late Future _getFollowerAndFollowingIds;

  @override
  void initState() {
    if (widget.username == null) {
      _currentUserViewModel = context.read<CurrentUserViewModel>();
      _getFollowerAndFollowingIds =
          _relationshipViewModel.getFollowerAndFollowingIds(
              followerListId: _currentUserViewModel.user!.followerListId,
              followingListId: _currentUserViewModel.user!.followingListId);
    } else {
      _getFollowerAndFollowingIds =
          _relationshipViewModel.getFollowerAndFollowingIds(
              followerListId: widget.followerListId,
              followingListId: widget.followingListId);
    }
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FutureBuilder(
        future: _getFollowerAndFollowingIds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()),);
          } else {
            return TabBarView(
              controller: _tabController,
              children: [
                FollowerListTabBarWidget(relationshipViewModel: _relationshipViewModel,),
                FollowingListTabBarWidget(relationshipViewModel: _relationshipViewModel,)
              ],
            );
          }
        },
      ),
    );
  }


  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(
          widget.username ?? _currentUserViewModel.user!.username, style: Theme
          .of(context)
          .textTheme
          .titleLarge),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: TabBar(
          controller: _tabController,
          labelPadding: const EdgeInsets.all(10),
          tabs: [
            Text("Follower", style: Theme
                .of(context)
                .textTheme
                .labelLarge,),
            Text("Following", style: Theme
                .of(context)
                .textTheme
                .labelLarge,),
          ],

        ),
      ),
    );
  }

  Widget _buildUserBlock(BuildContext context) {
    return Container();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
