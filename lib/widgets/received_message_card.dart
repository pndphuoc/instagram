import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/chat_user.dart';
import 'package:instagram/screens/full_image_screen.dart';
import 'package:instagram/widgets/avatar_with_status.dart';

import '../models/message.dart';

class ReceivedMessageCard extends StatefulWidget {
  final Message message;
  final ChatUser user;

  const ReceivedMessageCard(
      {Key? key, required this.message, required this.user})
      : super(key: key);

  @override
  State<ReceivedMessageCard> createState() => _ReceivedMessageCardState();
}

class _ReceivedMessageCardState extends State<ReceivedMessageCard> {
  final double borderRadius = 20;
  final double avatarSize = 15;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 10,
        ),
        CircleAvatar(
          radius: avatarSize,
          backgroundImage: widget.user.avatarUrl.isNotEmpty
              ? CachedNetworkImageProvider(widget.user.avatarUrl)
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
        ),
        const SizedBox(
          width: 10,
        ),
        if (widget.message.type == 'text') _buildTextMessage(context),
        if (widget.message.type == 'image') _buildImageMessage(context)
      ],
    );
  }

  Widget _buildTextMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
          color: const Color.fromRGBO(55, 126, 189, 1.0),
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
              builder: (context) => FullImageScreen(
                  message: widget.message,
                  senderName: widget.user.displayName.isEmpty
                      ? widget.user.displayName
                      : widget.user.username),
            ));
      },
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 10 * 6.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
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
}
