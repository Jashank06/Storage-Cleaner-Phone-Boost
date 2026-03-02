import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/storage_indicator.dart';
import '../widgets/storage_breakdown_chart.dart';
import '../widgets/feature_card.dart';
import '../widgets/native_ad_widget.dart';
import '../widgets/glassmorphism_background.dart';
import '../services/storage_service.dart';
import '../models/storage_info.dart';
import '../models/storage_breakdown.dart';
import '../utils/permission_utils.dart';
import 'settings_screen.dart';
import 'junk_cleaner_screen.dart';
import 'scan_screen.dart';
import 'duplicate_finder_screen.dart';
import 'large_files_screen.dart';
import 'whatsapp_cleaner_screen.dart';
import 'battery_saver_screen.dart';
import 'ram_boost_screen.dart';
import 'app_manager_screen.dart';

/// Home/Dashboard Screen with storage indicator, breakdown chart,
/// and feature cards for various cleaning functions
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  StorageInfo _storageInfo = StorageInfo.empty();
  StorageBreakdown _storageBreakdown = StorageBreakdown.empty();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }
  
  Future<void> _loadStorageData() async {
    setState(() => _isLoading = true);
    
    // Check permissions first
    final hasPermission = await PermissionUtils.requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to analyze usage.')),
        );
      }
      return;
    }
    
    final storageInfo = await _storageService.getStorageInfo();
    final breakdown = await _storageService.getStorageBreakdown();
    
    if (mounted) {
      setState(() {
        _storageInfo = storageInfo;
        _storageBreakdown = breakdown;
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassmorphismBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadStorageData,
            color: AppTheme.neonGreenPrimary,
            backgroundColor: AppTheme.backgroundDark,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text('Smart Phone Cleaner'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Storage Indicator
                        if (_isLoading)
                          _buildLoadingIndicator()
                        else
                          _buildStorageSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Storage Breakdown Chart
                        if (!_isLoading)
                          _buildBreakdownSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Scan Button
                        _buildScanButton(),
                        
                        const SizedBox(height: 32),
                        
                        // Feature Cards Grid
                        Text(
                          'Quick Actions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureGrid(),
                        
                        const SizedBox(height: 24),
                        
                        // Native Ad Placeholder
                        const NativeAdWidget(height: 120),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.neonGreenPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'Analyzing storage...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStorageSection() {
    return GlassCard(
      isDark: true, // Use new dark mode for better contrast
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Storage Usage',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: StorageIndicator(
              usedBytes: _storageInfo.usedBytes,
              totalBytes: _storageInfo.totalBytes,
              size: 200,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBreakdownSection() {
    if (_storageBreakdown.totalBytes == 0) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Storage Breakdown',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GlassCard(
          isDark: true, // Consistent dark theme for charts
          padding: const EdgeInsets.all(20),
          child: Center(
            child: StorageBreakdownChart(
              breakdown: _storageBreakdown,
              size: 240, 
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          if (await PermissionUtils.requestStoragePermission()) {
            if (mounted) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanScreen()),
              );
              if (result == true) {
                _loadStorageData(); // Refresh if cleaned
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch_rounded, size: 28),
            const SizedBox(width: 12),
            Text(
              'Quick Boost',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.backgroundDark,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0, // Strict square ratio
      children: [
        FeatureCard(
          icon: Icons.delete_sweep_rounded,
          title: 'Junk Cleaner',
          subtitle: 'Clear cache & temp',
          onTap: () async {
            if (await PermissionUtils.requestStoragePermission()) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JunkCleanerScreen()),
                );
              }
            }
          },
        ),
        FeatureCard(
          icon: Icons.search_rounded,
          title: 'Deep Scan',
          subtitle: 'Find hidden bloat',
          iconColor: AppTheme.neonGreenPrimary,
          onTap: () async {
            if (await PermissionUtils.requestStoragePermission()) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                );
              }
            }
          },
        ),
        FeatureCard(
          icon: Icons.photo_library_rounded,
          title: 'Duplicates',
          subtitle: 'Find duplicate photos',
          onTap: () async {
            if (await PermissionUtils.requestStoragePermission()) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DuplicateFinderScreen()),
                );
              }
            }
          },
        ),
        FeatureCard(
          icon: Icons.folder_rounded,
          title: 'Large Files',
          subtitle: 'Manage big files',
          onTap: () async {
            if (await PermissionUtils.requestStoragePermission()) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LargeFilesScreen()),
                );
              }
            }
          },
        ),
        FeatureCard(
          icon: Icons.battery_charging_full_rounded,
          title: 'Battery Health',
          subtitle: 'Analyze battery life',
          iconColor: Colors.orangeAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BatterySaverScreen()),
            );
          },
        ),
        FeatureCard(
          icon: Icons.speed_rounded,
          title: 'RAM Boost',
          subtitle: 'Clean background apps',
          iconColor: Colors.blueAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RamBoostScreen()),
            );
          },
        ),
        FeatureCard(
          icon: Icons.chat_rounded,
          title: 'WhatsApp',
          subtitle: 'Clean WhatsApp media',
          iconColor: const Color(0xFF25D366),
          onTap: () async {
            if (await PermissionUtils.requestStoragePermission()) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WhatsAppCleanerScreen()),
                );
              }
            }
          },
        ),
        FeatureCard(
          icon: Icons.apps_rounded,
          title: 'App Manager',
          subtitle: 'Manage installed apps',
          iconColor: Colors.deepPurpleAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppManagerScreen()),
            );
          },
        ),
      ],
    );
  }
}
