import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/comment.dart';

class CommentCard extends StatefulWidget {
  final Comment cmt;
  const CommentCard({Key? key, required this.cmt}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final double avatarSize = 25;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.cmt.avatarUrl),
            radius: avatarSize,
          ),
          const SizedBox(width: 15,),
          Column(
            children: [
              Text(widget.cmt.authorId, style: Theme.of(context).textTheme.titleSmall,),
              Text(widget.cmt.content, style: Theme.of(context).textTheme.bodyMedium,),
              TextButton(onPressed: (){}, child: Text("Reply", style: Theme.of(context).textTheme.labelMedium,))
            ],
          ),
          const Spacer(),
          Column(
            children: const [
              Icon(Icons.favorite_border, size: 15,),
              SizedBox(height: 5,),
              Text("10")
            ],
          )
        ],
      ),
    );
  }
}
