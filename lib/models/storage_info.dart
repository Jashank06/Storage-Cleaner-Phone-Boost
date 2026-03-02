/// Model for device storage information
class StorageInfo {
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;
  final double usedPercentage;
  
  StorageInfo({
    required this.totalBytes,
    required this.usedBytes,
    required this.freeBytes,
    required this.usedPercentage,
  });
  
  factory StorageInfo.empty() {
    return StorageInfo(
      totalBytes: 0,
      usedBytes: 0,
      freeBytes: 0,
      usedPercentage: 0.0,
    );
  }
}
