import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../core/theme/app_theme.dart';

class FilePreviewIcon extends StatelessWidget {
  final String path;
  final int size; // File size in bytes (optional, for display logic if needed)
  final double iconSize;

  const FilePreviewIcon({
    super.key,
    required this.path,
    this.size = 0,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final extension = path.split('.').last.toLowerCase();

    if (_isImage(extension)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildGenericIcon(Icons.image_not_supported),
        ),
      );
    } else if (_isVideo(extension)) {
      return _buildVideoThumbnail();
    } else if (_isAudio(extension)) {
      return _buildIcon(Icons.audiotrack_rounded, Colors.purpleAccent);
    } else if (_isPdf(extension)) {
      return _buildIcon(Icons.picture_as_pdf_rounded, Colors.redAccent);
    } else if (_isWord(extension)) {
      return _buildIcon(Icons.description_rounded, Colors.blueAccent);
    } else if (_isExcel(extension)) {
      return _buildIcon(Icons.table_chart_rounded, Colors.greenAccent);
    } else if (_isPowerPoint(extension)) {
      return _buildIcon(Icons.slideshow_rounded, Colors.orangeAccent);
    } else if (_isApk(extension)) {
      return _buildIcon(Icons.android_rounded, const Color(0xFF3DDC84));
    } else if (_isArchive(extension)) {
      return _buildIcon(Icons.folder_zip_rounded, Colors.amberAccent);
    } else {
      return _buildGenericIcon(Icons.insert_drive_file_rounded);
    }
  }

  Widget _buildVideoThumbnail() {
    // Generate thumbnail in memory or cache
    return FutureBuilder<String?>(
      future: VideoThumbnail.thumbnailFile(
        video: path,
        thumbnailPath: null, // use default cache
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128, // optimized size
        quality: 50,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(snapshot.data!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildIcon(Icons.videocam_off, Colors.red),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          );
        }
        return Container(
          color: Colors.black12,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }

  Widget _buildGenericIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white54, size: iconSize),
      ),
    );
  }

  bool _isImage(String ext) => ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  bool _isVideo(String ext) => ['mp4', 'mkv', 'webm', 'avi', 'mov', '3gp'].contains(ext);
  bool _isAudio(String ext) => ['mp3', 'aac', 'wav', 'ogg', 'm4a', 'opus'].contains(ext);
  bool _isPdf(String ext) => ext == 'pdf';
  bool _isWord(String ext) => ['doc', 'docx'].contains(ext);
  bool _isExcel(String ext) => ['xls', 'xlsx', 'csv'].contains(ext);
  bool _isPowerPoint(String ext) => ['ppt', 'pptx'].contains(ext);
  bool _isApk(String ext) => ext == 'apk' || ext == 'xapk';
  bool _isArchive(String ext) => ['zip', 'rar', '7z', 'tar', 'gz'].contains(ext);
}
