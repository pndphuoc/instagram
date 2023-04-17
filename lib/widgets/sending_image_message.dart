import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class SendingImageMessage extends StatelessWidget {
  final AssetEntity image;
  const SendingImageMessage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 20;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AssetEntityImage(
        image,
        height: 300,
        width: 200,
        fit: BoxFit.cover,
      ),
    );
  }

}
