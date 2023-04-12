import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/ultis/ultils.dart';
import 'package:instagram/view_model/comment_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/comment_card.dart';
import 'package:instagram/widgets/comment_shimmer.dart';
import 'package:instagram/widgets/uploading_comment_cart.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';

class PostDetailsScreen extends StatefulWidget {
  final Post post;

  const PostDetailsScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  late CurrentUserViewModel _currentUserViewModel;

  final TextEditingController _commentController = TextEditingController();
  final CommentViewModel _commentViewModel = CommentViewModel();
  final ScrollController _scrollController = ScrollController();
  final double avatarSize = 25;
  final myFocusNode = FocusNode();
  List<Comment> comments = [];
  late Future _getComments;

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();

    _getComments = _commentViewModel.getComments(
        commentListId: widget.post.commentListId,
        userId: _currentUserViewModel.user!.uid);

    _scrollController.addListener(() {
      if (_commentViewModel.hasMoreToLoad &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) {
        _commentViewModel.getMoreComments(
            commentListId: widget.post.commentListId,
            likeListId: widget.post.likedListId,
            userId: _currentUserViewModel.user!.uid);
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
            onTap: () {
              myFocusNode.unfocus();
            },
            onVerticalDragDown: (_) {
              myFocusNode.unfocus();
            },
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
                                comments.addAll(snapshot.data!);
                                snapshot.data!.clear();

                                return ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                    height: 15,
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _commentViewModel.hasMoreToLoad
                                      ? comments.length + 1
                                      : comments.length,
                                  itemBuilder: (context, index) {
                                    if (index >= comments.length) {
                                      return const CommentShimmer();
                                    } else if (comments[index].uid != '') {
                                      return GestureDetector(
                                        onLongPress: () {
                                          _showModalSheet(
                                              widget.post.commentListId,
                                              comments[index].uid);
                                        },
                                        child: CommentCard(
                                          cmt: comments[index],
                                          commentListId:
                                              widget.post.commentListId,
                                        ),
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
              bottom: 0,
              left: 0,
              right: 0,
              child: _writeCommentBlock(context))
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

  _onPostButtonPressed() {
    if (_commentController.text.isEmpty) {
      return;
    }

    final comment = Comment(
      uid: '',
      authorId: _currentUserViewModel.user!.uid,
      username: _currentUserViewModel.user!.username,
      avatarUrl: _currentUserViewModel.user!.avatarUrl,
      content: _commentController.text,
      likedListId: '',
      likeCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    comments.insert(0, comment);

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );

    _commentViewModel.addComment(
      widget.post.uid,
      widget.post.commentListId,
      comment,
    );

    myFocusNode.unfocus();
    _commentController.clear();
  }

  Widget _writeCommentBlock(BuildContext context) {
    return Container(
      color: secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: _currentUserViewModel.user!.avatarUrl.isNotEmpty
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
              focusNode: myFocusNode,
              controller: _commentController,
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
            onTap: _onPostButtonPressed,
            child: SizedBox(
                height: 30,
                child: Text(
                  "Post",
                  style: GoogleFonts.readexPro(color: Colors.blue),
                )),
          )
        ],
      ),
    );
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
        await _commentViewModel.deleteComment(
            commentListId, commentId, widget.post.uid).then((isDeleted) {
          Navigator.pop(context);
          if (isDeleted) {

            setState(() {
              comments.removeWhere((element) => element.uid == commentId);
            });

            showSnackBar(context, "Delete successful");
          } else {
            showSnackBar(context, "Delete failed");
          }
        });
      }
    });
  }
}
