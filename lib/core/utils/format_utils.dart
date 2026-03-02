import 'dart:math';

/// Utility functions for formatting file sizes, percentages, and numbers
class FormatUtils {
  /// Format bytes to human-readable size (KB, MB, GB)
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = (log(bytes) / log(1024)).floor();
    
    double size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }
  
  /// Format bytes to MB specifically
  static String formatToMB(int bytes) {
    double mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(2)} MB';
  }
  
  /// Format bytes to GB specifically
  static String formatToGB(int bytes) {
    double gb = bytes / (1024 * 1024 * 1024);
    return '${gb.toStringAsFixed(2)} GB';
  }
  
  /// Format percentage with one decimal place
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
  
  /// Format number with commas (e.g., 1,234,567)
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
  
  /// Get storage usage description
  static String getStorageDescription(double percentage) {
    if (percentage >= 90) {
      return 'Critical! Storage almost full';
    } else if (percentage >= 75) {
      return 'Storage running low';
    } else if (percentage >= 50) {
      return 'Moderate storage usage';
    } else {
      return 'Plenty of space available';
    }
  }
  
  /// Calculate percentage
  static double calculatePercentage(int used, int total) {
    if (total == 0) return 0;
    return (used / total) * 100;
  }
}
