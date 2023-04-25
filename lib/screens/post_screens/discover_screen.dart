import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/route/route_name.dart';
import 'package:instagram/screens/post_screens/post_details_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/post_widgets/video_player_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/post.dart';
import '../../provider/home_screen_provider.dart';
import '../../ultis/colors.dart';
import '../../view_model/elastic_view_model.dart';
import '../../view_model/post_view_model.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late HomeScreenProvider homeScreenProvider;
  late Future getPosts;
  final PostViewModel _postViewModel = PostViewModel();

  @override
  void initState() {
    getPosts = _postViewModel.getDiscoverPosts(context.read<CurrentUserViewModel>().user!.followingListId);
    homeScreenProvider = context.read<HomeScreenProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Consumer<PostViewModel>(
        builder: (context, value, child) {
          return FutureBuilder(
            future: getPosts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error.toString()}"),
                );
              } else {
                List<Post> posts = snapshot.data;
                return _postGrid(context, posts);
              }
            },
          );
        },
      ),
    );
  }

  _onSearchFieldTap() {
    homeScreenProvider.isDiscoverScreen = !homeScreenProvider.isDiscoverScreen;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const SearchScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      )
    ).whenComplete(() {
      context.read<ElasticViewModel>().searchResults = [];
    });
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: SizedBox(
        height: kToolbarHeight - 20,
        child: Consumer<ElasticViewModel>(
          builder: (context, elastic, child) {
            return TextField(
              readOnly: true,
              /*onChanged: (value) async {
                if (_debounce?.isActive ?? false) _debounce?.cancel();

                _debounce = Timer(const Duration(milliseconds: 300), () async {
                  await elastic.searchData('users', {
                    'match_phrase_prefix': {'username': _searchController.text}
                  });
                  setState(() {});
                });
              },*/
              onTap: _onSearchFieldTap,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: Colors.grey,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                counterStyle: Theme.of(context).textTheme.bodyMedium,
                filled: true,
                fillColor: secondaryColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                hintText: "Search",
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _postGrid(BuildContext context, List<Post> posts) {
    return GridView.builder(
      itemCount: posts.length + 1,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 2,
          mainAxisSpacing: 1),
      itemBuilder: (context, index) {
        if (index >= posts.length) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailsScreen(posts: posts, index: index),));
          },
          child: Stack(
            children: [
              Positioned.fill(child: posts[index].medias.first.type == 'image' ? CachedNetworkImage(
                imageUrl: posts[index].medias.first.url,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
              ) : VideoPlayerWidget.network(url: posts[index].medias.first.url)),
              if (posts[index].medias.length > 1) 
                const Positioned(top: 5, right: 5, child: Icon(Icons.layers_rounded, color: Colors.white,))
              else if (posts[index].medias.first.type == 'video')
                const Positioned(top: 5, right: 5,child: Icon(Icons.slow_motion_video_rounded, color: Colors.white,))
            ],
          ),
        );
      },
    );
  }
}
