/// Model for scan results
class ScanResult {
  final int junkFilesSize;
  final int junkFilesCount;
  final int duplicatePhotosSize;
  final int duplicatePhotosCount;
  final int largeFilesSize;
  final int largeFilesCount;
  final int whatsappMediaSize;
  final int whatsappMediaCount;
  
  ScanResult({
    required this.junkFilesSize,
    required this.junkFilesCount,
    required this.duplicatePhotosSize,
    required this.duplicatePhotosCount,
    required this.largeFilesSize,
    required this.largeFilesCount,
    required this.whatsappMediaSize,
    required this.whatsappMediaCount,
  });
  
  int get totalSavings =>
      junkFilesSize + duplicatePhotosSize + largeFilesSize + whatsappMediaSize;
  
  int get totalCount =>
      junkFilesCount + duplicatePhotosCount + largeFilesCount + whatsappMediaCount;
  
  factory ScanResult.empty() {
    return ScanResult(
      junkFilesSize: 0,
      junkFilesCount: 0,
      duplicatePhotosSize: 0,
      duplicatePhotosCount: 0,
      largeFilesSize: 0,
      largeFilesCount: 0,
      whatsappMediaSize: 0,
      whatsappMediaCount: 0,
    );
  }
}
