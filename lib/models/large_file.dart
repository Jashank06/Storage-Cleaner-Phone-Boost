/// Model for large file
class LargeFile {
  final String path;
  final int size;
  final String fileType;
  final DateTime lastModified;
  bool isSelected;
  
  LargeFile({
    required this.path,
    required this.size,
    required this.fileType,
    required this.lastModified,
    this.isSelected = false,
  });
  
  String get fileName {
    return path.split('/').last;
  }
  
  String get trimmedPath {
    // Show last 2 directories
    List<String> parts = path.split('/');
    if (parts.length > 3) {
      return '.../${parts[parts.length - 2]}/${parts[parts.length - 1]}';
    }
    return path;
  }
  
  String get extension {
    if (fileName.contains('.')) {
      return fileName.split('.').last.toUpperCase();
    }
    return 'FILE';
  }
}
