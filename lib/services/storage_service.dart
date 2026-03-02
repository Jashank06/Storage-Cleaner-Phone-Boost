import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/storage_info.dart';
import '../models/storage_breakdown.dart';

/// Service for retrieving device storage information
class StorageService {
  static const _channel = MethodChannel('com.smartphonecleaner.storageboost/storage');

  /// Get current storage information
  Future<StorageInfo> getStorageInfo() async {
    try {
      if (!Platform.isAndroid) {
        return _getMockStorageInfo();
      }

      final Map<dynamic, dynamic>? stats = await _channel.invokeMethod('getStorageStats');
      if (stats == null) return _getMockStorageInfo();

      // We focus on data partition as it more accurately reflects what settings show for total disk
      final int totalBytes = stats['dataTotalSpace'] ?? stats['totalSpace'] ?? 0;
      final int freeBytes = stats['dataAvailableSpace'] ?? stats['availableSpace'] ?? 0;
      final int usedBytes = totalBytes - freeBytes;
      final double usedPercentage = totalBytes > 0 ? (usedBytes / totalBytes) * 100 : 0;

      return StorageInfo(
        totalBytes: totalBytes,
        usedBytes: usedBytes,
        freeBytes: freeBytes,
        usedPercentage: usedPercentage,
      );
    } catch (e) {
      print('Error getting storage info: $e');
      return _getMockStorageInfo();
    }
  }

  /// Get storage breakdown by category
  Future<StorageBreakdown> getStorageBreakdown() async {
    try {
      if (!Platform.isAndroid) {
        return _getMockBreakdown();
      }

      const rootPath = '/storage/emulated/0';
      final rootDir = Directory(rootPath);

      if (!await rootDir.exists()) {
        return _getMockBreakdown();
      }

      int photosBytes = 0;
      int videosBytes = 0;
      int whatsappBytes = 0;
      int documentsBytes = 0;
      int otherBytes = 0;

      // Scan common directories for better performance
      final scanMap = {
        'Photos': ['$rootPath/DCIM', '$rootPath/Pictures'],
        'Videos': ['$rootPath/Movies', '$rootPath/DCIM/Camera'],
        'WhatsApp': [
          '$rootPath/Android/media/com.whatsapp/WhatsApp/Media',
          '$rootPath/WhatsApp/Media'
        ],
        'Documents': ['$rootPath/Documents', '$rootPath/Download'],
      };

      for (var entry in scanMap.entries) {
        for (var path in entry.value) {
          final dir = Directory(path);
          if (await dir.exists()) {
            await for (var entity in dir.list(recursive: true, followLinks: false)) {
              if (entity is File) {
                try {
                  final size = await entity.length();
                  final p = entity.path.toLowerCase();

                  if (p.contains('whatsapp')) {
                    whatsappBytes += size;
                  } else if (_isPhoto(p)) {
                    photosBytes += size;
                  } else if (_isVideo(p)) {
                    videosBytes += size;
                  } else if (_isDocument(p)) {
                    documentsBytes += size;
                  } else {
                    otherBytes += size;
                  }
                } catch (e) { /* skip */ }
              }
            }
          }
        }
      }

      // Calculate Apps & System usage
      final info = await getStorageInfo();
      // Everything else is Apps, System, and smaller un-scanned files
      final scannedTotal = photosBytes + videosBytes + whatsappBytes + documentsBytes + otherBytes;
      int appsBytes = info.usedBytes - scannedTotal;
      if (appsBytes < 0) appsBytes = 0;

      return StorageBreakdown(
        appsBytes: appsBytes,
        photosBytes: photosBytes,
        videosBytes: videosBytes,
        whatsappBytes: whatsappBytes,
        documentsBytes: documentsBytes,
        otherBytes: otherBytes,
      );
    } catch (e) {
      print('Error getting storage breakdown: $e');
      return _getMockBreakdown();
    }
  }

  bool _isPhoto(String path) => 
    path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || 
    path.endsWith('.webp') || path.endsWith('.heic');

  bool _isVideo(String path) => 
    path.endsWith('.mp4') || path.endsWith('.mkv') || path.endsWith('.mov') || 
    path.endsWith('.avi') || path.endsWith('.3gp');

  bool _isDocument(String path) => 
    path.endsWith('.pdf') || path.endsWith('.doc') || path.endsWith('.docx') || 
    path.endsWith('.txt') || path.endsWith('.xlsx') || path.endsWith('.pptx');

  StorageInfo _getMockStorageInfo() {
    const totalBytes = 128 * 1024 * 1024 * 1024; // More realistic mock
    const usedBytes = 85 * 1024 * 1024 * 1024;
    return StorageInfo(
      totalBytes: totalBytes,
      usedBytes: usedBytes,
      freeBytes: totalBytes - usedBytes,
      usedPercentage: (usedBytes / totalBytes) * 100,
    );
  }

  StorageBreakdown _getMockBreakdown() {
    return StorageBreakdown(
      appsBytes: 35 * 1024 * 1024 * 1024,
      photosBytes: 15 * 1024 * 1024 * 1024,
      videosBytes: 20 * 1024 * 1024 * 1024,
      whatsappBytes: 8 * 1024 * 1024 * 1024,
      documentsBytes: 4 * 1024 * 1024 * 1024,
      otherBytes: 3 * 1024 * 1024 * 1024,
    );
  }
}
