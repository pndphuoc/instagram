import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/widgets/comment_card.dart';

import '../models/post.dart';

class PostDetailsScreen extends StatefulWidget {
  final Post post;
  const PostDetailsScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final double avatarSize = 25;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: avatarSize,
                  backgroundImage: CachedNetworkImageProvider(widget.post.avatarUrl.toString(), ),
                ),
                const SizedBox(width: 15,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.post.username, style: Theme.of(context).textTheme.titleSmall,),
                    Text(widget.post.caption, style: Theme.of(context).textTheme.bodyMedium,)
                  ],
                )
              ],
            ),
          ),
          const Divider(color: Colors.white38,),
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text("Comment", style: Theme.of(context).textTheme.titleLarge,),
    );
  }
}
