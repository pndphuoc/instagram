import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/provider/home_screen_provider.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/image_thumbail.dart';
import 'package:mime/mime.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../models/post.dart';

class AddCaptionScreen extends StatefulWidget {
  final File? media;

  const AddCaptionScreen({Key? key, this.media}) : super(key: key);

  @override
  State<AddCaptionScreen> createState() => _AddCaptionScreenState();
}

class _AddCaptionScreenState extends State<AddCaptionScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String? mimeType;
  late VideoPlayerController _videoController;
  bool _isVideoFromCamera = false;

  @override
  void initState() {
    if (widget.media != null) {
      mimeType = lookupMimeType(widget.media!.path);
      if (mimeType != null && mimeType!.startsWith('video/')) {
        _isVideoFromCamera = true;
        _videoController = VideoPlayerController.file(File(widget.media!.path))
          ..initialize().then((_) {
            setState(() {});
          });
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_isVideoFromCamera) {
      _videoController.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double previewMediaSize = MediaQuery.of(context).size.width / 6;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(context),
      body: Container(
        color: mobileBackgroundColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            if (_isVideoFromCamera)
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                    Positioned.fill(
                        child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.play_circle_outline_outlined,
                            color: Colors.black54,
                            size: 40,
                          )),
                    ))
                  ],
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Consumer<CurrentUserViewModel>(
                  builder: (context, value, child) {
                    return CircleAvatar(
                      radius: 25,
                      backgroundImage: value.user!.avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(value.user!.avatarUrl)
                          : const AssetImage("assets/default_avatar.png")
                              as ImageProvider,
                    );
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 3,
                    decoration: const InputDecoration(
                        hintText: "Write caption",
                        contentPadding: EdgeInsets.all(5),
                        filled: true,
                        fillColor: postCardBackgroundColor,
                        disabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none)),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (!_isVideoFromCamera)
                  Consumer<AssetViewModel>(
                    builder: (context, value, child) => SizedBox(
                      height: previewMediaSize,
                      width: previewMediaSize,
                      child: widget.media != null
                          ? Image.file(
                              widget.media!,
                              height: 100,
                              width: 100,
                            )
                          : ImageItemWidget(
                              entity: value.selectedEntities.isEmpty
                                  ? value.selectedEntity!
                                  : value.selectedEntities.first,
                              option: const ThumbnailOption(
                                  size: ThumbnailSize.square(100))),
                    ),
                  ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _uploadNewPost(BuildContext context) {
    final user = context.read<CurrentUserViewModel>();
    final asset = context.read<AssetViewModel>();

    context.read<HomeScreenProvider>().currentIndex = 0;

    asset.onUploadButtonTap(file: widget.media);
    Navigator.popUntil(context, (route) => route.isFirst);

    context
        .read<PostViewModel>()
        .onUploadButtonTap(_controller.text, user.user!, asset);
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text(
        "Add caption",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            _uploadNewPost(context);
          },
          child: const SizedBox(
            height: kToolbarHeight,
            width: kToolbarHeight,
            child: Icon(
              Icons.done_outlined,
              color: Colors.blue,
              size: 30,
            ),
          ),
        )
      ],
    );
  }
}
