import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/models/message.dart';
import 'package:instagram/view_model/message_view_model.dart';

import '../ultis/ultils.dart';

class FullImageScreen extends StatelessWidget {
  final Message message;
  final String senderName;
  const FullImageScreen({Key? key, required this.message, required this.senderName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Hero(
          tag: message.content,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GestureDetector(
              /*onVerticalDragEnd: (details) {
                print("hehe");
                if (details.velocity.pixelsPerSecond.dy > 0) {
                  Navigator.pop(context);
                }
              },*/
              child: CachedNetworkImage(
                imageUrl: message.content,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - kToolbarHeight,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          )),
    );
  }
  
  _buildAppBar(BuildContext context) {
    final MessageViewModel messageViewModel = MessageViewModel();
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(senderName, style: Theme.of(context).textTheme.titleMedium,),
          Text("${getElapsedTime(message.timestamp)} ago", style: Theme.of(context).textTheme.labelMedium,)
        ],
      ),
      actions: [
        InkWell(
          onTap: () async {
            if (await messageViewModel.onDownload(message.content)) {
              Fluttertoast.showToast(msg: "Photo saved successfully");
            } else {
              Fluttertoast.showToast(msg: "photo save failed");
            }
          },
          child: const Icon(Icons.download, size: 25,),
        ),
        const SizedBox(width: 20,),
      ],
    );
  }
}
