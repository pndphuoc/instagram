import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../services/asset_services.dart';

class AssetAvatarChangeViewModel extends ChangeNotifier {
/*  final AssetService _assetService = AssetService();
  List<AssetEntity> _entities = [];
  List<AssetPathEntity> _paths = [];
  late AssetPathEntity _selectedPath;
  late AssetEntity _selectedEntity;
  List<AssetEntity> get entities => _entities;
  late int entitiesCount;
  bool _hasMoreToLoad = false;

  final _selectedFileController = StreamController<File?>();
  Stream<File?> get selectedFileStream => _selectedFileController.stream;

  final _selectedFileOverplayController = StreamController<int>.broadcast();
  Stream<int> get selectedFileOverplayStream => _selectedFileOverplayController.stream;

  final _pathSelectController = StreamController();
  Stream get pathSelectStream => _pathSelectController.stream;

  Future<void> loadAssetPathList({bool onlyImage = false}) async {
    try {
      _paths = await _assetService.loadAssetPathList(onlyImage: onlyImage);

    } catch (e) {
      print(e.toString());
      _paths = [];
    }
  }

  Future<void> loadAssetsOfPath({int page = 0, int sizePerPage = 50}) async {
    _entities.addAll(await _assetService.loadAssetsOfPath(_selectedPath,
        page: page, sizePerPage: sizePerPage));
    if (page == 0) {
      _selectedFileController.sink.add(await assetEntityToFile(_entities.first));
      _selectedFileOverplayController.sink.add(0);
    }
    entitiesCount = await _selectedPath.assetCountAsync;
    _hasMoreToLoad = _entities.length < entitiesCount;
  }

  Future<bool> loadAssetPathsAndAssets({bool onlyImage = false}) async {
    try {
      await loadAssetPathList(onlyImage: onlyImage);
      _selectedPath = _paths.first;
      await loadAssetsOfPath();

      _selectedEntity = _entities.first;
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<File?> assetEntityToFile(AssetEntity entity) async {
    try {
      return await entity.file;
    } catch (e) {
      rethrow;
    }
  }

  void onTapEntity(AssetEntity entity) async {
      _selectedFileController.sink.add(await assetEntityToFile(entity));
      _selectedFileOverplayController.sink.add(_entities.indexOf(entity));
  }

  void onPathTap(AssetPathEntity path) async {
    _selectedPath = path;
    await loadAssetsOfPath();
    _pathSelectController.sink.add(path.name);
  }


  List<AssetPathEntity> get paths => _paths;

  AssetPathEntity get selectedPath => _selectedPath;

  AssetEntity get selectedEntity => _selectedEntity;

  bool get hasMoreToLoad => _hasMoreToLoad;*/

}