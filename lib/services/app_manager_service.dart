import 'package:flutter/services.dart';
import '../models/app_info.dart';
import 'dart:io';

class AppManagerService {
  static const _channel = MethodChannel('com.smartphonecleaner.storageboost/storage');

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      if (!Platform.isAndroid) {
        return _getMockApps();
      }

      final List<dynamic>? apps = await _channel.invokeMethod('getInstalledApps');
      if (apps == null) return [];

      return apps.map((app) => AppInfo.fromMap(app as Map<dynamic, dynamic>)).toList();
    } catch (e) {
      print('Error getting installed apps: $e');
      return _getMockApps();
    }
  }

  Future<void> uninstallApp(String packageName) async {
    try {
      await _channel.invokeMethod('uninstallApp', {'packageName': packageName});
    } catch (e) {
      print('Error uninstalling app: $e');
    }
  }

  Future<bool> checkUsageStatsPermission() async {
    try {
      if (!Platform.isAndroid) return true;
      return await _channel.invokeMethod('checkUsageStatsPermission') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> openUsageStatsSettings() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('openUsageStatsSettings');
      }
    } catch (e) {}
  }

  List<AppInfo> _getMockApps() {
    return [
      AppInfo(
        packageName: 'com.example.app1',
        appName: 'Messenger',
        size: 150 * 1024 * 1024,
        cacheSize: 50 * 1024 * 1024,
        isSystemApp: false,
        lastUsed: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AppInfo(
        packageName: 'com.example.app2',
        appName: 'Photo Editor',
        size: 300 * 1024 * 1024,
        cacheSize: 120 * 1024 * 1024,
        isSystemApp: false,
        lastUsed: DateTime.now().subtract(const Duration(days: 10)),
      ),
      AppInfo(
        packageName: 'com.android.settings',
        appName: 'Settings',
        size: 20 * 1024 * 1024,
        cacheSize: 2 * 1024 * 1024,
        isSystemApp: true,
      ),
    ];
  }
}
