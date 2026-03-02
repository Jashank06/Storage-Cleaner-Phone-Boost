import 'dart:io';
import 'package:crypto/crypto.dart';
import '../models/duplicate_group.dart';

/// Service for detecting duplicate photos using hash-based comparison
class DuplicateService {
  /// Scan for duplicate photos
  Future<List<DuplicateGroup>> scanDuplicatePhotos() async {
    try {
      // Step 1: Group by file size (much faster than hashing everything)
      Map<int, List<String>> sizeMap = {};
      
      final directories = [
        Directory('/storage/emulated/0/DCIM'),
        Directory('/storage/emulated/0/Pictures'),
      ];
      
      for (final directory in directories) {
        if (!await directory.exists()) continue;
        
        await for (final entity in directory.list(recursive: true, followLinks: false)) {
          if (entity is File && _isImageFile(entity.path)) {
            try {
              final length = await entity.length();
              if (length > 0) {
                sizeMap.putIfAbsent(length, () => []).add(entity.path);
              }
            } catch (e) { /* skip */ }
          }
        }
      }

      // Step 2: Only hash files that have the same size
      Map<String, List<String>> hashMap = {};
      for (final entry in sizeMap.entries) {
        if (entry.value.length > 1) {
          for (final path in entry.value) {
            try {
              final hash = await _calculateFileHash(File(path));
              hashMap.putIfAbsent(hash, () => []).add(path);
            } catch (e) { /* skip */ }
          }
        }
      }
      
      List<DuplicateGroup> duplicateGroups = [];
      for (final entry in hashMap.entries) {
        if (entry.value.length > 1) {
          int totalSize = 0;
          for (final path in entry.value) {
            try {
              final stat = await File(path).stat();
              totalSize += stat.size;
            } catch (e) { /* ignore */ }
          }
          
          duplicateGroups.add(DuplicateGroup(
            hash: entry.key,
            filePaths: entry.value,
            totalSize: totalSize,
          ));
        }
      }
      
      return duplicateGroups;
    } catch (e) {
      print('Error scanning duplicates: $e');
      return [];
    }
  }
  
  /// Delete selected duplicate files
  Future<int> deleteDuplicates(List<DuplicateGroup> groups) async {
    int deletedBytes = 0;
    for (final group in groups) {
      for (final filePath in group.selectedFiles) {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            final stat = await file.stat();
            deletedBytes += stat.size;
            await file.delete();
          }
        } catch (e) {
          print('Error deleting duplicate file $filePath: $e');
        }
      }
    }
    return deletedBytes;
  }
  
  /// Calculate MD5 hash of a file
  /// For very large files, we only hash the first 1MB and the last 1MB for speed
  Future<String> _calculateFileHash(File file) async {
    try {
      final length = await file.length();
      if (length > 2 * 1024 * 1024) { // > 2MB
        final bytes = await file.openRead(0, 512 * 1024).toList(); // First 512KB
        final endBytes = await file.openRead(length - 512 * 1024, length).toList(); // Last 512KB
        final combined = [...bytes.expand((x) => x), ...endBytes.expand((x) => x)];
        return md5.convert(combined).toString();
      } else {
        final stream = file.openRead();
        final hash = await md5.bind(stream).first;
        return hash.toString();
      }
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch.toString(); // Fallback
    }
  }
  
  bool _isImageFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.webp') ||
        ext.endsWith('.heic');
  }
}
