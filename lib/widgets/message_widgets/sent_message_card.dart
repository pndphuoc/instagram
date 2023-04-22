import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:instagram/models/message.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../screens/message_screens/view_full_media_screen.dart';

class SentMessageCard extends StatefulWidget {
  final Message message;
  final DateTime? lastSeenMessageTimeOfRestUser;
  final String restUserAvatarUrl;

  const SentMessageCard(
      {Key? key,
      required this.message,
      this.lastSeenMessageTimeOfRestUser,
      required this.restUserAvatarUrl})
      : super(key: key);

  @override
  State<SentMessageCard> createState() => _SentMessageCardState();
}

class _SentMessageCardState extends State<SentMessageCard> {
  final double borderRadius = 20;
  late VideoPlayerController _controller;
  bool isLoading = true;
  late double heightOfVideo;
  late CurrentUserViewModel _currentUserViewModel;

  @override
  void initState() {
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    if (widget.message.type == 'video') {
      _controller = VideoPlayerController.network(
        widget.message.content,
      )..initialize().then((_) {
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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.message.type == 'text') _buildTextMessage(context),
        if (widget.message.type == 'image') _buildImageMessage(context),
        if (widget.message.type == 'video') _buildVideoMessage(context),
        const SizedBox(
          width: 5,
        ),
        _messageStatusDetector(),
        const SizedBox(
          width: 5,
        )
      ],
    );
  }

  Widget _buildSentStatusMessage(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      width: 13,
      height: 13,
      decoration: const BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.fromBorderSide(BorderSide(width: 1, color: primaryColor))),
      child:
          const Center(child: Icon(Icons.check, color: primaryColor, size: 10)),
    );
  }

  Widget _buildSendingStatusMessage(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
              BorderSide(width: 1.5, color: primaryColor))),
    );
  }

  Widget _buildLastSeenStatusMessage(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      width: 13,
      height: 13,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: CachedNetworkImageProvider(widget.restUserAvatarUrl!)),
          shape: BoxShape.circle,
          border: const Border.fromBorderSide(
              BorderSide(width: 1, color: primaryColor))),
    );
  }

  Widget _buildSeenStatusMessage(BuildContext context) {
    return Container();
  }

  _messageStatusDetector() {
    if (widget.lastSeenMessageTimeOfRestUser != null) {
      if (widget.lastSeenMessageTimeOfRestUser == widget.message.timestamp) {
        return _buildLastSeenStatusMessage(context);
      } else {
        return _buildSeenStatusMessage(context);
      }
    } else if (widget.message.status == 'sent') {
      print("sentttt");
      return _buildSentStatusMessage(context);
    } else if (widget.message.status == 'sending') {
      return _buildSendingStatusMessage(context);
    } else if (widget.lastSeenMessageTimeOfRestUser == null) {
      return _buildSentStatusMessage(context);
    }
  }

  Widget _buildTextMessage(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(borderRadius)),
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
              builder: (context) =>
                  FullMediaScreen(message: widget.message, senderName: "You"),
            ));
      },
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Hero(
            tag: widget.message.content,
            child: CachedNetworkImage(
              imageUrl: widget.message.content,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width / 10 * 6.5,
              height: MediaQuery.of(context).size.width / 10 * 6.5,
              placeholder: (context, url) => Container(
                color: Colors.grey,
              ),
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
                  senderName: _currentUserViewModel.user!.displayName.isEmpty
                      ? _currentUserViewModel.user!.username
                      : _currentUserViewModel.user!.displayName),
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
