import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionHandler with ChangeNotifier {
  static Future<bool> requestMediasPermissions() async {
    List<Permission> permissionsToRequest = [];

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        if (await Permission.storage.status != PermissionStatus.granted) {
          permissionsToRequest.add(Permission.storage);
        }
        if (await Permission.accessMediaLocation.status != PermissionStatus.granted) {
          permissionsToRequest.add(Permission.storage);
        }
      }  else {
        if (await Permission.photos.status != PermissionStatus.granted) {
          permissionsToRequest.add(Permission.photos);
        }

        if (await Permission.videos.status != PermissionStatus.granted) {
          permissionsToRequest.add(Permission.photos);
        }
      }
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
