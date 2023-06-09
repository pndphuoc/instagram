import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';


class FireBaseStorageRepository {
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  static Future<String> uploadFile(File file, String path,
      {bool isVideo = false}) async {
    final ref = _firebaseStorage
        .ref()
        .child(path)
        .child("${DateTime.now().millisecondsSinceEpoch}");
    late SettableMetadata metadata;
    late UploadTask task;
    late dynamic compressedFile;
    if (isVideo) {
      metadata = SettableMetadata(
        contentType: 'video/mp4', // Loại file (image/jpeg, video/mp4,...)
        customMetadata: {
          'picked-file-path': file.path
        },
      );
      compressedFile = await VideoCompress.compressVideo(
        file.absolute.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: true,
      );

      task = ref.putFile(File(compressedFile.path), metadata);
    } else {
      metadata = SettableMetadata(
        contentType: 'image/jpeg', // Loại file (image/jpeg, video/mp4,...)
        customMetadata: {
          'picked-file-path': file.path
        },
      );
      compressedFile = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 90,
      );

      task = ref.putData(
        compressedFile,
        metadata,
      );
    }

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes * 100;
      print('Upload is $progress% done');
    });

    final snapshot = await task.whenComplete(() {});
    return snapshot.ref.getDownloadURL();
  }

  static Future<void> deleteFile(String path) async {
    final ref = _firebaseStorage.ref(path);
    await ref.delete();
  }

  static Future<bool> downloadFile(String url, {bool isVideo = false}) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        late File file;
        final downloadPath = await getExternalStorageDirectories(type: StorageDirectory.dcim);
        if (isVideo) {
          file = File('$downloadPath/${DateTime.now()}.mp4');
        } else {
          file = File('$downloadPath/${DateTime.now()}.png');
        }
        await file.writeAsBytes(response.bodyBytes);
        return true;
      }
    } catch (e) {
      rethrow;
    }
    return false;
  }

  static Future<String> uploadImageFromUrlToFirebaseStorage(String url, String path) async {
    http.Response response = await http.get(Uri.parse(url));
    Uint8List imageData = response.bodyBytes;

    Reference ref = _firebaseStorage
        .ref()
        .child(path)
        .child("${DateTime.now().millisecondsSinceEpoch}");

    // Upload ảnh lên Firebase Storage
    UploadTask uploadTask = ref.putData(imageData);
    TaskSnapshot snapshot = await uploadTask;

    // Trả về URL của ảnh vừa được upload
    return await snapshot.ref.getDownloadURL();
  }
}
