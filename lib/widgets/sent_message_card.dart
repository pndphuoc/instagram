import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/message.dart';
import 'package:instagram/ultis/colors.dart';

class SentMessageCard extends StatefulWidget {
  final Message message;
  const SentMessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<SentMessageCard> createState() => _SentMessageCardState();
}

class _SentMessageCardState extends State<SentMessageCard> {
  final double borderRadius = 20;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.message.type == 'text') _buildTextMessage(context),
        if (widget.message.type == 'image') _buildImageMessage(context),
        const SizedBox(width: 5,),
        if (widget.message.status == 'sent')
          Container(
            alignment: Alignment.centerRight,
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
             shape: BoxShape.circle,
              border: Border.fromBorderSide(BorderSide(width: 1, color: primaryColor))
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 10,),
          ),
        if (widget.message.status == 'sending')
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(BorderSide(width: 1.5, color: primaryColor))
            ),
          ),
      ],
    );
  }

  Widget _buildTextMessage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 10 * 6.5,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: secondaryColor,
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
        width: MediaQuery.of(context).size.width / 10 * 5,
        fit: BoxFit.contain,
      ),
    );
  }

}
