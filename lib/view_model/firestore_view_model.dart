import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:instagram/services/firebase_storage_services.dart';

class FirestoreViewModel extends ChangeNotifier {
  final FireBaseStorageService _firestoreService = FireBaseStorageService();

  Future<String> uploadFile(File file, String path, {bool isVideo = false}) async {
    return await _firestoreService.uploadFile(file, path, isVideo: isVideo);
  }
}