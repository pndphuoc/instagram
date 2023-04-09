import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/models/comment.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/comment_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/comment_card.dart';
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

  final double avatarSize = 25;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: avatarSize,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.post.avatarUrl.toString(),),
                  ),
                  const SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post.username, style: Theme
                          .of(context)
                          .textTheme
                          .titleSmall,),
                      Text(widget.post.caption, style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium,)
                    ],
                  )
                ],
              ),
            ),
            const Divider(color: Colors.white38,),
          ],
        ),
      ),
      bottomNavigationBar: _writeCommentBlock(context),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text("Comment", style: Theme
          .of(context)
          .textTheme
          .titleLarge,),
    );
  }

  _onPostButtonPressed() {
    Comment comment = Comment(uid: '',
        authorId: _currentUserViewModel.user!.uid,
        username: _currentUserViewModel.user!.username,
        avatarUrl: _currentUserViewModel.user!.avatarUrl,
        content: _commentController.text,
        likedListId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());

    _commentViewModel.addComment(widget.post.uid, widget.post.commentedListId, comment);
  }

  Widget _writeCommentBlock(BuildContext context) {
    return Padding(
      padding: MediaQuery
          .of(context)
          .viewInsets,
      child: Container(
        color: secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: _currentUserViewModel.user!.avatarUrl.isNotEmpty
                  ?
              CachedNetworkImageProvider(_currentUserViewModel.user!.avatarUrl)
                  :
              const AssetImage('assets/default_avatar.png') as ImageProvider<
                  Object>?,
            ),
            const SizedBox(width: 20,),
            Expanded(child: TextField(
              controller: _commentController,
              maxLines: null,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  hintText: "Comment for ${widget.post.username}",
                  hintStyle: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
              ),
            ),),
            const SizedBox(width: 20,),
            GestureDetector(
              onTap: _onPostButtonPressed,
              child: SizedBox(
                  height: 30,
                  child: Text(
                    "Post", style: GoogleFonts.readexPro(color: Colors.blue),)),
            )
          ],
        ),
      ),
    );
  }
}
