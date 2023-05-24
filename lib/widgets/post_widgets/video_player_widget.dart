import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final File? file;
  final bool isPlay;
  final VideoPlayerController? controller;

  factory VideoPlayerWidget.file(
      {required File file,
      bool isPlay = false,
      VideoPlayerController? controller}) {
    return VideoPlayerWidget(
      videoUrl: null,
      file: file,
      isPlay: isPlay,
    );
  }

  factory VideoPlayerWidget.network(
      {required String url,
      bool isPlay = false,
      VideoPlayerController? controller}) {
    return VideoPlayerWidget(
      videoUrl: url,
      file: null,
      isPlay: isPlay,
      controller: controller,
    );
  }

  const VideoPlayerWidget(
      {super.key,
      required this.videoUrl,
      this.file,
      this.isPlay = false,
      this.controller});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null && widget.controller!.value.isInitialized) {
      widget.controller?.play();
      widget.controller?.setLooping(true);
      setState(() {});
    } else if (widget.videoUrl != null) {
      _controller = VideoPlayerController.network(widget.videoUrl!)
        ..initialize().then((_) {
          widget.isPlay ? _controller.play() : _controller.pause();
          _controller.setLooping(true);
          setState(() {});
        });
    } else if (widget.file != null) {
      _controller = VideoPlayerController.file(widget.file!)
        ..initialize().then((_) {
          widget.isPlay ? _controller.play() : _controller.pause();
          _controller.setLooping(true);
          setState(() {});
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller != null) {
      return widget.controller!.value.isInitialized ? AspectRatio(
        aspectRatio: widget.controller!.value.aspectRatio,
        child: VideoPlayer(widget.controller!),
      )
    : const Center( child: CircularProgressIndicator());
    } else {
      return _controller.value.isInitialized ? AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      )
          : const Center(
        child: CircularProgressIndicator(),
      );
    }

  }

  @override
  void dispose() {
    if (widget.controller == null && _controller.value.isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }
}
