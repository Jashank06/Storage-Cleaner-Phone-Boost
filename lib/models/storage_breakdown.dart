/// Model for storage breakdown by category
class StorageBreakdown {
  final int appsBytes;
  final int photosBytes;
  final int videosBytes;
  final int whatsappBytes;
  final int documentsBytes;
  final int otherBytes;
  
  StorageBreakdown({
    required this.appsBytes,
    required this.photosBytes,
    required this.videosBytes,
    required this.whatsappBytes,
    required this.documentsBytes,
    required this.otherBytes,
  });
  
  int get totalBytes =>
      appsBytes + photosBytes + videosBytes + whatsappBytes + documentsBytes + otherBytes;
  
  double get appsPercentage => _calculatePercentage(appsBytes);
  double get photosPercentage => _calculatePercentage(photosBytes);
  double get videosPercentage => _calculatePercentage(videosBytes);
  double get whatsappPercentage => _calculatePercentage(whatsappBytes);
  double get documentsPercentage => _calculatePercentage(documentsBytes);
  double get otherPercentage => _calculatePercentage(otherBytes);
  
  double _calculatePercentage(int bytes) {
    if (totalBytes == 0) return 0;
    return (bytes / totalBytes) * 100;
  }
  
  factory StorageBreakdown.empty() {
    return StorageBreakdown(
      appsBytes: 0,
      photosBytes: 0,
      videosBytes: 0,
      whatsappBytes: 0,
      documentsBytes: 0,
      otherBytes: 0,
    );
  }
}
