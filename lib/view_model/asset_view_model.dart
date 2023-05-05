import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';

import '../repository/asset_repository.dart';
import '../ultis/colors.dart';

class AssetViewModel extends ChangeNotifier {
  AssetViewModel() {
    loadAssetPathsAndAssets();
  }
  List<AssetPathEntity> _paths = [];
  List<AssetEntity> _entities = [];
  List<AssetEntity> _selectedEntities = [];
  late AssetPathEntity _selectedPath;
  late int entitiesCount;
  bool _isMultiSelect = false;
  AssetEntity? _selectedEntity;
  File? _selectedFile;
  List<GlobalKey<CropState>> cropKeys = [];

  File? get selectedFile => _selectedFile;

  set selectedFile(File? value) {
    _selectedFile = value;
  }

  File? _file;

  File? get file => _file;

  set file(File? value) {
    _file = value;
  }

  AssetEntity? firstAsset;

  List<AssetPathEntity> get paths => _paths;

  List<AssetEntity> get entities => _entities;

  List<AssetEntity> get selectedEntities => _selectedEntities;

  AssetPathEntity get selectedPath => _selectedPath;

  AssetEntity? get selectedEntity => _selectedEntity;

  bool get getIsMultiSelect => _isMultiSelect;

  bool get hasMoreToLoad => _hasMoreToLoad;

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

  Future<void> loadAssetPathList({bool onlyImage = false}) async {
    try {
      _paths = await AssetRepository.loadAssetPathList(onlyImage: onlyImage);

      notifyListeners();
    } catch (e) {
      print(e.toString());
      _paths = [];
    }
  }

  Future<void> loadAssetsOfPath({int page = 0, int sizePerPage = 50}) async {
    _entities.addAll(await AssetRepository.loadAssetsOfPath(_selectedPath,
        page: page, sizePerPage: sizePerPage));
    if (page == 0) {
      _selectedEntity = _entities.first;
    }
    entitiesCount = await _selectedPath.assetCountAsync;
    _hasMoreToLoad = _entities.length < entitiesCount;
    notifyListeners();
  }

  Future<bool> loadAssetPathsAndAssets({bool onlyImage = false}) async {
    try {
      await loadAssetPathList(onlyImage: onlyImage);
      _selectedPath = _paths.first;
      await loadAssetsOfPath();

      _selectedEntity = _entities.first;
      notifyListeners();
      return true;
    } catch (err) {
      return false;
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

    print(_selectedEntity!.type.name);

    notifyListeners();
  }

/*  void onTapEntityInMessage(AssetEntity entity) {
    _isMultiSelect = true;

    bool isExistInSelectedEntities = _selectedEntities.contains(entity);

    if (isExistInSelectedEntities) {
      _selectedEntities.remove(entity);
    } else {
      _selectedEntities.add(entity);

      notifyListeners();
    }
  }*/

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

  void onUploadButtonTap({File? file}) {
    if (file != null) {
      _file = file;
    } else if (selectedFile == null) {
      firstAsset =
          selectedEntities.isEmpty ? selectedEntity : selectedEntities.first;
    }
  }

  void resetAssetViewModel() {
    _selectedEntities = [];
    _isMultiSelect = false;
    _selectedEntity = null;
    _entities = [];
  }

  Future<File> cropImage(AssetEntity image) async {
    try {
      final file = File(image.relativePath!);
      final croppedImage = await ImageCropper().cropImage(
          sourcePath: file.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          cropStyle: CropStyle.rectangle,
          compressFormat: ImageCompressFormat.png,
          compressQuality: 80,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop and resize',
                toolbarColor: mobileBackgroundColor,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                backgroundColor: mobileBackgroundColor,
                activeControlsWidgetColor: primaryColor,
                statusBarColor: mobileBackgroundColor,
                lockAspectRatio: true),
            IOSUiSettings(
              title: 'Edit photo',
            ),
          ]);

      return File(croppedImage!.path);
    } catch (e) {
      rethrow;
    }
  }

  Future<File?> assetEntityToFile(AssetEntity entity) async {
    try {
      return await entity.file;
    } catch (e) {
      rethrow;
    }
  }
}
