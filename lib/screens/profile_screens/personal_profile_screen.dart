import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/contest_screens/contest_list_screen.dart';
import 'package:instagram/screens/post_screens/post_list_screen.dart';
import 'package:instagram/screens/profile_screens/archive_screen.dart';
import 'package:instagram/screens/profile_screens/edit_profile_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/authentication_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/post_widgets/video_player_widget.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/user.dart' as model;
import '../../ultis/ultils.dart';
import '../../widgets/common_widgets/sticky_tab_bar_delegate.dart';
import 'follower_following_list_screen.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({Key? key}) : super(key: key);

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen>
    with TickerProviderStateMixin {
  final double avatarSize = 60;
  late TabController _tabController;
  int page = 1;

  late CurrentUserViewModel _currentUserViewModel;

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, _currentUserViewModel.user!.username),
      body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            const double threshold = 0.5; // 90% of the list length
            final double extentAfter = scrollNotification.metrics.extentAfter;
            final double maxScrollExtent =
                scrollNotification.metrics.maxScrollExtent;

            if (_currentUserViewModel.hasMorePosts &&
                scrollNotification is ScrollEndNotification &&
                extentAfter / maxScrollExtent < threshold) {
              _currentUserViewModel.getPosts(++page);
            }
            return true;
          },
          child: StreamBuilder(
              stream: _currentUserViewModel
                  .getUserData(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        _currentUserViewModel.user!.avatarUrl.isNotEmpty
                            ? Hero(
                                tag: 'avatar',
                                child: CircleAvatar(
                                  radius: avatarSize,
                                  backgroundImage: CachedNetworkImageProvider(
                                      _currentUserViewModel.user!.avatarUrl),
                                ),
                              )
                            : Hero(
                                tag: 'avatar',
                                child: CircleAvatar(
                                    radius: avatarSize,
                                    backgroundImage: const AssetImage(
                                        "assets/default_avatar.png")),
                              ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          _currentUserViewModel.user!.username,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (_currentUserViewModel.user!.displayName.isNotEmpty)
                          Text(
                            _currentUserViewModel.user!.displayName,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          _currentUserViewModel.user!.bio,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _statsRow(context, _currentUserViewModel.user!),
                        const SizedBox(
                          height: 10,
                        ),
                        _buttonsRow(context),
                      ],
                    )),
                    SliverPersistentHeader(
                      delegate: StickyTabBarDelegate(
                        child: TabBar(controller: _tabController, tabs: const [
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
              })),
    );
  }

  Widget _buttonsRow(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const EditProfileScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return buildSlideTransition(animation, child,
                          offset: const Offset(0.0, 1.0));
                    },
                    transitionDuration: const Duration(milliseconds: 150),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 150),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: secondaryColor),
              child: Text(
                "Edit profile",
                style: Theme.of(context).textTheme.titleMedium,
              )),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: ElevatedButton(
              onPressed: () async {
                await AuthenticationViewModel.logout().whenComplete(
                  () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MyApp(),
                      ),
                      (_) => false,
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: secondaryColor),
              child: Text(
                "Log out",
                style: Theme.of(context).textTheme.titleMedium,
              )),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget _statsRow(BuildContext context, model.User user) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        _statsBlock(name: 'Posts', count: user.postIds.length),
        _statsBlock(
            name: 'Followers',
            count: user.followerCount,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowerFollowingListScreen(
                        followerListId: user.followerListId,
                        followingListId: user.followerListId),
                  ));
            }),
        _statsBlock(
            name: 'Following',
            count: user.followingCount,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowerFollowingListScreen(
                      followerListId: user.followerListId,
                      followingListId: user.followerListId,
                      initialIndex: 1,
                    ),
                  ));
            }),
        const SizedBox(
          width: 20,
        ),
      ],
    );
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
          child: const Icon(Icons.add_box_outlined),
        ),
        const SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () {
            _showModal(context);
          },
          child: const Icon(Icons.list_sharp),
        ),
        const SizedBox(
          width: 20,
        )
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

  Widget _postGrid(BuildContext context) {
    return StreamBuilder(
        stream: _currentUserViewModel.postStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text("No Post"),
            );
          } else {
            return GridView.builder(
              cacheExtent: 1000,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentUserViewModel.hasMorePosts
                  ? _currentUserViewModel.posts.length + 1
                  : _currentUserViewModel.posts.length,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 1),
              itemBuilder: (context, index) {
                if (index >= _currentUserViewModel.posts.length &&
                    _currentUserViewModel.hasMorePosts) {
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
                          posts: _currentUserViewModel.posts,
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
                      if (_currentUserViewModel
                              .posts[index].medias.first.type ==
                          'image')
                        CachedNetworkImage(
                          imageUrl: _currentUserViewModel
                              .posts[index].medias.first.url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          fadeInDuration: const Duration(milliseconds: 100),
                        )
                      else
                        Positioned.fill(
                          child: VideoPlayerWidget.network(
                            url: _currentUserViewModel
                                .posts[index].medias.first.url,
                            isPlay: false,
                          ),
                        ),
                      if (_currentUserViewModel.posts[index].medias.length > 1)
                        const Positioned(
                            top: 5,
                            right: 5,
                            child: Icon(
                              Icons.layers_rounded,
                              color: Colors.white,
                            ))
                      else if (_currentUserViewModel
                              .posts[index].medias.first.type ==
                          'video')
                        const Positioned(
                            top: 5,
                            right: 5,
                            child: Icon(
                              Icons.slow_motion_video_rounded,
                              color: Colors.white,
                            ))
                    ],
                  ),
                );
              },
            );
          }
        });
  }

  Widget _videosGrid(BuildContext context) {
    return Container();
  }

  _showModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      builder: (context) {
        return IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.remove_rounded,
                  size: 40,
                ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          Icons.settings_outlined,
                          size: 35,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Settings",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    )),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContestListScreen(ownerId: _currentUserViewModel.user!.uid),
                      ));
                },
                child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(Icons.photo_library_outlined, size: 35),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "My contests",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    )),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ArchiveScreen(),
                      ));
                },
                child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(Icons.archive_outlined, size: 35),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Archive",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    )),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(Icons.storage_outlined, size: 35),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Saved",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    )),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          Icons.logout,
                          size: 35,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Log out",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}
