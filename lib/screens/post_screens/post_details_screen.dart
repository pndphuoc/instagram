import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/widgets/post_widgets/post_card.dart';

import '../../models/post.dart';

class PostDetailsScreen extends StatefulWidget {
  final Post post;
  const PostDetailsScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: mobileBackgroundColor,
      body: Column(
        children: [
          PostCard(post: widget.post)
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
