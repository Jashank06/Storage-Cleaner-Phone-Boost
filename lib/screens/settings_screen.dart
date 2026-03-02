import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../widgets/glass_card.dart';

/// Settings and About Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info Section
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.neonGreenPrimary,
                        AppTheme.neonGreenSecondary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.greenGlow,
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cleaning_services_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Keep your phone clean and optimized',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGrey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Actions
          _buildSettingsTile(
            context,
            icon: Icons.policy_outlined,
            title: 'Privacy Policy',
            onTap: () => _openPrivacyPolicy(),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsTile(
            context,
            icon: Icons.star_outline_rounded,
            title: 'Rate App',
            onTap: () => _rateApp(),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsTile(
            context,
            icon: Icons.share_outlined,
            title: 'Share App',
            onTap: () => _shareApp(),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsTile(
            context,
            icon: Icons.block_outlined,
            title: 'Remove Ads',
            subtitle: 'Coming Soon',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ad removal will be available soon via in-app purchase'),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // About
          Center(
            child: Text(
              'Made with ❤️ for your phone',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.neonGreenPrimary),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textGrey,
        ),
      ),
    );
  }
  
  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  
  Future<void> _rateApp() async {
    final uri = Uri.parse(AppConstants.playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  
  Future<void> _shareApp() async {
    await Share.share(
      'Check out Smart Phone Cleaner - the best storage management app! ${AppConstants.playStoreUrl}',
      subject: 'Smart Phone Cleaner',
    );
  }
}
