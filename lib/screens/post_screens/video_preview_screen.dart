import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/post_screens/add_caption_screen.dart';
import 'dart:io';

import 'package:instagram/ultis/colors.dart';
import 'package:video_player/video_player.dart';

import '../../ultis/ultils.dart';

class VideoPreviewScreen extends StatefulWidget {
  final XFile video;
  const VideoPreviewScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController  _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.file(File(widget.video.path))
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _controller.setLooping(true);
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: VideoPlayer(_controller),
                  ),
                ),
                const SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
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
                  ),
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
    _controller.pause();
    Navigator.push(
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
    ).then((value) => _controller.play());
  }
}
