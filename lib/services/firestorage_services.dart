import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../interface/firestorage_interface.dart';

class FireBaseStorageService implements IStorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  @override
  Future<String> uploadFile(File file, String path, {bool isVideo = false}) async {
    final ref = _firebaseStorage.ref().child(path).child("${DateTime.now().millisecondsSinceEpoch}");
    late SettableMetadata metadata;
    if (isVideo) {
      metadata = SettableMetadata(
        contentType: 'video/mp4', // Loại file (image/jpeg, video/mp4,...)
        customMetadata: {'picked-file-path': file.path}, // Lưu đường dẫn file gốc
      );
    } else {
      metadata = SettableMetadata(
        contentType: 'image/jpeg', // Loại file (image/jpeg, video/mp4,...)
        customMetadata: {'picked-file-path': file.path}, // Lưu đường dẫn file gốc
      );
    }
    final task = ref.putFile(
      file,
      metadata,
    );

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress =
          snapshot.bytesTransferred / snapshot.totalBytes * 100;
      print('Upload is $progress% done');
    });

    final snapshot = await task.whenComplete(() {});
    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<void> deleteFile(String path) async {
    final ref = _firebaseStorage.ref(path);
    await ref.delete();
  }

}
