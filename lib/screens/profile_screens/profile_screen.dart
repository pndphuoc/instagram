import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/message_screens/conversation_screen.dart';
import 'package:instagram/screens/profile_screens/personal_profile_screen.dart';
import 'package:instagram/screens/post_screens/post_list_screen.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:instagram/widgets/bottom_navigator_bar.dart';
import '../../models/user_summary_information.dart';
import '../../models/post.dart';
import '../../models/user.dart' as model;
import 'package:provider/provider.dart';

import '../../ultis/colors.dart';
import '../../ultis/ultils.dart';
import '../../view_model/relationship_view_model.dart';
import '../../widgets/post_widgets/video_player_widget.dart';
import '../../widgets/sticky_tab_bar_delegate.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final double avatarSize = 60;
  final RelationshipViewModel _relationshipViewModel = RelationshipViewModel();
  late CurrentUserViewModel _currentUserViewModel;
  late TabController _tabController;
  final UserViewModel _userViewModel = UserViewModel();
  late Future getUserDetails;
  late List<Post> posts = [];

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);

    _currentUserViewModel = context.read<CurrentUserViewModel>();

    getUserDetails = _userViewModel
        .getUserDetailsWithCurrentUser(widget.userId)
        .whenComplete(() => _userViewModel.getPosts());
    super.initState();
  }

  @override
  void dispose() {
    _userViewModel.dispose();
    super.dispose();
  }

  _onPressedFollowButton() {
    _relationshipViewModel.follow(
        _currentUserViewModel.user!.uid,
        _currentUserViewModel.user!.followingListId,
        widget.userId,
        _userViewModel.user.followerListId);
    _userViewModel.isFollowing = true;
  }

  _onPressedUnfollowButton() {
    _relationshipViewModel.unfollow(
        _currentUserViewModel.user!.uid,
        _currentUserViewModel.user!.followingListId,
        widget.userId,
        _userViewModel.user.followerListId);
    _userViewModel.isFollowing = false;
  }

