import 'dart:io';

/// Service for cleaning WhatsApp media files
class WhatsAppCleanerService {
  /// Scan WhatsApp media directories
  Future<List<WhatsAppMedia>> scanWhatsAppMedia() async {
    List<WhatsAppMedia> mediaFiles = [];
    
    try {
      // WhatsApp media paths (Legacy and Modern)
      final basePaths = [
        '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media',
        '/storage/emulated/0/WhatsApp/Media',
      ];
      
      final subCategories = {
        'Status': '.Statuses',
        'Sent Videos': 'WhatsApp Video/Sent',
        'Received Videos': 'WhatsApp Video',
        'Images': 'WhatsApp Images',
        'Voice Notes': 'WhatsApp Voice Notes',
        'Documents': 'WhatsApp Documents',
      };
      
      for (final basePath in basePaths) {
        for (final entry in subCategories.entries) {
          final dir = Directory('$basePath/${entry.value}');
          if (await dir.exists()) {
            await _scanWhatsAppDirectory(dir, entry.key, mediaFiles);
          }
        }
      }
      
    } catch (e) {
      print('Error scanning WhatsApp media: $e');
    }
    
    return mediaFiles;
  }
  
  Future<void> _scanWhatsAppDirectory(
    Directory dir,
    String category,
    List<WhatsAppMedia> mediaFiles,
  ) async {
    try {
      if (!await dir.exists()) return;
      
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            final path = entity.path;
            // Skip non-media control files
            if (path.endsWith('.nomedia')) continue;
            
            final stat = await entity.stat();
            mediaFiles.add(WhatsAppMedia(
              path: entity.path,
              size: stat.size,
              category: category,
              lastModified: stat.modified,
            ));
          } catch (e) {
            // Skip inaccessible files
          }
        }
      }
    } catch (e) {
      print('Error scanning WhatsApp directory ${dir.path}: $e');
    }
  }
  
  /// Delete selected WhatsApp media
  Future<int> deleteWhatsAppMedia(List<WhatsAppMedia> files) async {
    int deletedBytes = 0;
    
    for (final media in files) {
      if (!media.isSelected) continue;
      
      try {
        final file = File(media.path);
        if (await file.exists()) {
          deletedBytes += media.size;
          await file.delete();
        }
      } catch (e) {
        print('Error deleting WhatsApp file ${media.path}: $e');
      }
    }
    
    return deletedBytes;
  }
}

/// Model for WhatsApp media file
class WhatsAppMedia {
  final String path;
  final int size;
  final String category;
  final DateTime lastModified;
  bool isSelected;
  
  WhatsAppMedia({
    required this.path,
    required this.size,
    required this.category,
    required this.lastModified,
    this.isSelected = false,
  });
  
  String get fileName => path.split('/').last;
}
