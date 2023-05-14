import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/home_screen_provider.dart';
import '../../view_model/asset_view_model.dart';
import '../../view_model/current_user_view_model.dart';
import '../../view_model/notification_controller.dart';
import '../../view_model/post_view_model.dart';
import '../../widgets/post_widgets/post_card.dart';
import '../../widgets/post_widgets/uploading_post_card.dart';
import '../../widgets/shimmer_widgets/post_shimmer.dart';

class FollowingNewsFeedScreen extends StatefulWidget {
  const FollowingNewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<FollowingNewsFeedScreen> createState() => _FollowingNewsFeedScreenState();
}

class _FollowingNewsFeedScreenState extends State<FollowingNewsFeedScreen> with AutomaticKeepAliveClientMixin {
  late Future _getPosts;
  late CurrentUserViewModel _currentUserViewModel;

  @override
  void initState() {
    super.initState();
    NotificationController().addListener(() => setState(() {}));
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _getPosts = context.read<PostViewModel>().getPosts(_currentUserViewModel.user!.followingListId);
  }

  Future<void> _refresh() async {
    setState(() {
      _getPosts = context.read<PostViewModel>().getPosts(_currentUserViewModel.user!.followingListId);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final assetProvider = Provider.of<AssetViewModel>(context, listen: false);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Consumer<PostViewModel>(
        builder: (context, value, child) {
          return FutureBuilder(
            future: _getPosts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SingleChildScrollView(
                  child: Column(
                    children: const [
                      PostShimmer(),
                      SizedBox(height: 20,),
                      PostShimmer(),
                    ],
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (value.posts.isNotEmpty) {
                  return ListView.separated(
                    controller: context.read<HomeScreenProvider>().scrollController,
                    cacheExtent: 1000,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 20,
                    ),
                    itemCount: value.posts.length,
                    itemBuilder: (context, index) {
                      if (value.isUploading && index == 0) {
                        return UploadingPostCard(
                            post: value.posts.first,
                            asset: assetProvider.firstAsset);
                      }
                      return PostCard(post: value.posts[index]);
                    },
                  );
                } else {
                  return const Center(
                    child: Text("No post"),
                  );
                }
              } else {
                return const Center(
                  child: Text("Error"),
                );
              }
            },
          );
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
