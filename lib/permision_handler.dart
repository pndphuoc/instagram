import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionHandler with ChangeNotifier {
  static Future<bool> requestPermissions() async {
    List<Permission> permissionsToRequest = [];

/*    // Kiểm tra quyền thông báo
    if (await Permission.notification.status != PermissionStatus.granted) {
      permissionsToRequest.add(Permission.notification);
    }*/

/*    // Kiểm tra quyền truy cập vị trí
    if (await Permission.accessMediaLocation.status != PermissionStatus.granted) {
      permissionsToRequest.add(Permission.accessMediaLocation);
    }*/

    // Kiểm tra quyền truy cập ảnh và video
    if (await Permission.photos.status != PermissionStatus.granted) {
      permissionsToRequest.add(Permission.photos);
    }

    // Kiểm tra quyền truy cập bộ nhớ
    if (await Permission.storage.status != PermissionStatus.granted) {
      permissionsToRequest.add(Permission.storage);
    }

    if (permissionsToRequest.isNotEmpty) {
      Map<Permission, PermissionStatus> permissionStatuses =
      await permissionsToRequest.request();

      bool allGranted = true;

      permissionStatuses.forEach((permission, permissionStatus) {
        if (!permissionStatus.isGranted) {
          allGranted = false;
        }
      });

      return allGranted;
    }

    return true;
  }
}