/*  bool _scrollNotification(scrollNotification) {
    const double threshold = 0.5; // 90% of the list length
    final double extentAfter =
        scrollNotification.metrics.extentAfter;
    final double maxScrollExtent =
        scrollNotification.metrics.maxScrollExtent;

    if (_userViewModel.hasMorePosts &&
        scrollNotification is ScrollEndNotification &&
        extentAfter / maxScrollExtent < threshold) {
      _userViewModel.getPosts();
    }
    return true;
  }*/

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          model.User user = snapshot.data;
          if (user.uid == context.read<CurrentUserViewModel>().user!.uid) {
            return const PersonalProfileScreen();
          }
          return Scaffold(
            backgroundColor: mobileBackgroundColor,
            appBar: _appBar(context, user.username),
            body: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                return scrollEvent(scrollNotification, _userViewModel, 0.5);
              },
              child: Consumer<CurrentUserViewModel>(
                builder: (context, currentUser, child) {
                  return NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            user.avatarUrl.isNotEmpty
                                ? CircleAvatar(
                                    radius: avatarSize,
                                    backgroundImage: CachedNetworkImageProvider(
                                        user.avatarUrl),
                                  )
                                : CircleAvatar(
                                    radius: avatarSize,
                                    backgroundImage: defaultAvatar,
                                  ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              user.username,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              user.bio,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            _statsRow(context),
                            const SizedBox(
                              height: 10,
                            ),
                            _buttonsRow(context),
                          ],
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: StickyTabBarDelegate(
                          child:
                              TabBar(controller: _tabController, tabs: const [
                            Tab(
                              child: Icon(Icons.grid_view),
                            ),
                            Tab(
                              child: Icon(Icons.video_collection_outlined),
                            )
                          ]),
                        ),
                        pinned: true,
                      ),
                    ],
                    body: TabBarView(
                      controller: _tabController,
                      children: [_postGrid(context), _videosGrid(context)],
                    ),
                  );
                },
              ),
            ),
            bottomNavigationBar: const BottomNavBar(),
          );
        }
      },
    );
  }

  Widget _postGrid(BuildContext context) {
    return StreamBuilder(
      stream: _userViewModel.postsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          posts.addAll(snapshot.data!);
          snapshot.data!.clear();
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                _userViewModel.hasMorePosts ? posts.length + 1 : posts.length,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 2,
                mainAxisSpacing: 1),
            itemBuilder: (context, index) {
              if (index >= posts.length && _userViewModel.hasMorePosts) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            PostListScreen(
                          posts: posts,
                          index: index,
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return buildSlideTransition(animation, child);
                        },
                        transitionDuration: const Duration(milliseconds: 150),
                        reverseTransitionDuration:
                            const Duration(milliseconds: 150),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      if (posts[index].medias.first.type == 'image')
                        CachedNetworkImage(
                          imageUrl: posts[index].medias.first.url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          fadeInDuration: const Duration(milliseconds: 100),
                        )
                      else
                        Positioned.fill(
                          child: VideoPlayerWidget.network(
                            url: posts[index].medias.first.url,
                            isPlay: false,
                          ),
                        ),
                      if (posts[index].medias.length > 1)
                        const Positioned(
                            top: 5,
                            right: 5,
                            child: Icon(
                              Icons.layers_rounded,
                              color: Colors.white,
                            ))
                      else if (posts[index].medias.first.type == 'video')
                        const Positioned(
                            top: 5,
                            right: 5,
                            child: Icon(
                              Icons.slow_motion_video_rounded,
                              color: Colors.white,
                            ))
                    ],
                  ));
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
      },
    );
  }

  Widget _videosGrid(BuildContext context) {
    return Container();
  }

  AppBar _appBar(BuildContext context, String username) {
    return AppBar(
      elevation: 0,
      shape: Border.all(width: 0),
      backgroundColor: mobileBackgroundColor,
      title: Text(
        username,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: const Icon(Icons.notifications_outlined),
        ),
        const SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () {},
          child: const Icon(Icons.more_horiz),
        ),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }

  Widget _buttonsRow(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Expanded(
            child: StreamBuilder<bool>(
          stream: _userViewModel.followStateStream,
          initialData: _userViewModel.isFollowing,
          builder: (context, snapshot) {
            if (snapshot.data!) {
              return ElevatedButton(
                  onPressed: _onPressedUnfollowButton,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: secondaryColor),
                  child: Text(
                    "Unfollow",
                    style: Theme.of(context).textTheme.titleMedium,
                  ));
            } else {
              return ElevatedButton(
                  onPressed: _onPressedFollowButton,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: primaryColor),
                  child: Text(
                    "Follow",
                    style: Theme.of(context).textTheme.titleMedium,
                  ));
            }
          },
        )),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: ElevatedButton(
              onPressed: _onMessageButtonPressed,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: secondaryColor),
              child: Text(
                "Message",
                style: Theme.of(context).textTheme.titleMedium,
              )),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget _statsRow(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        _statsBlock(name: 'Posts', count: _userViewModel.user.postIds.length),
        StreamBuilder<int>(
            stream: _userViewModel.followerStream,
            initialData: _userViewModel.user.followerCount,
            builder: (context, snapshot) {
              return _statsBlock(name: 'Followers', count: snapshot.data!);
            }),
        _statsBlock(
            name: 'Following', count: _userViewModel.user.followingCount),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget _statsBlock(
      {required String name, required int count, Function()? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              name,
              style: Theme.of(context).textTheme.labelLarge,
            )
          ],
        ),
      ),
    );
  }

  _onMessageButtonPressed() {
    final UserSummaryInformation restUser = UserSummaryInformation(
      userId: widget.userId,
      username: _userViewModel.user.username,
      avatarUrl: _userViewModel.user.avatarUrl,
      displayName: _userViewModel.user.displayName,
    );
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ConversationScreen(
          restUser: restUser,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return buildSlideTransition(animation, child);
        },
        transitionDuration: const Duration(milliseconds: 150),
        reverseTransitionDuration: const Duration(milliseconds: 150),
      ),
    );
  }
}
