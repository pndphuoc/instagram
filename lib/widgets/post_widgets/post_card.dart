import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/models/notification.dart';
import 'package:instagram/screens/post_screens/comment_reading_screen.dart';
import 'package:instagram/screens/like_list_screen.dart';
import 'package:instagram/screens/post_screens/edit_post_screen.dart';
import 'package:instagram/screens/profile_screens/profile_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/like_view_model.dart';
import 'package:instagram/view_model/notification_view_model.dart';
import 'package:instagram/widgets/animation_widgets/like_animation.dart';
import 'package:instagram/widgets/post_widgets/video_player_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/post.dart';
import '../../ultis/ultils.dart';
import '../confirm_dialog.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late double imageWidth;
  final LikeViewModel _likeViewModel = LikeViewModel();
  late CurrentUserViewModel _currentUserViewModel;
  late NotificationViewModel _notificationViewModel;
  bool isEnableShimmer = true;
  List<VideoPlayerController?> _currentControllers = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _notificationViewModel = context.read<NotificationViewModel>();
    for (int i = 0; i < widget.post.medias.length; i++) {
      if (widget.post.medias[i].type == 'video') {
        _currentControllers
            .add(VideoPlayerController.network(widget.post.medias[i].url)
              ..initialize().then((value) {
                setState(() {});
              }));
      } else {
        _currentControllers.add(null);
      }
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < _currentControllers.length; i++) {
      _currentControllers[i]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    imageWidth = MediaQuery.of(context).size.width - 20;
    return Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: postCardBackgroundColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHead(context),
            const SizedBox(height: 10),
            _buildMediasCarousel(context),
            const SizedBox(
              height: 10,
            ),
            _buildInteractBar(context),
            const SizedBox(
              height: 10,
            ),
            _buildContentBlock(context),
          ],
        ));
  }

  Widget _buildPostHead(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProfileScreen(userId: widget.post.userId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return buildSlideTransition(animation, child);
            },
            transitionDuration: const Duration(milliseconds: 150),
            reverseTransitionDuration: const Duration(milliseconds: 150),
          ),
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            widget.post.avatarUrl.isNotEmpty
                ? CircleAvatar(
                    radius: avatarInPostCardSize,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.post.avatarUrl,
                    ),
                  )
                : const CircleAvatar(
                    radius: avatarInPostCardSize,
                    backgroundImage: AssetImage("assets/default_avatar.png")),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    getElapsedTime(widget.post.createAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _showModal(context, widget.post.uid);
              },
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_horiz),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractBar(BuildContext context) {
    return StreamBuilder(
      stream: _likeViewModel.likeStream,
      initialData: widget.post.isLiked,
      builder: (context, snapshot) {
        return Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {
                _likeViewModel.toggleLikePost(widget.post).then((value) {
                  if (value) {
                    _notificationViewModel.addInteractiveNotification(
                        userId: widget.post.userId,
                        interactiveUserAvatarUrl:
                            _currentUserViewModel.user!.avatarUrl,
                        interactiveUsername:
                            _currentUserViewModel.user!.username,
                        notificationType: NotificationType.like,
                        postId: widget.post.uid,
                        firstImage: widget.post.medias.first.url);
                  }
                });

              },
              child: LikeAnimation(
                  isAnimating: snapshot.data!,
                  child: snapshot.data!
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        LikeListScreen(likeListId: widget.post.likedListId),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return buildSlideTransition(animation, child);
                    },
                    transitionDuration: const Duration(milliseconds: 150),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 150),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
                child: Text(
                  widget.post.likeCount.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        CommentReadingScreen(post: widget.post),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return buildSlideTransition(animation, child);
                    },
                    transitionDuration: const Duration(milliseconds: 150),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 150),
                  ),
                );
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
              widget.post.commentCount.toString(),
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
        );
      },
    );
  }

  Widget _buildMediasCarousel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: GestureDetector(
        onDoubleTap: () {
          if (!widget.post.isLiked) _likeViewModel.toggleLikePost(widget.post);
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CarouselSlider(
                options: CarouselOptions(
                    aspectRatio: 1,
                    reverse: false,
                    scrollPhysics: const BouncingScrollPhysics(),
                    enableInfiniteScroll: false,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) async {
                      setState(() {
                        currentIndex = index;
                      });
                    }),
                items: widget.post.medias.map((e) {
                  if (e.type == 'image') {
                    return CachedNetworkImage(
                        imageUrl: e.url,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 100),
                        placeholder: (_, __) => Shimmer.fromColors(
                              baseColor: const Color.fromARGB(255, 39, 39, 39),
                              highlightColor:
                                  const Color.fromARGB(255, 86, 86, 86),
                              child: const SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ));
                  } else {
                    final index = widget.post.medias.indexOf(e);
                    return _currentControllers[index]!.value.isInitialized
                        ? VisibilityDetector(
                            key: Key(e.url),
                            onVisibilityChanged: (info) {
                              if (info.visibleFraction == 0) {
                                _currentControllers[index]!.pause();
                              } else {
                                _currentControllers[index]!.play();
                              }
                            },
                            child: VideoPlayerWidget(
                                videoUrl: e.url,
                                controller: _currentControllers[index]))
                        : const Center(
                            child: CircularProgressIndicator(),
                          );
                  }
                }).toList(),
              ),
            ),
            if (widget.post.medias.length > 1)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black54),
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 5, bottom: 5),
                  child: Text(
                    "${currentIndex + 1}/${widget.post.medias.length}",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildContentBlock(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CommentReadingScreen(post: widget.post),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return buildSlideTransition(animation, child);
            },
            transitionDuration: const Duration(milliseconds: 150),
            reverseTransitionDuration: const Duration(milliseconds: 150),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpandableText(
              widget.post.caption,
              expandText: 'show more',
              maxLines: 3,
              animation: true,
              expandOnTextTap: true,
              linkColor: Colors.grey,
              linkStyle: GoogleFonts.readexPro(fontWeight: FontWeight.w200),
              animationDuration: const Duration(milliseconds: 500),
              style: GoogleFonts.readexPro(color: Colors.white),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  _showModal(BuildContext context, String postId) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      builder: (context) => IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.remove_rounded,
                size: 40,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      const Icon(
                        Icons.bookmark_border_rounded,
                        size: 35,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Save",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  )),
            ),
            if (widget.post.userId ==
                FirebaseAuth.instance.currentUser!.uid) ...[
              _currentUserViewModel.user!.postIds.contains(widget.post.uid)
                  ? InkWell(
                      onTap: () {
                        _currentUserViewModel
                            .toggleArchivePost(widget.post.uid, true)
                            .whenComplete(() => Navigator.pop(context))
                            .whenComplete(() => Navigator.pop(context));
                      },
                      child: Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(Icons.archive_outlined, size: 35),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Archive",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          )),
                    )
                  : InkWell(
                      onTap: () {
                        _currentUserViewModel
                            .toggleArchivePost(widget.post.uid, false)
                            .whenComplete(() => Navigator.pop(context))
                            .whenComplete(() => Navigator.pop(context));
                      },
                      child: Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(Icons.archive_outlined, size: 35),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Unarchive",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          )),
                    ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPostScreen(post: widget.post),
                      ));
                },
                child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(Icons.edit_outlined, size: 35),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Edit",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    )),
              ),
              InkWell(
                onTap: () {
                  _onTap();
                },
                child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          Icons.delete_outline_rounded,
                          size: 35,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Delete",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    )),
              ),
            ],
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  _onTap() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const ConfirmDialog(
        confirmButtonText: "Delete",
        confirmText: "Delete this post?",
        description:
            "Are you sure to delete this post? This action cannot be undone.",
        isUnfollow: false,
      ),
    );
    if (result) {
      _currentUserViewModel.deletePost(widget.post.uid).whenComplete(() {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }
}
