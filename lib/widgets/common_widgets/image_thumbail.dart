import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class ImageItemWidget extends StatelessWidget {
  const ImageItemWidget({
    Key? key,
    required this.entity,
    required this.option,
    this.onTap,
    this.onLongPress
  }) : super(key: key);

  final AssetEntity entity;
  final ThumbnailOption option;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  Widget buildContent(BuildContext context) {
    if (entity.type == AssetType.audio) {
      return const Center(
        child: Icon(Icons.audiotrack, size: 30),
      );
    }
    return _buildImageWidget(context, entity, option);
  }

  String durationOfVideo(int videoSeconds) {
    int minutes = videoSeconds ~/60;
    int seconds = videoSeconds - (minutes * 60);
    return "$minutes:${seconds >= 10 ? seconds : "0$seconds"}";
  }

  Widget _buildImageWidget(
    BuildContext context,
    AssetEntity entity,
    ThumbnailOption option,
  ) {
    return Consumer<AssetViewModel>(
      builder: (context, value, child) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: AssetEntityImage(
                entity,
                isOriginal: false,
                thumbnailSize: option.size,
                thumbnailFormat: option.format,
                fit: BoxFit.cover,
              ),
            ),
            (entity.type == AssetType.video)
                ? Positioned(
                bottom: 0,
                right: 0,
                child: Text(
                  durationOfVideo(entity.videoDuration.inSeconds),
                  style:
                  GoogleFonts.readexPro(color: Colors.white, fontSize: 15),
                ))
                : Container(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: buildContent(context),
    );
  }
}
