import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/comment_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/like_view_model.dart';
import 'package:instagram/widgets/animation_widgets/like_animation.dart';
import 'package:instagram/widgets/post_widgets/reply_comment_card.dart';
import 'package:provider/provider.dart';

import '../../ultis/ultils.dart';

class CommentCard extends StatefulWidget {
  final Comment cmt;
  final String commentListId;
  final Color backgroundColor;
  final CommentViewModel commentViewModel;
  final String postId;

  const CommentCard({
    Key? key,
    required this.cmt,
    required this.commentListId,
    this.backgroundColor = Colors.transparent,
    required this.commentViewModel,
    required this.postId,
  }) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isLiked = false;
  final LikeViewModel _likeViewModel = LikeViewModel();
  late CurrentUserViewModel _currentUserViewModel;
  late CommentViewModel _localCommentViewModel;
  List<Comment> replyComments = [];
  late Stream<List<Comment>> _getReplyComments;

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _localCommentViewModel = CommentViewModel(widget.commentListId, widget.cmt.uid);
    _localCommentViewModel.replyCount = widget.cmt.replyCount;
    _getReplyComments = _localCommentViewModel.replyCommentsStream;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: widget.backgroundColor,
      child: Column(
        children: [
          _buildCommentContent(context),
          _buildReplyComments(context),
          _buildReadMoreCommentsButton(context)
        ],
      ),
    );
  }

  Widget _buildCommentContent(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        if (widget.cmt.authorId == _currentUserViewModel.user!.uid) {
          _localCommentViewModel.onCommentLongPress(widget.cmt);
          await _showModalSheet(widget.commentListId, widget.cmt.uid)
              .whenComplete(() => _localCommentViewModel.cancelCommentLongPress());
        }
      },
      child: StreamBuilder(
          stream: _localCommentViewModel.selectingCommentStream,
          initialData: false,
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              color: snapshot.data! ? Colors.white24 : mobileBackgroundColor,
              child: Row(
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
                        GestureDetector(
                          onTap: () {
                            widget.commentViewModel.onReplyButtonTap(
                                widget.cmt.username,
                                widget.cmt.uid,
                                replyComments);
                          },
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
                      onTap: () {
                        _likeViewModel.toggleLike(widget.cmt);
                      },
                      onLongPress: () {},
                      child: Container(
                        color: Colors.transparent,
                        child: StreamBuilder(
                            stream: _likeViewModel.likeStream,
                            initialData: widget.cmt.isLiked,
                            builder: (context, snapshot) {
                              widget.cmt.isLiked = snapshot.data!;
                              return Column(
                                children: [
                                  LikeAnimation(
                                    isAnimating: snapshot.data!,
                                    child: snapshot.data!
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
                              );
                            }),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }

  Widget _buildReplyComments(BuildContext context) {
    return StreamBuilder<List<Comment>>(
      stream: _getReplyComments,
      initialData: const [],
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          replyComments.addAll(snapshot.data!.where((element) => !replyComments.contains(element)));
          return ListView.separated(
            itemCount: replyComments.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: 15,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ReplyCommentCard(
                  commentListId: widget.commentListId,
                  commentId: widget.cmt.uid,
                  replyComment: replyComments[index],
                  commentViewModel: widget.commentViewModel,
                  replyComments: replyComments,
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildReadMoreCommentsButton(BuildContext context) {
    if (widget.cmt.replyCount > 0) {
      return Container(
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
            Expanded(
              child: StreamBuilder(
                  stream: _localCommentViewModel.replyCountController.stream,
                  initialData: _localCommentViewModel.replyCount,
                  builder: (context, snapshot) {
                    if (snapshot.data! > 0) {
                      return GestureDetector(
                        onTap: () {
                          _localCommentViewModel.getReplyComments(commentId: widget.cmt.uid);
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "See ${snapshot.data} reply comments",
                            style: Theme.of(context).textTheme.labelMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          _localCommentViewModel
                              .hideAllReplyComments(widget.cmt.replyCount);
                          replyComments = [];
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          color: Colors.transparent,
                          child: Text(
                            "Hide all reply comments",
                            style: Theme.of(context).textTheme.labelMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }
                  }),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Future _showModalSheet(String commentListId, String commentId) {
    return showModalBottomSheet(
      backgroundColor: secondaryColor,
      context: context,
      builder: (context) {
        return IntrinsicHeight(
          child: Column(
            children: [
              InkWell(
                onTap: () {},
                child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Edit",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    )),
              ),
              InkWell(
                onTap: () {
                  _deleteHandle(commentListId, commentId);
                },
                child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Delete",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    )),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm delete'),
          content: const Text(
              'Are you sure you want to delete this? This action cannot be undone.'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future _deleteHandle(String commentListId, String commentId) async {
    await _showDeleteConfirmationDialog().then((value) async {
      if (value) {
        await widget.commentViewModel
            .deleteComment(commentListId, commentId, widget.postId)
            .then((isDeleted) {
          Navigator.pop(context);
          if (isDeleted) {
            showSnackBar(context, "Delete successful");
          } else {
            showSnackBar(context, "Delete failed");
          }
        });
      }
    });
  }
}
