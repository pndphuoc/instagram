import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/screens/post_detais_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/like_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:instagram/widgets/like_animation.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/post.dart';
import '../ultis/ultils.dart';

class PostCard extends StatefulWidget {
  final String postId;

  const PostCard({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final double avatarHeight = 20;
  final double avatarWidth = 20;
  late double imageWidth;
  final LikeViewModel _likeViewModel = LikeViewModel();
  final PostViewModel _postViewModel = PostViewModel();
  late CurrentUserViewModel _currentUserViewModel;
  late Future _getPost;

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _getPost = _postViewModel
        .getPost(widget.postId, _likeViewModel, _currentUserViewModel.user!.uid);
  }

  void _toggleLikePost(snapshot) {
    final currentUserViewModel = context.read<CurrentUserViewModel>();
    if (!_likeViewModel.isLiked) {
      _likeViewModel.like(widget.postId, snapshot.data!.likedListId,
          currentUserViewModel.user!.uid);
      snapshot.data!.likeCount++;
    } else {
      _likeViewModel.unlike(widget.postId, snapshot.data!.likedListId,
          currentUserViewModel.user!.uid);
      snapshot.data!.likeCount--;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    imageWidth = MediaQuery.of(context).size.width - 20;
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: postCardBackgroundColor),
      child: FutureBuilder(
        future: _getPost,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _likeViewModel.isLikeAnimating = _likeViewModel.isLiked;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    snapshot.data!.avatarUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: avatarHeight,
                            backgroundImage: CachedNetworkImageProvider(
                              snapshot.data!.avatarUrl,
                            ),
                          )
                        : CircleAvatar(
                            radius: avatarHeight,
                            backgroundImage:
                                const AssetImage("assets/default_avatar.png")),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data!.username,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            getElapsedTime(snapshot.data!.createAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_horiz),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: GestureDetector(
                    onDoubleTap: () {
                      if (!_likeViewModel.isLiked) _toggleLikePost(snapshot);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: CarouselSlider(
                        options: CarouselOptions(
                            aspectRatio: 1,
                            reverse: false,
                            scrollPhysics: const BouncingScrollPhysics(),
                            enableInfiniteScroll: false,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) async {}),
                        items: snapshot.data!.mediaUrls.map<Widget>((e) {
                          return CachedNetworkImage(
                              imageUrl: e,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 100),
                              placeholder: (_, __) => Shimmer.fromColors(
                                    baseColor:
                                        const Color.fromARGB(255, 39, 39, 39),
                                    highlightColor:
                                        const Color.fromARGB(255, 86, 86, 86),
                                    child: const SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ));
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () => _toggleLikePost(snapshot),
                      child: LikeAnimation(
                          isAnimating: _likeViewModel.isLikeAnimating,
                          child: _likeViewModel.isLiked
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.favorite_border,
                                  size: 30,
                                )),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      snapshot.data!.likeCount.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailsScreen(post: snapshot.data!),
                            ));
                      },
                      child: SvgPicture.asset(
                        "assets/ic_comment.svg",
                        height: 28,
                        width: 28,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      snapshot.data!.commentCount.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SvgPicture.asset(
                      "assets/ic_share.svg",
                      height: 28,
                      width: 28,
                    ),
                    const Expanded(child: SizedBox()),
                    SvgPicture.asset(
                      "assets/ic_bookmark.svg",
                      height: 28,
                      width: 28,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: ExpandableText(
                    snapshot.data!.caption,
                    expandText: 'show more',
                    collapseText: 'show less',
                    maxLines: 3,
                    animation: true,
                    collapseOnTextTap: true,
                    expandOnTextTap: true,
                    linkColor: Colors.grey,
                    linkStyle:
                        GoogleFonts.readexPro(fontWeight: FontWeight.w200),
                    animationDuration: const Duration(milliseconds: 500),
                    style: GoogleFonts.readexPro(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: GestureDetector(
                    onTap: () {},
                    child: Text("See all comments",
                        style: Theme.of(context).textTheme.labelLarge),
                  ),
                )
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Text("Error: ${snapshot.error.toString()}");
          }
        },
      ),
    );
  }
}
