import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/models/comment.dart';

import '../ultis/ultils.dart';

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
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.cmt.avatarUrl),
            radius: avatarSize,
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: Text(
                        widget.cmt.username,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                        child: Text(
                      getElapsedTime(widget.cmt.createdAt),
                      style: GoogleFonts.readexPro(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                          fontSize: 12),
                    )),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.cmt.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Reply",
                    style: GoogleFonts.readexPro(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                        fontSize: 12),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 20,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(widget.cmt.likeCount.toString()),
              ],
            ),
          )
        ],
      ),
    );
  }
}
