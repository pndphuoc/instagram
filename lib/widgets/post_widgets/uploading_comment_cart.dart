import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/ultis/colors.dart';

import '../../ultis/ultils.dart';

class UploadingCommentCard extends StatelessWidget {
  final Comment cmt;
  final String commentListId;

  const UploadingCommentCard(
      {Key? key, required this.cmt, required this.commentListId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 20;

    bool isLiked = false;

    return Container(
      color: secondaryColor,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(cmt.avatarUrl),
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
                        cmt.username,
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
                          getElapsedTime(cmt.createdAt),
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
                  cmt.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          )
        ],
      ),
    );
  }
}
