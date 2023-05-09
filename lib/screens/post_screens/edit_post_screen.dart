import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/post.dart';
import '../../ultis/global_variables.dart';
import '../../ultis/ultils.dart';
import '../../widgets/post_widgets/video_player_widget.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({Key? key, required this.post}) : super(key: key);
  final Post post;

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final List<VideoPlayerController?> _currentControllers = [];
  final TextEditingController _textEditingController = TextEditingController();
  late PostViewModel _postViewModel;
  late CurrentUserViewModel _currentUserViewModel;

  @override
  void initState() {
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _postViewModel = context.read<PostViewModel>();
    _textEditingController.text = widget.post.caption;
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
    super.initState();
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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              _buildPostHead(context),
              const SizedBox(
                height: 10,
              ),
              _buildMediasCarousel(context),
              const SizedBox(
                height: 10,
              ),
              TextField(
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 15, right: 15)),
                maxLines: null,
                controller: _textEditingController,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostHead(BuildContext context) {
    return Row(
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
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Widget _buildMediasCarousel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 1,
              reverse: false,
              scrollPhysics: const BouncingScrollPhysics(),
              enableInfiniteScroll: false,
              viewportFraction: 1,
              onPageChanged: (index, reason) async {
                //_onPageChanged(index);
              }),
          items: widget.post.medias.map<Widget>((e) {
            if (e.type == 'image') {
              return CachedNetworkImage(
                  imageUrl: e.url,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 100),
                  placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: const Color.fromARGB(255, 39, 39, 39),
                        highlightColor: const Color.fromARGB(255, 86, 86, 86),
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
    );
  }

  _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(
        "Edit post",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        const SizedBox(
          width: 20,
        ),
        Selector<CurrentUserViewModel, bool>(
            selector: (context, currentUserViewModel) =>
                currentUserViewModel.isLoading,
            builder: (context, value, child) {
              if (value) {
                return const SizedBox(
                    height: 50,
                    width: 50,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ));
              } else {
                return GestureDetector(
                    onTap: () {
                      _currentUserViewModel
                          .updatePostCaption(
                              post: widget.post,
                              caption: _textEditingController.text)
                          .whenComplete(() => Navigator.pop(context));
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.check,
                        color: primaryColor,
                        size: 30,
                      ),
                    ));
              }
            })
      ],
    );
  }
}
