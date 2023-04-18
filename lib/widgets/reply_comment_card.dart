import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/provider/comment_text_field_provider.dart';
import 'package:instagram/view_model/comment_view_model.dart';
import 'package:provider/provider.dart';

import '../models/comment.dart';
import 'package:flutter/material.dart';

import '../ultis/global_variables.dart';
import '../ultis/ultils.dart';
import '../view_model/current_user_view_model.dart';
import '../view_model/like_view_model.dart';
import 'like_animation.dart';

class ReplyCommentCard extends StatefulWidget {
  final String commentListId;
  final String commentId;
  final String usernameOfCommentIsBeingReplied;
  final Comment replyComment;

  const ReplyCommentCard({
    Key? key,
    required this.commentListId,
    required this.commentId,
    required this.replyComment,
    required this.usernameOfCommentIsBeingReplied,
  }) : super(key: key);

  @override
  State<ReplyCommentCard> createState() => _ReplyCommentCardState();
}

class _ReplyCommentCardState extends State<ReplyCommentCard> {
  final LikeViewModel _likeViewModel = LikeViewModel();
  final CommentViewModel _commentViewModel = CommentViewModel();
  late CurrentUserViewModel _currentUserViewModel;

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 55),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage:
                CachedNetworkImageProvider(widget.replyComment.avatarUrl),
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
                        widget.replyComment.username,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      getElapsedTime(widget.replyComment.createdAt),
                      style: GoogleFonts.readexPro(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                          fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.replyComment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 5,
                ),
                Consumer<CommentTextFieldProvider>(
                  builder: (context, value, child) => GestureDetector(
                    onTap: () {
                      value.textEditingController.text =
                          "@${widget.replyComment.username}";
                    },
                    child: Text(
                      "Reply",
                      style: GoogleFonts.readexPro(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                          fontSize: 12),
                    ),
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
                      child: widget.replyComment.isLiked
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
                    Text(widget.replyComment.likeCount.toString()),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _toggleLike() {
    if (widget.replyComment.isLiked) {
      _likeViewModel.unlike(
          widget.replyComment.likedListId, _currentUserViewModel.user!.uid);
      widget.replyComment.likeCount--;
      //_commentViewModel.unlikeComment(widget.commentListId, widget.cmt.uid);
    } else {
      _likeViewModel.like(
          widget.replyComment.likedListId, _currentUserViewModel.user!.uid);
      widget.replyComment.likeCount++;
      //_commentViewModel.likeComment(widget.commentListId, widget.cmt.uid);
    }
    setState(() {
      widget.replyComment.isLiked = !widget.replyComment.isLiked;
    });
  }
}
