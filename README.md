# Smart Phone Cleaner – Storage Manager

A premium Flutter Android application for storage management with a beautiful liquid glass UI design featuring neon green accents and 3D effects.

![Version](https://img.shields.io/badge/version-1.0.0-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.16%2B-blue)
![License](https://img.shields.io/badge/license-MIT-blue)

## ✨ Features

### Core Functionality
- **Real Storage Analysis**: Get actual device storage statistics
- **Junk File Cleaner**: Remove cache, temp files, and empty folders
- **Duplicate Photo Finder**: Hash-based duplicate detection using MD5
- **Large Files Manager**: Identify and remove files > 100MB
- **WhatsApp Media Cleaner**: Clean WhatsApp media by category
- **Storage Breakdown Chart**: Visual analysis of storage by category

### Premium UI/UX
- **Liquid Glass Design**: Semi-transparent white cards with 3D depth effects
- **Neon Green Accents**: Vibrant green gradient (#00FF88 → #10D97A)
- **Smooth Animations**: Page transitions, stagger effects, confetti celebrations
- **Onboarding Flow**: 3 beautiful swipeable slides for first-time users
- **Pull-to-Refresh**: Native gesture support for updating storage data
- **Haptic Feedback**: Tactile responses on buttons and actions

### Play Store Ready
- **Minimum Required Permissions**: Only essential storage permissions
- **No False Claims**: Real functionality, no fake RAM boost or battery saver
- **AdMob Integration Structure**: Ready for monetization with frequency capping
- **Compliant with Google Play Policies**: Safe operations, user-controlled deletions

## 🎨 Design System

### Color Palette
- **Background**: `#0F172A` (Dark Navy)
- **Liquid Glass White**: `rgba(255, 255, 255, 0.08-0.15)`
- **Neon Green Primary**: `#00FF88`
- **Neon Green Secondary**: `#10D97A`

### 3D Glass Effects
- Multi-layer shadows (outer + inner)
- Backdrop blur (8-12px)
- Border gradients (white 0.2-0.4 opacity)
- Optional green glow for active states

### Typography
- **Font**: Poppins (Medium, SemiBold, Bold)
- **Heading**: 24-32px
- **Body**: 14-16px
- **Small**: 12px

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.16 or higher
- Android Studio or VS Code with Flutter extension
- Android SDK (API 21-34)
- Physical Android device or emulator for testing

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd "Storage Cleaner – Phone Boost"
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

4. **Build APK for testing**
```bash
flutter build apk --debug
```

5. **Build release bundle for Play Store**
```bash
flutter build appbundle --release
```

## 📱 AdMob Integration (Optional)

The app includes AdMob integration structure with placeholders. To enable ads:

### Step 1: Setup AdMob Account
1. Create account at [https://admob.google.com](https://admob.google.com)
2. Create a new app in AdMob console
3. Generate Ad Unit IDs for:
   - Interstitial Ads
   - Native Ads

### Step 2: Update Dependencies
Uncomment in `pubspec.yaml`:
```yaml
google_mobile_ads: ^4.0.0
```

### Step 3: Add AdMob App ID
Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

### Step 4: Update Ad Unit IDs
In `lib/services/ad_service.dart`, replace placeholder IDs with your actual Unit IDs.

### Step 5: Test Ads
```bash
flutter run
```

## 🔐 Permissions

The app uses the following permissions:

### Storage Permissions
- `READ_EXTERNAL_STORAGE` (Android 12 and below)
- `READ_MEDIA_IMAGES` (Android 13+)
- `READ_MEDIA_VIDEO` (Android 13+)
- `MANAGE_EXTERNAL_STORAGE` (Android 11+, for advanced cleaning)

### Other Permissions
- `INTERNET` - For AdMob ads servicing
- `ACCESS_NETWORK_STATE` - For network status checks
- `VIBRATE` - For haptic feedback

### Play Store Permission Declaration

When submitting to Play Store, you MUST justify storage permissions:

**Declaration Template:**
```
READ_MEDIA_IMAGES & READ_MEDIA_VIDEO:
- Used to scan for duplicate photos and videos
- Allows users to free up storage by removing duplicates
- Users have full control over which files to delete

MANAGE_EXTERNAL_STORAGE:
- Required for advanced junk file cleaning (Android 11+)
- Enables detection of cache and temp files across the device
- All deletions require explicit user confirmation
```

## 📦 Project Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # App configuration
├── core/
│   ├── theme/
│   │   └── app_theme.dart    # Liquid glass theme
│   ├── constants/
│   │   └── app_constants.dart # App constants
│   ├── utils/
│   │   └── format_utils.dart  # Formatting utilities
│   └── animations/
│       ├── page_transitions.dart
│       └── stagger_animation.dart
├── models/
│   ├── storage_info.dart
│   ├── storage_breakdown.dart
│   ├── junk_file.dart
│   ├── duplicate_group.dart
│   ├── large_file.dart
│   └── scan_result.dart
├── services/
│   ├── storage_service.dart
│   ├── cleaner_service.dart
│   ├── duplicate_service.dart
│   ├── large_files_service.dart
│   ├── whatsapp_cleaner_service.dart
│   └── ad_service.dart
├── widgets/
│   ├── glass_card.dart
│   ├── storage_indicator.dart
│   ├── storage_breakdown_chart.dart
│   ├── feature_card.dart
│   ├── native_ad_widget.dart
│   └── confetti_overlay.dart
└── screens/
    ├── splash_screen.dart
    ├── onboarding_screen.dart
    ├── home_screen.dart
    └── settings_screen.dart
```

## ⚠️ Google Play Compliance

### What This App Does:
✅ Cleans junk files (cache, temp, empty folders)  
✅ Finds duplicate photos using hash comparison  
✅ Identifies large files for user-managed deletion  
✅ Organizes WhatsApp media by category  
✅ Provides real storage statistics  

### What This App Does NOT Do:
❌ No fake RAM boost or speed boost  
❌ No system file modifications  
❌ No root access required  
❌ No automatic deletions without user confirmation  
❌ No access to personal data (contacts, messages, etc.)  

### Safety Features:
- All scans are read-only until user confirms deletion
- Confirmation dialogs before any file removal
- Only accesses user-accessible storage areas
- No background services or auto-cleaning

## 🛠️ Development Tips

### Testing Storage Features
1. Use a physical device with actual files for realistic testing
2. Create test duplicate images for duplicate finder
3. Test on both Android 12 and Android 13+ for permission compatibility

### Debugging Tips
```bash
# View detailed logs
flutter logs

# Run with verbose output
flutter run -v

# Check for lint issues
flutter analyze
```

### Building for Release
1. Update version in `pubspec.yaml`
2. Update `android/app/build.gradle` version codes
3. Configure signing (see Flutter docs)
4. Build app bundle: `flutter build appbundle --release`

## 🎯 TODO / Future Enhancements

- [ ] Implement remaining screens (scan, results, detail screens)
- [ ] Add platform channels for exact storage stats (StatFs)
- [ ] Integrate real AdMoba ads
- [ ] Add MediaStore API integration for better image scanning
- [ ] Implement home screen widget
- [ ] Add in-app purchases for ad removal
- [ ] Add analytics integration
- [ ] Scheduled cleaning feature
- [ ] Photo compressor
- [ ] App manager (rarely used apps)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For support, email: support@yourwebsite.com  
Play Store: [App Link](https://play.google.com/store)

---

**Made with ❤️ using Flutter**
