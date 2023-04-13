import 'package:flutter/material.dart';

class ConversationCard extends StatefulWidget {
  const ConversationCard({Key? key}) : super(key: key);

  @override
  State<ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<ConversationCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          CircleAvatar()
        ],
      ),
    );
  }
}
