import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/authentication_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:provider/provider.dart';
import '../models/user.dart' as model;
import '../widgets/sticky_tab_bar_delegate.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({Key? key}) : super(key: key);

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen>
    with TickerProviderStateMixin {
  final double avatarSize = 60;
  late TabController _tabController;
  late Future _getOwnPosts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    _getOwnPosts = context.read<CurrentUserViewModel>().getOwnPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUserViewModel>(
      builder: (context, value, child) {
        return Scaffold(
          appBar: _appBar(context, value.user!.username),
          body: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                const double threshold = 0.5; // 90% of the list length
                final double extentAfter =
                    scrollNotification.metrics.extentAfter;
                final double maxScrollExtent =
                    scrollNotification.metrics.maxScrollExtent;

                if (value.hasMorePosts &&
                    scrollNotification is ScrollEndNotification &&
                    extentAfter / maxScrollExtent < threshold) {
                  value.getOwnPosts().whenComplete(() {
                    setState(() {});
                  });
                }
                return true;
              },
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: StreamBuilder(
                      stream: value.getUserData(FirebaseAuth.instance.currentUser!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(),);
                        } else if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()),);
                        } else {
                          model.User user = model.User.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                          return Column(
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
                                  backgroundImage: const AssetImage(
                                      "assets/default_avatar.png")),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                value.user!.username,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (value.user!.displayName.isNotEmpty)
                                Text(
                                  user.displayName,
                                  style: Theme.of(context).textTheme.labelSmall,
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
                              _statsRow(context, user),
                              const SizedBox(
                                height: 10,
                              ),
                              _buttonsRow(context),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: StickyTabBarDelegate(
                      child: TabBar(onTap: (value) {} ,controller: _tabController, tabs: const [
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
                  children: [_postGrid(context, value), _videosGrid(context)],
                ),
              )),
        );
      },
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10)),
                  backgroundColor: secondaryColor),
              child: Text(
                "Edit profile",
                style:
                Theme.of(context).textTheme.titleMedium,
              )),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: ElevatedButton(
              onPressed: () {
                context
                    .read<CurrentUserViewModel>()
                    .removeData();
                context
                    .read<AuthenticationViewModel>()
                    .logout();
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10)),
                  backgroundColor: secondaryColor),
              child: Text(
                "Log out",
                style:
                Theme.of(context).textTheme.titleMedium,
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
          onTap: () {},
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

  Widget _postGrid(BuildContext context, CurrentUserViewModel userViewModel) {
    return FutureBuilder(
        future: _getOwnPosts,
        builder: (context, snapshot) => GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userViewModel.hasMorePosts
                  ? userViewModel.ownPosts.length + 1
                  : userViewModel.ownPosts.length,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 1),
              itemBuilder: (context, index) {
                if (index >= userViewModel.ownPosts.length &&
                    userViewModel.hasMorePosts) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return CachedNetworkImage(
                  imageUrl: userViewModel.ownPosts[index].mediaUrls.first,
                  fit: BoxFit.cover,
                );
              },
            ));
  }

  Widget _videosGrid(BuildContext context) {
    return Container();
  }
}
