import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/comment_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/like_view_model.dart';
import 'package:instagram/widgets/like_animation.dart';
import 'package:instagram/widgets/reply_comment_card.dart';
import 'package:provider/provider.dart';

import '../provider/comment_text_field_provider.dart';
import '../ultis/ultils.dart';

class CommentCard extends StatefulWidget {
  final Comment cmt;
  final String commentListId;
  final Color backgroundColor;

  const CommentCard({
    Key? key,
    required this.cmt,
    required this.commentListId,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isLiked = false;
  List<Comment> replyCommentList = [];
  final LikeViewModel _likeViewModel = LikeViewModel();
  late CurrentUserViewModel _currentUserViewModel;
  final CommentViewModel _commentViewModel = CommentViewModel();

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _commentViewModel.replyCount = widget.cmt.replyCount;
  }

  _toggleLike() {
    if (widget.cmt.isLiked) {
      _likeViewModel.unlike(
          widget.cmt.likedListId, _currentUserViewModel.user!.uid);
      widget.cmt.likeCount--;
    } else {
      _likeViewModel.like(
          widget.cmt.likedListId, _currentUserViewModel.user!.uid);
      widget.cmt.likeCount++;
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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(widget.cmt.avatarUrl),
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
                        Text(
                          getElapsedTime(widget.cmt.createdAt),
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
                      widget.cmt.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Consumer<CommentTextFieldProvider>(
                      builder: (context, value, child) {
                        return GestureDetector(
                          onTap: () {
                            value.onReplyButtonTap(widget.cmt.username, widget.cmt.uid);
                          },
                          child: Text(
                            "Reply",
                            style: GoogleFonts.readexPro(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300,
                                fontSize: 12),
                          ),
                        );
                      },
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
          const SizedBox(
            height: 15,
          ),
          StreamBuilder(
            stream: _commentViewModel.replyCommentsStream,
            initialData: const [],
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return ListView.separated(
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 15,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ReplyCommentCard(
                      commentListId: widget.commentListId,
                      commentId: widget.cmt.uid,
                      replyComment: snapshot.data![index],
                      usernameOfCommentIsBeingReplied: widget.cmt.username,
                    );
                  },
                );
              }
            },
          ),
          if (widget.cmt.replyCount > 0)
            Container(
              padding: const EdgeInsets.only(top: 5, left: 55),
              margin: const EdgeInsets.only(top: 5),
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  const SizedBox(
                    width: 30,
                    child: Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  StreamBuilder(
                      stream: _commentViewModel.replyCountController.stream,
                      initialData: _commentViewModel.replyCount,
                      builder: (context, snapshot) {
                        if (snapshot.data! > 0) {
                          return GestureDetector(
                            onTap: () {
                              _commentViewModel.getReplyComments(
                                  commentListId: widget.commentListId,
                                  commentId: widget.cmt.uid,
                                  userId: _currentUserViewModel.user!.uid);
                            },
                            child: Text(
                              "See ${snapshot.data} reply comments",
                              style: Theme.of(context).textTheme.labelMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              _commentViewModel
                                  .hideAllReplyComments(widget.cmt.replyCount);
                            },
                            child: Text(
                              "Hide all reply comments",
                              style: Theme.of(context).textTheme.labelMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                      }),
                ],
              ),
            )
        ],
      ),
    );
  }
}
