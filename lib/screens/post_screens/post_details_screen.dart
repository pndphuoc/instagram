import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/like_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:instagram/widgets/post_widgets/post_card.dart';

import '../../models/post.dart';

class PostDetailsScreen extends StatefulWidget {
  final Post? post;
  final String? postId;
  const PostDetailsScreen({Key? key, this.post, this.postId}) : super(key: key);

  factory PostDetailsScreen.fromId(String postId) {
    return PostDetailsScreen(postId: postId,);
  }
  factory PostDetailsScreen.fromPost(Post post) {
    return PostDetailsScreen(post: post,);
  }

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final PostViewModel _postViewModel = PostViewModel();
  final LikeViewModel _likeViewModel = LikeViewModel();
  late Future _getPostDetail;
  @override
  void initState() {
    _getPostDetail = _postViewModel.getPost(widget.postId!, _likeViewModel);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: mobileBackgroundColor,
      body: Column(
        children: [
          if (widget.post != null) PostCard(post: widget.post!)
          else
            FutureBuilder(
                future: _getPostDetail,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(),);
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()),);
                  } else {
                    return PostCard(post: snapshot.data!);
                  }
                },)
        ],
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text("Post", style: Theme.of(context).textTheme.titleLarge,),
    );
  }
}
