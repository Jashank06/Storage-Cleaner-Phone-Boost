import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/junk_file.dart';

/// Service for detecting and cleaning junk files
class CleanerService {
  /// Scan for junk files
  Future<List<JunkFile>> scanJunkFiles() async {
    List<JunkFile> junkFiles = [];
    
    try {
      // Scan cache directories
      junkFiles.addAll(await _scanCache());
      
      // Scan temp files
      junkFiles.addAll(await _scanTempFiles());
      
      // Scan installers (APKs)
      junkFiles.addAll(await _scanInstallers());
      
      // Scan logs
      junkFiles.addAll(await _scanLogFiles());
      
      // Scan empty folders
      junkFiles.addAll(await _scanEmptyFolders());
      
    } catch (e) {
      print('Error scanning junk files: $e');
    }
    
    return junkFiles;
  }
  
  /// Delete selected junk files
  Future<int> deleteJunkFiles(List<JunkFile> files) async {
    int deletedBytes = 0;
    
    for (final file in files) {
      if (!file.isSelected) continue;
      
      try {
        final fileEntity = File(file.path);
        if (await fileEntity.exists()) {
          deletedBytes += file.size;
          await fileEntity.delete();
        }
      } catch (e) {
        print('Error deleting file ${file.path}: $e');
      }
    }
    
    return deletedBytes;
  }
  
  Future<List<JunkFile>> _scanCache() async {
    List<JunkFile> cacheFiles = [];
    
    try {
      // Get app cache directory
      final cacheDir = await getTemporaryDirectory();
      
      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            final stat = await entity.stat();
            cacheFiles.add(JunkFile(
              path: entity.path,
              size: stat.size,
              category: JunkCategory.cache,
            ));
          }
        }
      }
    } catch (e) {
      print('Error scanning cache: $e');
    }
    
    return cacheFiles;
  }
  
  Future<List<JunkFile>> _scanTempFiles() async {
    List<JunkFile> tempFiles = [];
    
    try {
      final tempDir = await getTemporaryDirectory();
      
      // Scan for .tmp files
      await for (final entity in tempDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.tmp')) {
          final stat = await entity.stat();
          tempFiles.add(JunkFile(
            path: entity.path,
            size: stat.size,
            category: JunkCategory.temp,
          ));
        }
      }
    } catch (e) {
      print('Error scanning temp files: $e');
    }
    
    return tempFiles;
  }
  
  Future<List<JunkFile>> _scanEmptyFolders() async {
    List<JunkFile> emptyFolders = [];
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      
      await for (final entity in appDir.list(recursive: true)) {
        if (entity is Directory) {
          final contents = await entity.list().toList();
          if (contents.isEmpty) {
            emptyFolders.add(JunkFile(
              path: entity.path,
              size: 0,
              category: JunkCategory.emptyFolders,
            ));
          }
        }
      }
    } catch (e) {
      print('Error scanning empty folders: $e');
    }
    
    return emptyFolders;
  }
  
  Future<List<JunkFile>> _scanInstallers() async {
    List<JunkFile> apkFiles = [];
    final scanPaths = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Bluetooth',
      '/storage/emulated/0/Telegram/Telegram Documents',
    ];

    for (var path in scanPaths) {
      try {
        final dir = Directory(path);
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: true)) {
            if (entity is File && entity.path.toLowerCase().endsWith('.apk')) {
              final stat = await entity.stat();
              apkFiles.add(JunkFile(
                path: entity.path,
                size: stat.size,
                category: JunkCategory.apk,
              ));
            }
          }
        }
      } catch (e) { /* skip */ }
    }
    return apkFiles;
  }

  Future<List<JunkFile>> _scanLogFiles() async {
    List<JunkFile> logFiles = [];
    final scanPaths = [
      '/storage/emulated/0',
      '/storage/emulated/0/Android/data',
    ];

    for (var path in scanPaths) {
      try {
        final dir = Directory(path);
        if (await dir.exists()) {
          // Limit depth for root scan to avoid performance hit
          await for (final entity in dir.list(recursive: false)) {
             if (entity is File && entity.path.toLowerCase().endsWith('.log')) {
                final stat = await entity.stat();
                logFiles.add(JunkFile(path: entity.path, size: stat.size, category: JunkCategory.log));
             } else if (entity is Directory && !entity.path.contains('Android/data')) {
                // Scan one level deeper for logs in other folders
                try {
                  await for (final sub in entity.list()) {
                    if (sub is File && sub.path.toLowerCase().endsWith('.log')) {
                       final stat = await sub.stat();
                       logFiles.add(JunkFile(path: sub.path, size: stat.size, category: JunkCategory.log));
                    }
                  }
                } catch (e) {}
             }
          }
        }
      } catch (e) { /* skip */ }
    }
    return logFiles;
  }

  /// Get total size of junk files by category
  int getTotalSize(List<JunkFile> files, {JunkCategory? category}) {
    if (category == null) {
      return files.fold(0, (sum, file) => sum + file.size);
    }
    return files
        .where((f) => f.category == category)
        .fold(0, (sum, file) => sum + file.size);
  }
}
