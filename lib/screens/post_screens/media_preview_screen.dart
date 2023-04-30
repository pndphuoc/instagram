import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/post_screens/add_caption_screen.dart';
import 'dart:io';

import 'package:instagram/ultis/colors.dart';
import 'package:video_player/video_player.dart';

import '../../ultis/ultils.dart';

class MediaPreviewScreen extends StatefulWidget {
  final XFile? video;
  final File? image;
  final bool isSendMessage;

  factory MediaPreviewScreen.video({required XFile video, bool isSendMessage = false}) {
    return MediaPreviewScreen(video: video, isSendMessage: isSendMessage,);
  }

  factory MediaPreviewScreen.image({required File image, bool isSendMessage = false}) {
    return MediaPreviewScreen(image: image, isSendMessage: isSendMessage,);
  }

  const MediaPreviewScreen({Key? key, this.video, this.image, required this.isSendMessage}) : super(key: key);

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  late VideoPlayerController  _controller;

  @override
  void initState() {
    if (widget.video != null) {
      _controller = VideoPlayerController.file(File(widget.video!.path))
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _controller.setLooping(true);
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.video != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                widget.video != null && widget.image == null ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: VideoPlayer(_controller),
                  ),
                ) : ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.file(widget.image!),
                ),
                const SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerRight,
                  child:  widget.isSendMessage ? _buildSendButton(context) : _buildNextButton(context)
                ),
              ],
            ),
            Positioned(
                left: 10,
                right: 10,
                top: 10,
                child: _actionBar(context))
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return GestureDetector(
      onTap: _onNextButtonTap,
      child: Container(
        height: 45,
        padding: const EdgeInsets.only(left: 15, right: 15),
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(25)
        ),
        child: IntrinsicWidth(
          child: Row(
            children: const [
              Text("Next", style: TextStyle(color: Colors.white),),
              SizedBox(width: 5,),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 15,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return GestureDetector(
      onTap: _onNextButtonTap,
      child: Container(
        height: 45,
        padding: const EdgeInsets.only(left: 15, right: 15),
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(25)
        ),
        child: IntrinsicWidth(
          child: Row(
            children: const [
              Text("Send", style: TextStyle(color: Colors.white),),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onTap: (){
          Navigator.pop(context);
        }),
        _buildActionButton(icon: const Icon(Icons.download_rounded), onTap: (){}),
      ],
    );
  }

  Widget _buildActionButton({required Icon icon, required void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54
        ),
        child: icon,
      ),
    );
  }

  _onNextButtonTap() {
    if (widget.video != null) {
      _controller.pause();
      Navigator.pop(context, [File(widget.video!.path), 'video']);
    } else {
      Navigator.pop(context, [File(widget.image!.path), 'image']);
    }
/*    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation,
            secondaryAnimation) =>
            AddCaptionScreen(media: File(widget.video.path)),
        transitionsBuilder: (context,
            animation,
            secondaryAnimation,
            child) {
          return buildSlideTransition(
              animation, child);
        },
        transitionDuration:
        const Duration(milliseconds: 150),
        reverseTransitionDuration:
        const Duration(milliseconds: 150),
      ),
    ).then((value) => _controller.play());*/
  }
}
