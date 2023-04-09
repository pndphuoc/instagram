import 'dart:io';

abstract class IStorageService {
  Future<String> uploadFile(File file, String path, {bool isVideo = false});
  Future<void> deleteFile(String url);
}
