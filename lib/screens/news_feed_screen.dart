import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:instagram/widgets/post_card.dart';
import 'package:instagram/widgets/post_shimmer.dart';
import 'package:instagram/widgets/uploading_post_card.dart';
import 'package:provider/provider.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  late Future _getPosts;
  late CurrentUserViewModel _currentUserViewModel;
  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _getPosts = context.read<PostViewModel>().getPosts(_currentUserViewModel.user!.followingListId);
  }

  @override
  Widget build(BuildContext context) {
    final assetProvider = Provider.of<AssetViewModel>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(context),
      body: Consumer<PostViewModel>(
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
                    cacheExtent: 1000,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 20,
                    ),
                    itemCount: value.posts.length,
                    itemBuilder: (context, index) {
                      if (value.isUploading && index == 0) {
                        return UploadingPostCard(
                            post: value.posts.first,
                            asset: assetProvider.firstAsset!);
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

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: SvgPicture.asset(
        'assets/ic_instagram.svg',
        width: MediaQuery.of(context).size.width / 3,
        color: primaryColor,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            child: const Icon(Icons.mail_outline),
          ),
        )
      ],
    );
  }
}
