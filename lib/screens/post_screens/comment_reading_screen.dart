import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/comment_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/post_widgets/comment_card.dart';
import 'package:instagram/widgets/shimmer_widgets/comment_shimmer.dart';
import 'package:instagram/widgets/animation_widgets/show_up_widget.dart';
import 'package:instagram/widgets/post_widgets/uploading_comment_cart.dart';
import 'package:provider/provider.dart';

import '../../models/post.dart';

class CommentReadingScreen extends StatefulWidget {
  final Post post;

  const CommentReadingScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<CommentReadingScreen> createState() => _CommentReadingScreenState();
}

class _CommentReadingScreenState extends State<CommentReadingScreen> {
  late CurrentUserViewModel _currentUserViewModel;

  final TextEditingController _commentController = TextEditingController();
  late CommentViewModel _commentViewModel;
  final ScrollController _scrollController = ScrollController();
  final double avatarSize = 25;
  final myFocusNode = FocusNode();
  List<Comment> comments = [];
  late Future _getComments;

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();

    _commentViewModel = CommentViewModel(
        widget.post.commentListId, widget.post.uid);

    _getComments =
        _commentViewModel.getComments();

    _scrollController.addListener(() {
      if (_commentViewModel.hasMoreToLoad &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) {
        _commentViewModel.getMoreComments();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
    _commentViewModel.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: _appBar(context),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _postContent(context),
                    const Divider(
                      color: Colors.white38,
                    ),
                    FutureBuilder(
                      future: _getComments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            children: const [
                              CommentShimmer(),
                              CommentShimmer(),
                              CommentShimmer(),
                              CommentShimmer(),
                              CommentShimmer(),
                              CommentShimmer(),
                              CommentShimmer(),
                              CommentShimmer(),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return StreamBuilder(
                            stream: _commentViewModel.commentsStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                    height: 15,
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _commentViewModel.hasMoreToLoad
                                      ? _commentViewModel.comments.length + 1
                                      : _commentViewModel.comments.length,
                                  itemBuilder: (context, index) {
                                    if (index >= _commentViewModel.comments.length) {
                                      return const CommentShimmer();
                                    } else if (_commentViewModel.comments[index].uid != '') {
                                      return CommentCard(
                                        cmt: _commentViewModel.comments[index],
                                        commentListId:
                                            widget.post.commentListId,
                                        commentViewModel: _commentViewModel,
                                        postId: widget.post.uid,
                                      );
                                    } else {
                                      return UploadingCommentCard(
                                          cmt: comments[index],
                                          commentListId:
                                              widget.post.commentListId);
                                    }
                                  },
                                );
                              } else {
                                return Container();
                              }
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(
                      height: kBottomNavigationBarHeight + 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0, left: 0, right: 0, child: _writeCommentBlock(context))
        ],
      ),
    );
  }

  Widget _postContent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: avatarSize,
            backgroundImage: CachedNetworkImageProvider(
              widget.post.avatarUrl.toString(),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.username,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  widget.post.caption,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(
        "Comment",
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _writeCommentBlock(BuildContext context) {
    return Column(
      children: [
        StreamBuilder(
            stream: _commentViewModel.usernameIsBeingRepliedStream,
            initialData: '',
            builder: (context, snapshot) {
              if (snapshot.data!.isNotEmpty) {
                return ShowUp(
                  delay: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text("Answering ${snapshot.data}",
                              style: const TextStyle(color: Colors.black)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            onTap: () {
                              _commentViewModel.onCancelReplyCommentTap();
                            },
                            child: const Icon(Icons.close),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }),
        Container(
          color: secondaryBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    _currentUserViewModel.user!.avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(
                            _currentUserViewModel.user!.avatarUrl)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider<Object>?,
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextField(
                  focusNode: _commentViewModel.commentFocusNode,
                  controller: _commentViewModel.commentTextField,
                  autofocus: true,
                  maxLines: null,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: "Comment for ${widget.post.username}",
                      hintStyle: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  _commentViewModel.onPostButtonPressed(
                      widget.post.commentListId,
                      _currentUserViewModel.chatUser,
                      _scrollController,
                      comments);
                },
                child: SizedBox(
                    height: 30,
                    child: Text(
                      "Post",
                      style: GoogleFonts.readexPro(color: Colors.blue),
                    )),
              )
            ],
          ),
        ),
      ],
    );
  }
}
