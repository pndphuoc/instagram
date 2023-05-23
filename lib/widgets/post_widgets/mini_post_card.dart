import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/post_screens/post_details_screen.dart';
import 'package:instagram/widgets/post_widgets/video_player_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/post.dart';
import '../../screens/post_screens/post_list_screen.dart';
import '../../ultis/ultils.dart';

class MiniPostCard extends StatelessWidget {
  const MiniPostCard({Key? key, required this.post}) : super(key: key);
  final Post post;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (post.medias.first.type ==
            'image')
          CachedNetworkImage(
            imageUrl: post.medias.first.url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            fadeInDuration: const Duration(milliseconds: 100),
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey.shade900,
              highlightColor: Colors.grey.shade700,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
              ),
            ),
          )
        else
          Positioned.fill(
            child: VideoPlayerWidget.network(
              url: post.medias.first.url,
              isPlay: false,
            ),
          ),
        if (post.medias.length > 1)
          const Positioned(
              top: 5,
              right: 5,
              child: Icon(
                Icons.layers_rounded,
                color: Colors.white,
              ))
        else if (post.medias.first.type ==
            'video')
          const Positioned(
              top: 5,
              right: 5,
              child: Icon(
                Icons.slow_motion_video_rounded,
                color: Colors.white,
              )),
        if (post.isAIPost)
          Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white)
                ),
                child: Center(child: Text("AI", style: Theme.of(context).textTheme.labelSmall,),),
              ))
      ],
    );
  }
}
