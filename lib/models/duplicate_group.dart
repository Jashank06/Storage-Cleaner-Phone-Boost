/// Model for a group of duplicate photos
class DuplicateGroup {
  final String hash;
  final List<String> filePaths;
  final int totalSize;
  final List<String> selectedFiles;
  
  DuplicateGroup({
    required this.hash,
    required this.filePaths,
    required this.totalSize,
    List<String>? selectedFiles,
  }) : selectedFiles = selectedFiles ?? [];
  
  int get duplicateCount => filePaths.length;
  
  /// Get potential space saving (keep one, delete rest)
  int get potentialSavings {
    if (duplicateCount <= 1) return 0;
    return (totalSize ~/ duplicateCount) * (duplicateCount - 1);
  }
  
  /// Total size of selected files
  int get selectedSize {
    if (selectedFiles.isEmpty || duplicateCount == 0) return 0;
    // Estimate size of each file
    int sizePerFile = totalSize ~/ duplicateCount;
    return sizePerFile * selectedFiles.length;
  }
}
