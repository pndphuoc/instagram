import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/permision_handler.dart';
import 'package:instagram/services/asset_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetViewModel extends ChangeNotifier {
  final AssetService _assetService = AssetService();
  List<AssetPathEntity> _paths = [];
  List<AssetEntity> _entities = [];
  List<AssetEntity> _selectedEntities = [];
  late AssetPathEntity _selectedPath;
  late int entitiesCount;
  bool _isMultiSelect = false;
  AssetEntity? _selectedEntity;
  bool _isAllPermissionGranted = false;
  AssetEntity? firstAsset;

  List<AssetPathEntity> get paths => _paths;

  List<AssetEntity> get entities => _entities;

  List<AssetEntity> get selectedEntities => _selectedEntities;

  AssetPathEntity get selectedPath => _selectedPath;

  AssetEntity? get selectedEntity => _selectedEntity;

  bool get getIsMultiSelect => _isMultiSelect;

  bool get hasMoreToLoad => _hasMoreToLoad;

  bool get isAllPermissionGranted => _isAllPermissionGranted;

  set selectedPath(AssetPathEntity path) {
    _selectedPath = path;
    _entities = [];
    _selectedEntity = null;
  }

  set setSelectedEntity(AssetEntity asset) {
    _selectedEntity = asset;
    notifyListeners();
  }

  set setIsMultiSelect(bool value) {
    _isMultiSelect = value;
    if (_isMultiSelect) {
      _selectedEntities.add(_selectedEntity!);
    } else {
      _selectedEntities = [];
    }
    notifyListeners();
  }

  bool _hasMoreToLoad = false;

  Future<void> loadAssetPathList() async {
    try {
      _paths = await _assetService.loadAssetPathList();

      notifyListeners();
    } catch (e) {
      print(e.toString());
      _paths = [];
    }
  }

  Future<bool> requestAssets() async {
    try {
      _isAllPermissionGranted = await _assetService.requestAssets();
    } catch (e) {
      print(e.toString());
    }
    return _isAllPermissionGranted;
  }

  Future<void> loadAssetsOfPath({int page = 0, int sizePerPage = 50}) async {
    _entities.addAll(await _assetService.loadAssetsOfPath(_selectedPath,
        page: page, sizePerPage: sizePerPage));
    if (page == 0) {
      _selectedEntity = _entities.first;
    }
    entitiesCount = await _selectedPath.assetCountAsync;
    _hasMoreToLoad = _entities.length < entitiesCount;
    notifyListeners();
  }

  Future<bool> firstLoading() async {
    try {
      if (await Permission.accessMediaLocation.isGranted && await Permission.photos.isGranted && await Permission.videos.isGranted) {
        await loadAssetPathList();
        _selectedPath = _paths.first;
        await loadAssetsOfPath();

        _selectedEntity = _entities.first;
        notifyListeners();
        return true;
      } else {
        return await PermissionHandler.requestPermissions();
      }
    } catch (err) {
      return true;
    }
  }

  void onTapEntity(AssetEntity entity) {
    bool isExistInSelectedEntities = _selectedEntities.contains(entity);

    if (_isMultiSelect) {
      if (isExistInSelectedEntities && _selectedEntity == entity) {
        _selectedEntities.remove(entity);
        notifyListeners();
        _selectedEntity =
            _selectedEntities.isNotEmpty ? _selectedEntities.last : entity;
      } else if (isExistInSelectedEntities && _selectedEntity != entity) {
        _selectedEntity = entity;
      } else {
        handleMaxSelection(entity);
      }
    } else {
      _selectedEntity = entity;
    }

    notifyListeners();
  }

  void onTapEntityInMessage(AssetEntity entity) {
    _isMultiSelect = true;

    bool isExistInSelectedEntities = _selectedEntities.contains(entity);

    if (isExistInSelectedEntities) {
      _selectedEntities.remove(entity);
    } else {
      _selectedEntities.add(entity);

      notifyListeners();
    }
  }

  void onLongPress(AssetEntity entity) {
    if (!_isMultiSelect) {
      _isMultiSelect = true;

      _selectedEntity = entity;
      setIsMultiSelect = true;

      notifyListeners();
    } else if (_selectedEntities.length < 10) {
      _selectedEntities.add(entity);
      _selectedEntity = entity;
    } else {
      handleMaxSelection(entity);
    }
  }

  void handleMaxSelection(AssetEntity entity) {
    if (_selectedEntities.length < 10) {
      _selectedEntities.add(entity);
      _selectedEntity = entity;
    } else {
      showMaxSelectionToast();
    }
  }

  void showMaxSelectionToast() {
    Fluttertoast.showToast(
      msg: 'The limit is 10 images or videos',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  bool isAvailableList() {
    if (_selectedEntities.length < 10) {
      return true;
    }
    return false;
  }

  void resetAssetViewModel() {
    _selectedEntities = [];
    _isMultiSelect = false;
    _selectedEntity = null;
    _entities = [];
  }
}
