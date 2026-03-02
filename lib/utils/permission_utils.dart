import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      
      if (deviceInfo.version.sdkInt >= 30) {
        // Android 11+ (R)
        var status = await Permission.manageExternalStorage.status;
        if (status.isGranted) {
          return true;
        } else {
          status = await Permission.manageExternalStorage.request();
          return status.isGranted;
        }
      } else {
        // Android 10 and below
        var status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        } else {
          status = await Permission.storage.request();
          return status.isGranted;
        }
      }
    }
    return false;
  }
  
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 30) {
        return await Permission.manageExternalStorage.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return false;
  }
}
