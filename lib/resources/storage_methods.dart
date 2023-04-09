import 'dart:typed_data';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPhotoToStorage(
      String childName, Uint8List file, bool isPost) async {
    Reference ref =
        _storage.ref().child(childName).child("${DateTime.now().millisecondsSinceEpoch}");

    SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg', // Loại file (image/jpeg, video/mp4,...)
    );

    UploadTask uploadTask = ref.putData(file, metadata);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Upload ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
    });

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadVideoToStorage(File file) async {
    String videoPath = 'videos/${DateTime.now().millisecondsSinceEpoch}.mp4';

    final storageRef = _storage.ref().child(videoPath);

    SettableMetadata metadata = SettableMetadata(
      contentType: 'video/mp4', // Loại file (image/jpeg, video/mp4,...)
    );

    final UploadTask uploadTask = storageRef.putFile(file, metadata);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Upload ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
    });

    final TaskSnapshot downloadUrl =
        (await uploadTask.whenComplete(() => null));
    final String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }
}
