import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/chat_user.dart';
import 'package:instagram/widgets/avatar_with_status.dart';

import '../models/message.dart';

class ReceivedMessageCard extends StatefulWidget {
  final Message message;
  final ChatUser user;
  const ReceivedMessageCard({Key? key, required this.message, required this.user}) : super(key: key);

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
        const SizedBox(width: 10,),
        AvatarWithStatus(radius: avatarSize, imageUrl: widget.user.avatarUrl, isOnline: widget.user.isOnline),
        const SizedBox(width: 10,),
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
          borderRadius: BorderRadius.circular(borderRadius)
      ),
      child: Text(widget.message.content, style: const TextStyle(color: Colors.white),
        maxLines: null,
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: widget.message.content,
        width: MediaQuery.of(context).size.width / 10 * 4,
        fit: BoxFit.contain,
      ),
    );
  }

}
