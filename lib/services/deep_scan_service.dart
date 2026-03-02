import 'dart:io';
import '../models/junk_file.dart';

/// Deep Scan Service for identifying hidden/app-specific junk
class DeepScanService {
  static const List<String> deepPaths = [
    '/storage/emulated/0/Android/data/com.whatsapp/cache',
    '/storage/emulated/0/Android/data/com.facebook.katana/cache',
    '/storage/emulated/0/Android/data/com.instagram.android/cache',
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Links',
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/Pictures/.thumbnails',
    '/storage/emulated/0/DCIM/.thumbnails',
    '/storage/emulated/0/.thumbnails',
  ];

  /// Scans for deep-seated junk files
  Future<List<JunkFile>> scanDeepJunk() async {
    List<JunkFile> results = [];
    
    for (String path in deepPaths) {
      try {
        final dir = Directory(path);
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final stat = await entity.stat();
              results.add(JunkFile(
                path: entity.path,
                size: stat.size,
                category: JunkCategory.cache, // Treating deep scan as deep cache
              ));
            }
          }
        }
      } catch (e) {
        // Skip inaccessible folders
      }
    }
    
    return results;
  }

  /// Categorize results by app/source if needed
  Map<String, List<JunkFile>> groupResultsBySource(List<JunkFile> files) {
    Map<String, List<JunkFile>> grouped = {};
    for (var file in files) {
      String source = 'General';
      if (file.path.contains('com.whatsapp')) source = 'WhatsApp';
      else if (file.path.contains('com.facebook')) source = 'Facebook';
      else if (file.path.contains('com.instagram')) source = 'Instagram';
      else if (file.path.contains('.thumbnails')) source = 'Thumbnails';
      
      grouped.putIfAbsent(source, () => []).add(file);
    }
    return grouped;
  }
}
