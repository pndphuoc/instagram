import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/route/route_name.dart';
import 'package:instagram/screens/post_screens/camera_preview_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:instagram/widgets/image_thumbail.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../ultis/ultils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final ScrollController _scrollController = ScrollController();
  final _gridViewCrossAxisCount = 4;
  late Future<bool> _firstLoading;
  late AssetViewModel assetViewModel;
  late double itemHeight;
  int page = 1;
  final double _crossAxisSpacing = 2;
  final double _mainAxisSpacing = 2;
  final double _childAspectRatio = 1;

  @override
  void initState() {
    super.initState();
    assetViewModel = Provider.of<AssetViewModel>(context, listen: false);
    _firstLoading = assetViewModel.firstLoading();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _calculateItemHeight(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth =
        (screenWidth - _crossAxisSpacing * (_gridViewCrossAxisCount - 1)) /
            _gridViewCrossAxisCount;
    double itemHeight = itemWidth / _childAspectRatio + _mainAxisSpacing;
    return itemHeight;
  }

  @override
  Widget build(BuildContext context) {
    double previewImageSize = MediaQuery.of(context).size.width;
    itemHeight = _calculateItemHeight(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(context),
      body: Consumer<AssetViewModel>(
        builder: (context, value, child) => FutureBuilder(
          future: _firstLoading,
          initialData: null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data! == false) {
              return Center(
                child: Text(
                  "Permission is not authorized\nPlease grant permission to use the application",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              List<AssetEntity> entities = value.entities;
              return Column(
                children: [
                  SizedBox(
                    width: previewImageSize,
                    height: previewImageSize,
                    child: ImageItemWidget(
                        entity: value.selectedEntity!,
                        option: const ThumbnailOption(
                            size: ThumbnailSize.square(1000), quality: 80)),
                  ),
                  _controllerBar(context, value),
                  Expanded(child: _mediasGrid(context, value, entities))
                ],
              );
            }
          },
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: onBackground,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text("New post"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteName.addCaption);
            },
            child: const Text("Post"))
      ],
    );
  }

  Widget _controllerBar(BuildContext context, AssetViewModel value) {
    return Container(
      decoration: const BoxDecoration(
        color: mobileBackgroundColor,
      ),
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () async {
                await _showBottomModalOfPaths(context, value);
              },
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    Text(
                      value.selectedPath.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Icon(Icons.arrow_drop_down)
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      value.setIsMultiSelect = !value.getIsMultiSelect;
                    },
                    borderRadius: BorderRadius.circular(35),
                    child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: value.getIsMultiSelect
                                ? Colors.blue
                                : const Color.fromARGB(100, 172, 173, 168)),
                        child: const Icon(
                          Icons.layers_outlined,
                          color: Colors.white,
                          size: 17,
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(35),
                    onTap: () async {
                          await availableCameras().then((cameras) {
                            if (cameras.isEmpty) {
                              return;
                            }
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    CameraPreviewScreen(cameras: cameras),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return buildSlideTransition(animation, child);
                            },
                            transitionDuration:
                                const Duration(milliseconds: 150),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 150),
                          ),
                        );
                      });
                    },
                    child: Container(
                        height: 35,
                        width: 35,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(100, 172, 173, 168)),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 17,
                        )),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Widget _mediasGrid(
      BuildContext context, AssetViewModel value, List<AssetEntity> entities) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        const double threshold = 0.5; // 90% of the list length
        final double extentAfter = scrollNotification.metrics.extentAfter;
        final double maxScrollExtent =
            scrollNotification.metrics.maxScrollExtent;
        if (scrollNotification is ScrollEndNotification &&
            extentAfter / maxScrollExtent < threshold &&
            value.hasMoreToLoad) {
          value.loadAssetsOfPath(page: page);
          page++;
        }
        return true;
      },
      child: GridView.builder(
        cacheExtent: 500,
        controller: _scrollController,
        itemCount: entities.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridViewCrossAxisCount,
            mainAxisSpacing: _mainAxisSpacing,
            crossAxisSpacing: _crossAxisSpacing,
            childAspectRatio: _childAspectRatio),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (value.isAvailableList()) {
                _scrollController.animateTo(
                    index ~/ _gridViewCrossAxisCount * itemHeight,
                    curve: Curves.bounceInOut,
                    duration: const Duration(milliseconds: 200));
              }
              value.onTapEntity(entities[index]);
            },
            onLongPress: () {
              value.onLongPress(entities[index]);
            },
            child: Stack(
              children: [
                ImageItemWidget(
                  entity: entities[index],
                  option: const ThumbnailOption(
                    size: ThumbnailSize(300, 300),
                  ),
                ),
                if (value.selectedEntity == entities[index])
                  Container(
                    color: Colors.white38,
                  ),
                if (value.getIsMultiSelect &&
                    !value.selectedEntities.contains(entities[index]))
                  Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 1)),
                            color: blueColor),
                      ))
                else if (value.getIsMultiSelect &&
                    value.selectedEntities.contains(entities[index]))
                  Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 1)),
                            color: Colors.blue),
                        child: Center(
                            child: Text((value.selectedEntities
                                        .indexOf(entities[index]) +
                                    1)
                                .toString())),
                      ))
              ],
            ),
          );
        },
      ),
    );
  }

  Future _showBottomModalOfPaths(BuildContext context, AssetViewModel value) {
    return showModalBottomSheet(
      elevation: 0,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          maxChildSize: 1,
          minChildSize: 0.8,
          initialChildSize: 1,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  ...value.paths.map((path) => InkWell(
                        onTap: () {
                          page = 0;
                          value.selectedPath = path;
                          value.loadAssetsOfPath(page: page);
                          page++;
                          Navigator.pop(context);
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              path.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )),
                      ))
                ],
              ),
            );
          },
        );
      },
    );
  }
}
