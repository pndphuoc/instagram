import 'package:flutter/material.dart';
import 'package:instagram/interface/asset_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetService implements IAssetService {
  @override
  Future<List<AssetEntity>> loadAssetsOfPath(AssetPathEntity path,
      {int page = 0, int sizePerPage = 50}) async {
    final List<AssetEntity> entities = await path.getAssetListPaged(
      page: page,
      size: sizePerPage,
    );
    return entities;
  }

  @override
  Future<void> loadMoreAssets() {
    // TODO: implement loadMoreAssets
    throw UnimplementedError();
  }

  @override
  Future<bool> requestAssets() async {
    var photosStatus = await Permission.photos.status;
    var videosStatus = await Permission.videos.status;
    var mediaLocationStatus = await Permission.accessMediaLocation.status;
    //var manageStatus = await Permission.manageExternalStorage.status;

    if (photosStatus.isDenied || videosStatus.isDenied || mediaLocationStatus.isDenied) {
      Map<Permission, PermissionStatus> statues = await [
        //Permission.manageExternalStorage,
        Permission.accessMediaLocation,
        Permission.photos,
        Permission.videos
      ].request();
    }

    if (photosStatus.isGranted && videosStatus.isGranted && mediaLocationStatus.isGranted) {
      return true;
    }
    return false;

    //final PermissionState ps = await PhotoManager.requestPermissionExtend();
    //return ps;
  }

  @override
  Future<List<AssetPathEntity>> loadAssetPathList() async {
    final FilterOptionGroup filterOptionGroup = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      orders: [
        const OrderOption(
          type: OrderOptionType.updateDate,
          asc: false,
        ),
      ],
    );

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      hasAll: true,
      filterOption: filterOptionGroup,
    );
    return paths;
  }
}