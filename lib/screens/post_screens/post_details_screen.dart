import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:instagram/widgets/bottom_navigator_bar.dart';
import 'package:instagram/widgets/post_widgets/post_card.dart';

import '../../models/post.dart';

class PostDetailsScreen extends StatefulWidget {
  final List<Post> posts;
  final int index;
  const PostDetailsScreen({Key? key, required this.posts, required this.index})
      : super(key: key);

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text("Posts", style: Theme.of(context).textTheme.titleLarge,),
      ),
      backgroundColor: mobileBackgroundColor,
      body: ListView.separated(
        controller: _scrollController,
        itemCount: widget.posts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20,),
        itemBuilder: (context, index) {
          return PostCard(post: widget.posts[index]);
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
