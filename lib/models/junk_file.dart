enum JunkCategory {
  cache,
  temp,
  apk,
  log,
  emptyFolders,
}

/// Model for junk file
class JunkFile {
  final String path;
  final int size;
  final JunkCategory category;
  bool isSelected;
  
  JunkFile({
    required this.path,
    required this.size,
    required this.category,
    this.isSelected = true,
  });
  
  String get fileName {
    return path.split('/').last;
  }
  
  String get categoryName {
    switch (category) {
      case JunkCategory.cache:
        return 'App Cache';
      case JunkCategory.temp:
        return 'Temporary Files';
      case JunkCategory.apk:
        return 'Obsolete APKs';
      case JunkCategory.log:
        return 'System Logs';
      case JunkCategory.emptyFolders:
        return 'Empty Folders';
    }
  }
}
