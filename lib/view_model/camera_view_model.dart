import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:instagram/ultis/colors.dart';

class CameraViewModel extends ChangeNotifier {
  final CameraController _controller;
  CameraViewModel(this._controller);
  Future<File> takePicture() async {
    try {
      final capturedImage = await _controller.takePicture();
      return await cropImage(capturedImage);
/*      final img.Image capturedImage = img.decodeImage(await File(image.path).readAsBytes())!;
      final img.Image orientedImage = img.bakeOrientation(capturedImage);
      return await File(image.path).writeAsBytes(img.encodeJpg(orientedImage));*/

    } catch (e) {
      rethrow;
    }
  }

  Future<File> cropImage(XFile image) async {
    try {
      final croppedImage = await ImageCropper().cropImage(sourcePath: image.path,
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
        ]
      );

      return File(croppedImage!.path);
    } catch (e) {
      rethrow;
    }
  }

  void startRecording() async {
    try {
      await _controller.startVideoRecording();
    } catch (e) {
      print(e);
    }
  }

  void stopRecording() async {
    try {
      await _controller.stopVideoRecording();
    } catch (e) {
      print(e);
    }
  }
}