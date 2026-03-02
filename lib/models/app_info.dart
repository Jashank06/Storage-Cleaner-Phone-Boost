import 'dart:typed_data';

class AppInfo {
  final String packageName;
  final String appName;
  final Uint8List? icon;
  final int size; // Total size in bytes
  final int cacheSize; // Cache size in bytes
  final DateTime? lastUsed;
  final bool isSystemApp;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.icon,
    required this.size,
    required this.cacheSize,
    this.lastUsed,
    required this.isSystemApp,
  });

  factory AppInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppInfo(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      icon: map['icon'] as Uint8List?,
      size: map['size'] as int? ?? 0,
      cacheSize: map['cacheSize'] as int? ?? 0,
      lastUsed: map['lastUsed'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUsed'] as int)
          : null,
      isSystemApp: map['isSystemApp'] as bool? ?? false,
    );
  }
}
