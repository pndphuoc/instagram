import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:instagram/models/message.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/message_details_view_model.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../screens/message_screens/view_full_media_screen.dart';

class SentMessageCard extends StatefulWidget {
  final String conversationId;
  final Message message;
  final String restUserAvatarUrl;
  final bool isLastSeenMessage;
  final bool isLastInGroup;
  final bool isFirstInGroup;

  const SentMessageCard(
      {Key? key,
      required this.message,
      required this.restUserAvatarUrl,
      required this.conversationId,
      required this.isLastSeenMessage,
      this.isLastInGroup = false,
      this.isFirstInGroup = false})
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
  late MessageDetailsViewModel _detailsViewModel;

  @override
  void initState() {
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _detailsViewModel =
        MessageDetailsViewModel(widget.conversationId, widget.message.id);
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
      ),
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
              image: widget.restUserAvatarUrl.isNotEmpty ? CachedNetworkImageProvider(widget.restUserAvatarUrl) : const AssetImage('assets/default_avatar.png') as ImageProvider),
          shape: BoxShape.circle,
          border: const Border.fromBorderSide(
              BorderSide(width: 1, color: primaryColor))),
    );
  }

  Widget _buildSeenStatusMessage(BuildContext context) {
    return const SizedBox(
      width: 13,
    );
  }

  _messageStatusDetector() {
    if (widget.isLastSeenMessage) {
      return _buildLastSeenStatusMessage(context);
    } else if (widget.message.status == 'seen') {
      return _buildSeenStatusMessage(context);
    } else if (widget.message.status == 'sent') {
      return _buildSentStatusMessage(context);
    } else if (widget.message.status == 'sending') {
      return _buildSendingStatusMessage(context);
    }
  }

  final firstMessageOfGroupBorder = const BorderRadius.only(
      topRight: Radius.circular(20),
      topLeft: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(5));
  final lastMessageOfGroupBorder = const BorderRadius.only(
      bottomRight: Radius.circular(20),
      topLeft: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      topRight: Radius.circular(5));
  final middleMessageOfGroupBorder = const BorderRadius.only(
      bottomRight: Radius.circular(5),
      topLeft: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      topRight: Radius.circular(5));

  Widget _buildTextMessage(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
          color: secondaryColor,
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
              builder: (context) =>
                  FullMediaScreen(message: widget.message, senderName: "You"),
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
