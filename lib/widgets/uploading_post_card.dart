import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/post.dart';
import '../ultis/colors.dart';

class UploadingPostCard extends StatefulWidget {
  final Post post;
  final AssetEntity asset;

  const UploadingPostCard({Key? key, required this.post, required this.asset})
      : super(key: key);

  @override
  State<UploadingPostCard> createState() => _UploadingPostCardState();
}

class _UploadingPostCardState extends State<UploadingPostCard> {
  final double avatarHeight = 20;
  final double avatarWidth = 20;
  late double imageWidth;

  @override
  Widget build(BuildContext context) {
    imageWidth = MediaQuery.of(context).size.width - 20;
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: postCardBackgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    radius: avatarHeight,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.post.avatarUrl ?? "",
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "0 second ago",
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: AssetEntityImage(
                    widget.asset,
                    height: imageWidth,
                    width: imageWidth,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  SvgPicture.asset(
                    "assets/ic_heart.svg",
                    height: 28,
                    width: 28,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "0",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SvgPicture.asset(
                    "assets/ic_comment.svg",
                    height: 28,
                    width: 28,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "0",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SvgPicture.asset(
                    "assets/ic_share.svg",
                    height: 28,
                    width: 28,
                  ),
                  const Expanded(child: SizedBox()),
                  SvgPicture.asset(
                    "assets/ic_bookmark.svg",
                    height: 28,
                    width: 28,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: ExpandableText(
                  widget.post.caption,
                  expandText: 'show more',
                  collapseText: 'show less',
                  maxLines: 3,
                  animation: true,
                  collapseOnTextTap: true,
                  expandOnTextTap: true,
                  linkColor: Colors.grey,
                  linkStyle: GoogleFonts.readexPro(fontWeight: FontWeight.w200),
                  animationDuration: const Duration(milliseconds: 500),
                  style: GoogleFonts.readexPro(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: GestureDetector(
                  onTap: () {},
                  child: Text("See all comments",
                      style: Theme.of(context).textTheme.labelLarge),
                ),
              )
            ],
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black38,
          ),
        ),
        const Positioned.fill(
            child: Center(
          child: CircularProgressIndicator(),
        ))
      ],
    );
  }
}
