/// App-wide constants for colors, dimensions, and configuration
class AppConstants {
  // Colors
  static const String backgroundColorHex = '#0F172A';
  static const String neonGreenHex = '#00FF88';
  static const String neonGreenSecondaryHex = '#10D97A';
  
  // Dimensions
  static const double cardBorderRadius = 24.0;
  static const double buttonBorderRadius = 20.0;
  static const double largeBorderRadius = 28.0;
  static const double smallBorderRadius = 16.0;
  
  static const double cardPadding = 20.0;
  static const double screenPadding = 16.0;
  static const double gridSpacing = 16.0;
  
  // 3D Effects
  static const double blurRadius = 12.0;
  static const double shadowBlurRadius = 24.0;
  static const double borderWidth = 1.5;
  
  // Animation Durations (in milliseconds)
  static const int fastAnimationDuration = 200;
  static const int normalAnimationDuration = 300;
  static const int slowAnimationDuration = 600;
  
  // File Size Thresholds
  static const int largeFileSizeThresholdMB = 100;
  static const int largeFileSizeThresholdBytes = largeFileSizeThresholdMB * 1024 * 1024;
  
  // WhatsApp Paths
  static const String whatsappMediaPath = '/WhatsApp/Media';
  static const String whatsappStatusPath = '/WhatsApp/Media/.Statuses';
  static const String whatsappSentPath = '/WhatsApp/Media/WhatsApp Video/Sent';
  
  // Ad Configuration
  static const int maxAdsPerSession = 3;
  static const int adFrequencyMinutes = 5;
  
  // App Info
  static const String appName = 'Smart Phone Cleaner';
  static const String appVersion = '1.0.0';
  static const String privacyPolicyUrl = 'https://storage.emailsenderprox.online/#privacy';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.smartphonecleaner.storageboost';
  
  // SharedPreferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyAdCount = 'ad_count';
  static const String keyLastAdTime = 'last_ad_time';
  static const String keyTotalSpaceFreed = 'total_space_freed';
  
  // Strings
  static const String scanningMessage = 'Scanning your device...';
  static const String analyzingMessage = 'Analyzing storage...';
  static const String cleaningMessage = 'Cleaning files...';
  static const String completedMessage = 'Cleaning completed!';
}
