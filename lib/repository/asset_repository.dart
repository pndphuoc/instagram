import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetRepository {
  static Future<List<AssetEntity>> loadAssetsOfPath(AssetPathEntity path,
      {int page = 0, int sizePerPage = 50}) async {
    final List<AssetEntity> entities = await path.getAssetListPaged(

      page: page,
      size: sizePerPage,
    );
    return entities;
  }

  static Future<bool> requestAssets() async {
    var photosStatus = await Permission.photos.status;
    var videosStatus = await Permission.videos.status;
    var mediaLocationStatus = await Permission.accessMediaLocation.status;

    if (photosStatus.isDenied || videosStatus.isDenied || mediaLocationStatus.isDenied) {
      Map<Permission, PermissionStatus> statues = await [
        Permission.accessMediaLocation,
        Permission.photos,
        Permission.videos
      ].request();
    }

    if (photosStatus.isGranted && videosStatus.isGranted && mediaLocationStatus.isGranted) {
      return true;
    }
    return false;
  }

  static Future<List<AssetPathEntity>> loadAssetPathList({bool onlyImage = false}) async {
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
      type: onlyImage ? RequestType.image : RequestType.common,
      filterOption: filterOptionGroup,
    );
    return paths;
  }
}