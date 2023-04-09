import 'package:photo_manager/photo_manager.dart';

abstract class IAssetService {
  Future<List<AssetPathEntity>> loadAssetPathList();

  Future<List<AssetEntity>> loadAssetsOfPath(AssetPathEntity path,
      {int page = 0, int sizePerPage = 0});

  Future<void> loadMoreAssets();

  Future<bool> requestAssets();
}
