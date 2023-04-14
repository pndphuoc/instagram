import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/comment_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/like_view_model.dart';
import 'package:instagram/widgets/like_animation.dart';
import 'package:provider/provider.dart';

import '../ultis/ultils.dart';

class CommentCard extends StatefulWidget {
  final Comment cmt;
  final String commentListId;
  final Color backgroundColor;

  const CommentCard(
      {Key? key,
      required this.cmt,
      required this.commentListId,
      this.backgroundColor = Colors.transparent})
      : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isLiked = false;

  final LikeViewModel _likeViewModel = LikeViewModel();
  late CurrentUserViewModel _currentUserViewModel;
  final CommentViewModel _commentViewModel = CommentViewModel();

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
  }

  _toggleLike() {
    if (widget.cmt.isLiked) {
      _likeViewModel.unlike(
          widget.cmt.likedListId, _currentUserViewModel.user!.uid);
      widget.cmt.likeCount--;
      //_commentViewModel.unlikeComment(widget.commentListId, widget.cmt.uid);
    } else {
      _likeViewModel.like(
          widget.cmt.likedListId, _currentUserViewModel.user!.uid);
      widget.cmt.likeCount++;
      //_commentViewModel.likeComment(widget.commentListId, widget.cmt.uid);
    }
    setState(() {
      widget.cmt.isLiked = !widget.cmt.isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: widget.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.cmt.avatarUrl),
            radius: avatarInPostCardSize,
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
            child: GestureDetector(
              onTap: _toggleLike,
              onLongPress: () {},
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    LikeAnimation(
                      isAnimating: _likeViewModel.isLikeAnimating,
                      child: widget.cmt.isLiked
                          ? const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 17,
                            )
                          : const Icon(
                              Icons.favorite_border,
                              size: 17,
                            ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(widget.cmt.likeCount.toString()),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
