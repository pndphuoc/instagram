/*
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:instagram/screens/profile_screens/pick_image_from_gallery_screen.dart';
import 'package:instagram/screens/profile_screens/shoot_image_from_camera_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/asset_avatar_change_view_model.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class AvatarChangeScreen extends StatefulWidget {
  const AvatarChangeScreen({Key? key}) : super(key: key);

  @override
  State<AvatarChangeScreen> createState() => _AvatarChangeScreenState();
}

class _AvatarChangeScreenState extends State<AvatarChangeScreen> with TickerProviderStateMixin {
  late AssetViewModel _assetViewModel;
  late TabController _tabController;
  final AssetAvatarChangeViewModel _assetAvatarChangeViewModel = AssetAvatarChangeViewModel();

  @override
  void initState() {
    _assetViewModel = context.read<AssetViewModel>();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          PickImageFromGalleryScreen(assetAvatarChangeViewModel: _assetAvatarChangeViewModel),
          const ShootImageFromCameraScreen()
        ],
      ),
      bottomNavigationBar: Container(
        height: 45,
        color: secondaryColor,
        child: TabBar(
          controller: _tabController,
          tabs: [
            Text("Gallery", style: Theme.of(context).textTheme.titleMedium,),
            Text("Camera", style: Theme.of(context).textTheme.titleMedium,),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: GestureDetector(
        onTap: () async {
          await _showBottomModalOfPaths(context);
        },
        child: IntrinsicWidth(
          child: Row(
            children: [
              StreamBuilder(
                stream: _assetAvatarChangeViewModel.pathSelectStream,
                initialData: 'Gallery',
                builder: (context, snapshot) {
                  return Text(snapshot.data, style: Theme.of(context).textTheme.titleLarge,);
                }
              ),
              const SizedBox(width: 5,),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white,)
            ],
          ),
        ) ,
      ),
      actions: [
        IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_forward, color: Colors.blue, size: 30,)),
        const SizedBox(width: 10,)
      ],
    );
  }

  Future _showBottomModalOfPaths(BuildContext context) {
    return showModalBottomSheet(
      elevation: 0,
      useSafeArea: true,
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
                  ..._assetAvatarChangeViewModel.paths.map((path) => InkWell(
                    onTap: () {
                      _assetAvatarChangeViewModel.onPathTap(path);
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
*/
