import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/post_screens/post_details_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/common_contest_view_model.dart';
import 'package:provider/provider.dart';

import '../../models/post.dart';

class ContestEntriesScreen extends StatefulWidget {
  const ContestEntriesScreen(
      {Key? key, required this.contestId, required this.contestName})
      : super(key: key);
  final String contestId;
  final String contestName;

  @override
  State<ContestEntriesScreen> createState() => _ContestEntriesScreenState();
}

class _ContestEntriesScreenState extends State<ContestEntriesScreen> {
  late Future _getPostsOfContest;

  @override
  void initState() {
    _getPostsOfContest =
        context.read<CommonContestViewModel>().getPostsOfContest(
            widget.contestId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FutureBuilder(
          future: _getPostsOfContest,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()),);
            } else {
              return _buildPostsGridView(context);
            }
          }
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(
          widget.contestName, overflow: TextOverflow.ellipsis, style: Theme
          .of(context)
          .textTheme
          .titleLarge),
    );
  }

  Widget _buildPostsGridView(BuildContext context) {
    return Selector<CommonContestViewModel, List<Post>>(
      selector: (context, viewModel) => viewModel.posts,
      builder: (context, value, child) {
        if (value.isEmpty) {
          return Center(
            child: Text("There are currently no articles.", style: Theme
                .of(context)
                .textTheme
                .titleMedium,),);
        } else {
          return GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1
          ),
            itemCount: value.length,
            itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailsScreen(postId: value[index].uid),));
                },
                child: CachedNetworkImage(imageUrl: value[index].medias.first.url, fit: BoxFit.cover)),);
        }
      },
    );
  }
}
