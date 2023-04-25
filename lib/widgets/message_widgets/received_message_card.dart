import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_summary_information.dart';
import 'package:instagram/screens/message_screens/view_full_media_screen.dart';
import 'package:instagram/widgets/avatar_with_status.dart';

import '../../models/message.dart';

class ReceivedMessageCard extends StatefulWidget {
  final Message message;
  final bool isLastInGroup;
  final bool isFirstInGroup;
  final UserSummaryInformation user;

  const ReceivedMessageCard(
      {Key? key,
      required this.message,
      required this.user,
      this.isLastInGroup = false,
      this.isFirstInGroup = false})
      : super(key: key);

  @override
  State<ReceivedMessageCard> createState() => _ReceivedMessageCardState();
}

class _ReceivedMessageCardState extends State<ReceivedMessageCard> {
  final double borderRadius = 20;
  final double avatarSize = 15;
  bool isLoading = true;
  late double heightOfVideo;
  late VideoPlayerController _controller;

  @override
  void initState() {
    if (widget.message.type == 'video') {
      _controller = VideoPlayerController.network(widget.message.content)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          heightOfVideo = MediaQuery.of(context).size.width /
              2 /
              _controller.value.aspectRatio;
          setState(() {
            isLoading = false;
          });
        });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.message.type == 'video') {
      _controller.dispose();
    }
  }

  double calculateMargin() {
    if (widget.isFirstInGroup && widget.isLastInGroup) {
      return 10;
    } else if (widget.isLastInGroup) {
      return 2;
    } else if (widget.isFirstInGroup) {
      return 10;
    } else {
      return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: calculateMargin()),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 10,
          ),
          widget.isLastInGroup
              ? CircleAvatar(
                  radius: avatarSize,
                  backgroundImage: widget.user.avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(widget.user.avatarUrl)
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                )
              : SizedBox(
                  width: avatarSize * 2,
                ),
          const SizedBox(
            width: 10,
          ),
          if (widget.message.type == 'text') _buildTextMessage(context),
          if (widget.message.type == 'image') _buildImageMessage(context),
          if (widget.message.type == 'video') _buildVideoMessage(context),
        ],
      ),
    );
  }

  final firstMessageOfGroupBorder = const BorderRadius.only(
      topRight: Radius.circular(20),
      topLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
      bottomLeft: Radius.circular(5));
  final lastMessageOfGroupBorder = const BorderRadius.only(
      bottomRight: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      topLeft: Radius.circular(5));
  final middleMessageOfGroupBorder = const BorderRadius.only(
      bottomLeft: Radius.circular(5),
      topRight: Radius.circular(20),
      bottomRight: Radius.circular(20),
      topLeft: Radius.circular(5));

  Widget _buildTextMessage(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
          color: const Color.fromRGBO(55, 126, 189, 1.0),
          borderRadius: widget.isLastInGroup && widget.isFirstInGroup
              ? BorderRadius.circular(borderRadius)
              : widget.isFirstInGroup
                  ? firstMessageOfGroupBorder
                  : widget.isLastInGroup
                      ? lastMessageOfGroupBorder
                      : middleMessageOfGroupBorder),
      child: Text(
        widget.message.content,
        style: const TextStyle(color: Colors.white),
        maxLines: null,
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullMediaScreen(
                  message: widget.message,
                  senderName: widget.user.displayName.isEmpty
                      ? widget.user.displayName
                      : widget.user.username),
            ));
      },
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
        child: ClipRRect(
          borderRadius: widget.isLastInGroup && widget.isFirstInGroup
              ? BorderRadius.circular(borderRadius)
              : widget.isFirstInGroup
                  ? firstMessageOfGroupBorder
                  : widget.isLastInGroup
                      ? lastMessageOfGroupBorder
                      : middleMessageOfGroupBorder,
          child: Hero(
            tag: widget.message.content,
            child: CachedNetworkImage(
              imageUrl: widget.message.content,
              width: MediaQuery.of(context).size.width / 10 * 6.5,
              height: MediaQuery.of(context).size.width / 10 * 6.5,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoMessage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullMediaScreen(
                  message: widget.message,
                  senderName: widget.user.displayName.isNotEmpty
                      ? widget.user.displayName
                      : widget.user.username),
            ));
      },
      child: AnimatedContainer(
        //constraints: BoxConstraints( maxWidth: MediaQuery.of(context).size.width / 2),
        width: MediaQuery.of(context).size.width / 2,
        height:
            isLoading ? MediaQuery.of(context).size.width / 2 : heightOfVideo,
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(20)),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Hero(
                      tag: widget.message.content,
                      child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller)),
                    ),
                  ),
                  const Positioned(
                      top: 10,
                      right: 10,
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 40,
                      ))
                ],
              ),
      ),
    );
  }
}
