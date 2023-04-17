import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

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

    final compressedFile = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1024,
      minHeight: 1024,
      quality: 90,
    );

    final task = ref.putData(
      compressedFile!,
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

  @override
  Future<bool> downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Save file to device
      final directory = await getExternalStorageDirectory();
      print(directory!.path);
      final file = File('/storage/emulated/0/DCIM/${DateTime.now()}.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return true;
    }
    return false;
  }

}
