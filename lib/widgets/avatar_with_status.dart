import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';

class AvatarWithStatus extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool isOnline;
  const AvatarWithStatus({Key? key, required this.radius, required this.imageUrl, required this.isOnline}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: CachedNetworkImageProvider(imageUrl),
        ),
        if (isOnline) Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
                border: Border.fromBorderSide(BorderSide(color: mobileBackgroundColor, width: 2))
              ),
              width: radius / 2,
              height: radius / 2,
            ))
      ],
    );
  }
}
