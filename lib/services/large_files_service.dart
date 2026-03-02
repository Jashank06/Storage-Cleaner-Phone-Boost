import 'dart:io';
import '../models/large_file.dart';

/// Service for detecting large files
class LargeFilesService {
  final int thresholdBytes;
  
  LargeFilesService({this.thresholdBytes = 100 * 1024 * 1024}); // 100 MB default
  
  /// Scan for large files
  Future<List<LargeFile>> scanLargeFiles() async {
    List<LargeFile> largeFiles = [];
    
    try {
      // Scan common directories
      final directories = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Documents',
      ];

      for (final dirPath in directories) {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          await _scanDirectory(dir, largeFiles);
        }
      }
      
      // Sort by size (largest first)
      largeFiles.sort((a, b) => b.size.compareTo(a.size));
      
    } catch (e) {
      print('Error scanning large files: $e');
    }
    
    return largeFiles;
  }
  
  Future<void> _scanDirectory(Directory dir, List<LargeFile> largeFiles) async {
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            
            if (stat.size >= thresholdBytes) {
              largeFiles.add(LargeFile(
                path: entity.path,
                size: stat.size,
                fileType: _getFileType(entity.path),
                lastModified: stat.modified,
              ));
            }
          } catch (e) {
            // Skip files we can't access
          }
        }
      }
    } catch (e) {
      print('Error scanning directory ${dir.path}: $e');
    }
  }
  
  /// Delete selected large files
  Future<int> deleteLargeFiles(List<LargeFile> files) async {
    int deletedBytes = 0;
    
    for (final largeFile in files) {
      if (!largeFile.isSelected) continue;
      
      try {
        final file = File(largeFile.path);
        if (await file.exists()) {
          deletedBytes += largeFile.size;
          await file.delete();
        }
      } catch (e) {
        print('Error deleting file ${largeFile.path}: $e');
      }
    }
    
    return deletedBytes;
  }
  
  String _getFileType(String path) {
    final ext = path.split('.').last.toLowerCase();
    
    if (['mp4', 'avi', 'mkv', 'mov', 'wmv'].contains(ext)) {
      return 'Video';
    } else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      return 'Image';
    } else if (['pdf', 'doc', 'docx', 'txt'].contains(ext)) {
      return 'Document';
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      return 'Archive';
    } else if (['mp3', 'wav', 'flac', 'm4a'].contains(ext)) {
      return 'Audio';
    } else {
      return 'Other';
    }
  }
}
