import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/message.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:video_player/video_player.dart';

import '../../ultis/ultils.dart';

class FullMediaScreen extends StatefulWidget {
  final Message message;
  final String senderName;
  const FullMediaScreen({Key? key, required this.message, required this.senderName}) : super(key: key);

  @override
  State<FullMediaScreen> createState() => _FullMediaScreenState();
}

class _FullMediaScreenState extends State<FullMediaScreen> {
  late VideoPlayerController _controller;
  bool isLoading = true;
  final TransformationController _transformationController = TransformationController();

  void _onInteractionEnd(ScaleEndDetails details) {
    _transformationController.value = Matrix4.identity();
  }

  @override
  void initState() {
    if (widget.message.type == 'video') {
      _controller = VideoPlayerController.network(
          widget.message.content)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            isLoading = false;
            _controller.play();
          });
        });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.message.type == 'video') {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Hero(
          tag: widget.message.content,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GestureDetector(
              child: widget.message.type == 'image' ? InteractiveViewer(
                transformationController: _transformationController,
                onInteractionEnd: _onInteractionEnd,
                panEnabled: false, // Set it to false to prevent panning.
                boundaryMargin: const EdgeInsets.all(80),
                maxScale: 4,
                child: CachedNetworkImage(
                  imageUrl: widget.message.content,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ) : isLoading ? const Center(child: CircularProgressIndicator(),) : AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller))
            ),
          )),
    );
  }

  _buildAppBar(BuildContext context) {
    final UserViewModel userViewModel = UserViewModel();
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.senderName, style: Theme.of(context).textTheme.titleMedium,),
          Text("${getElapsedTime(widget.message.timestamp)} ago", style: Theme.of(context).textTheme.labelMedium,)
        ],
      ),
      actions: [
        InkWell(
          onTap: () async {
            /*if (await widget.messageViewModel.onDownload(widget.message.content)) {
              Fluttertoast.showToast(msg: "Photo saved successfully");
            } else {
              Fluttertoast.showToast(msg: "photo save failed");
            }*/
          },
          child: const Icon(Icons.download, size: 25,),
        ),
        const SizedBox(width: 20,),
      ],
    );
  }
}
