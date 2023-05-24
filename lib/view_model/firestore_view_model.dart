import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:instagram/repository/firebase_storage_repository.dart';

class FirestoreViewModel extends ChangeNotifier {

  Future<String> uploadFile(File file, String path, {bool isVideo = false}) async {
    return await FireBaseStorageRepository.uploadFile(file, path, isVideo: isVideo);
  }
}