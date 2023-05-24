import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:instagram/ultis/colors.dart';

enum VideoRecordingState {recording, paused, stop, resume}

class CameraViewModel extends ChangeNotifier {
  final CameraController _controller;

  CameraController get controller => _controller;

  CameraViewModel(this._controller);



  final _videoController = StreamController<String>();
  Stream<String> get videoStream => _videoController.stream;

  Future<File> takePicture({bool isSendMessage = false}) async {
    try {
      if (isSendMessage) {
        return File((await _controller.takePicture()).path);
      }
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
      _videoController.sink.add('recording');
      await _controller.startVideoRecording();
    } catch (e) {
      print(e);
    }
  }

  Future<XFile> stopRecording() async {
    try {
      _videoController.sink.add('stop');
      return await _controller.stopVideoRecording();
    } catch (e) {
      rethrow;
    }
  }

  void pauseRecording() async {
    try {
      _videoController.sink.add('pause');
      await _controller.pauseVideoRecording();
    } catch (e) {
      print(e);
    }
  }

  void resumeRecording() async {
    try {
      _videoController.sink.add('recording');
      await _controller.resumeVideoRecording();
    } catch (e) {
      print(e);
    }
  }

  double calculatePercentage(int elapsedSeconds) {
    if (elapsedSeconds >= 60) {
      return 1.0;
    } else {
      return elapsedSeconds / 60.0;
    }
  }


  @override
  void dispose() {
    _videoController.close();
    _controller.dispose();
    super.dispose();
  }
}
