/*
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:instagram/view_model/asset_avatar_change_view_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../ultis/colors.dart';
import '../../ultis/ultils.dart';
import '../../view_model/asset_view_model.dart';
import '../../widgets/image_thumbail.dart';
import '../../widgets/post_widgets/video_player_widget.dart';

class PickImageFromGalleryScreen extends StatefulWidget {
  final AssetAvatarChangeViewModel assetAvatarChangeViewModel;
  const PickImageFromGalleryScreen({Key? key, required this.assetAvatarChangeViewModel}) : super(key: key);

  @override
  State<PickImageFromGalleryScreen> createState() =>
      _PickImageFromGalleryScreenState();
}

class _PickImageFromGalleryScreenState extends State<PickImageFromGalleryScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  late Future _loadImageAssets;
  File? _sample;
  File? _lastCropped;

  late double itemHeight;
  final double _crossAxisSpacing = 2;
  final double _mainAxisSpacing = 2;
  final double _childAspectRatio = 1;
  final _gridViewCrossAxisCount = 4;
  int page = 1;

  @override
  void initState() {
    super.initState();
    _loadImageAssets = widget.assetAvatarChangeViewModel.loadAssetPathsAndAssets(onlyImage: true);
    _sample?.delete();
    _lastCropped?.delete();
  }

  @override
  Widget build(BuildContext context) {
    itemHeight = calculateItemHeight(
        context: context,
        crossAxisSpacing: _crossAxisSpacing,
        mainAxisSpacing: _mainAxisSpacing,
        gridViewCrossAxisCount: _gridViewCrossAxisCount,
        childAspectRatio: _childAspectRatio);

    super.build(context);
    return SizedBox(
      height: (MediaQuery.of(context).size.height -
          kToolbarHeight -
          kBottomNavigationBarHeight),
      width: MediaQuery.of(context).size.width,
      child: FutureBuilder(
        future: _loadImageAssets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.yellow,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return Stack(
              children: [
                Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: SizedBox(
                      height: (MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          kBottomNavigationBarHeight) /
                          2 - 10,
                      child: StreamBuilder(
                        stream: widget.assetAvatarChangeViewModel.selectedFileStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator(),);
                          } else {
                            return _buildCropImage(snapshot.data!);
                          }
                        },
                      ),
                    )),
                Positioned.fill(
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.5,
                    maxChildSize: 0.8,
                    builder: (context, scrollController) {
                      return _mediasGrid(context);
                    },
                  ),
                )
              ],
            );
          }

        },
      ),
    );
  }

  Widget _buildCropImage(File imageFile) {
    GlobalKey<CropState> cropKey = GlobalKey<CropState>();
    return Container(
      color: Colors.black,
      child: Crop.file(
        imageFile,
        key: cropKey,
        aspectRatio: 1,
      ),
    );
    //return Image.file(imageFile);
  }

  Widget _mediasGrid(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        const double threshold = 0.5; // 90% of the list length
        final double extentAfter = scrollNotification.metrics.extentAfter;
        final double maxScrollExtent =
            scrollNotification.metrics.maxScrollExtent;
        if (scrollNotification is ScrollEndNotification &&
            extentAfter / maxScrollExtent < threshold &&
            widget.assetAvatarChangeViewModel.hasMoreToLoad) {
          widget.assetAvatarChangeViewModel.loadAssetsOfPath(page: page);
          page++;
        }
        return true;
      },
      child: Container(
        color: mobileBackgroundColor,
        child: GridView.builder(
          cacheExtent: 500,
          controller: _scrollController,
          itemCount: widget.assetAvatarChangeViewModel.entities.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridViewCrossAxisCount,
              mainAxisSpacing: _mainAxisSpacing,
              crossAxisSpacing: _crossAxisSpacing,
              childAspectRatio: _childAspectRatio),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _scrollController.animateTo(
                    index ~/ _gridViewCrossAxisCount * itemHeight,
                    curve: Curves.bounceInOut,
                    duration: const Duration(milliseconds: 200));
                widget.assetAvatarChangeViewModel.onTapEntity(widget.assetAvatarChangeViewModel.entities[index]);
              },
              child: Stack(
                children: [
                  ImageItemWidget(
                    entity: widget.assetAvatarChangeViewModel.entities[index],
                    option: const ThumbnailOption(
                      size: ThumbnailSize(300, 300),
                    ),
                  ),
                  StreamBuilder(
                      stream: widget.assetAvatarChangeViewModel.selectedFileOverplayStream,
                      initialData: 0,
                      builder: (context, snapshot) {
                        if (index == snapshot.data) {
                          return Container(
                            color: Colors.white38,
                          );
                        } else {
                          return const SizedBox();
                        }
                      },)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}
*/
