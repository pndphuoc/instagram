import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/message.dart';
import 'package:instagram/ultis/colors.dart';

import '../screens/full_image_screen.dart';

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
            width: 13,
            height: 13,
            decoration: const BoxDecoration(
             shape: BoxShape.circle,
              border: Border.fromBorderSide(BorderSide(width: 1, color: primaryColor))
            ),
            child: const Center(child: Icon(Icons.check, color: primaryColor, size: 10)),
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
        const SizedBox(width: 5,)
      ],
    );
  }

  Widget _buildTextMessage(BuildContext context) {
    return Container(
      constraints: BoxConstraints( maxWidth: MediaQuery.of(context).size.width / 10 * 6.5),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => FullImageScreen(message: widget.message,
            senderName: "You"
        ),));
      },
      child: Container(
        constraints: BoxConstraints( maxWidth: MediaQuery.of(context).size.width / 10 * 6.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Hero(
            tag: widget.message.content,
            child: CachedNetworkImage(
              imageUrl: widget.message.content,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width / 10 * 6.5,
              height: MediaQuery.of(context).size.width / 10 * 6.5,
              placeholder: (context, url) => Container(color: Colors.grey,),
            ),
          ),
        ),
      ),
    );
  }

}
