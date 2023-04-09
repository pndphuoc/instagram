import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/personal_profile_screen.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:instagram/widgets/bottom_navigator_bar.dart';
import '../models/post.dart';
import '../models/user.dart' as model;
import 'package:provider/provider.dart';

import '../ultis/colors.dart';
import '../widgets/sticky_tab_bar_delegate.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final double avatarSize = 60;
  late TabController _tabController;
  late UserViewModel _userViewModel;
  late Future getUserDetails;
  late List<Post> posts = [];
  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    _userViewModel = UserViewModel();
    getUserDetails = _userViewModel.getUserDetails(widget.userId).whenComplete(() => _userViewModel.getPosts());
    super.initState();
  }

  @override
  void dispose() {
    _userViewModel.dispose();
    super.dispose();
  }

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
            appBar: _appBar(context, user.username),
            body: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
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
              },
              child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) =>
                  [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          user.avatarUrl != null
                              ? CircleAvatar(
                            radius: avatarSize,
                            backgroundImage: CachedNetworkImageProvider(
                                user.avatarUrl!),
                          )
                              : Image.asset(
                            'assets/default_avatar.jpg',
                            width: avatarSize,
                            height: avatarSize,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            user.username,
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleLarge,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            user.bio ?? "",
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              _statsBlock(
                                  name: 'Posts',
                                  count: user.postIds.length),
                              _statsBlock(
                                  name: 'Followers',
                                  count: user.followerCount),
                              _statsBlock(
                                  name: 'Following',
                                  count: user.followingCount),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                        backgroundColor: primaryColor),
                                    child: Text(
                                      "Follow",
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .titleMedium,
                                    )),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                        backgroundColor: secondaryColor),
                                    child: Text(
                                      "Message",
                                      style:
                                      Theme
                                          .of(context)
                                          .textTheme
                                          .titleMedium,
                                    )),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                    children: [
                      _postGrid(context),
                      _videosGrid(context)
                    ],
                  ),
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
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userViewModel.hasMorePosts
                ? posts.length + 1
                : posts.length,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 2,
                mainAxisSpacing: 1),
            itemBuilder: (context, index) {
              if (index >= posts.length &&
                  _userViewModel.hasMorePosts) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return CachedNetworkImage(
                imageUrl: posts[index].mediaUrls.first,
                fit: BoxFit.cover,
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator(color: Colors.blue,),);
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
        style: Theme
            .of(context)
            .textTheme
            .titleLarge,
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

  Widget _statsBlock(
      {required String name, required int count, Function()? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              count.toString(),
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
            Text(
              name,
              style: Theme
                  .of(context)
                  .textTheme
                  .labelLarge,
            )
          ],
        ),
      ),
    );
  }
}
