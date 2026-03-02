import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassmorphism_background.dart';
import '../services/app_manager_service.dart';
import '../models/app_info.dart';
import '../utils/format_utils.dart';
import '../utils/permission_utils.dart';

class AppManagerScreen extends StatefulWidget {
  const AppManagerScreen({super.key});

  @override
  State<AppManagerScreen> createState() => _AppManagerScreenState();
}

class _AppManagerScreenState extends State<AppManagerScreen> {
  final AppManagerService _appService = AppManagerService();
  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  String _sortBy = 'Size';

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() => _isLoading = true);
    
    // Check for Usage Stats permission (required for sizes)
    final hasUsagePermission = await _appService.checkUsageStatsPermission();
    if (!hasUsagePermission && mounted) {
      _showUsagePermissionDialog();
    }

    final apps = await _appService.getInstalledApps();
    if (mounted) {
      setState(() {
        _apps = apps;
        _sortApps();
        _isLoading = false;
      });
    }
  }

  void _sortApps() {
    setState(() {
      if (_sortBy == 'Size') {
        _apps.sort((a, b) => b.size.compareTo(a.size));
      } else if (_sortBy == 'Name') {
        _apps.sort((a, b) => a.appName.compareTo(b.appName));
      } else if (_sortBy == 'Cache') {
        _apps.sort((a, b) => b.cacheSize.compareTo(a.cacheSize));
      }
      _filteredApps = List.from(_apps);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassmorphismBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSortToolbar(),
              Expanded(
                child: _isLoading ? _buildLoading() : _buildAppList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'App Manager',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadApps,
          ),
        ],
      ),
    );
  }

  Widget _buildSortToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          _buildSortChip('Size'),
          const SizedBox(width: 8),
          _buildSortChip('Cache'),
          const SizedBox(width: 8),
          _buildSortChip('Name'),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label) {
    final isSelected = _sortBy == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortBy = label;
            _sortApps();
          });
        }
      },
      selectedColor: AppTheme.neonGreenPrimary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
      ),
      backgroundColor: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.neonGreenPrimary),
    );
  }

  Widget _buildAppList() {
    if (_filteredApps.isEmpty) {
      return const Center(child: Text('No apps found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredApps.length,
      itemBuilder: (context, index) {
        final app = _filteredApps[index];
        return _buildAppItem(app);
      },
    );
  }

  Widget _buildAppItem(AppInfo app) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        isDark: true,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: app.icon != null
                  ? Image.memory(app.icon!, fit: BoxFit.contain)
                  : const Icon(Icons.android_rounded, color: AppTheme.neonGreenPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        FormatUtils.formatBytes(app.size),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      if (app.cacheSize > 0)
                        Text(
                          'Cache: ${FormatUtils.formatBytes(app.cacheSize)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.neonGreenPrimary.withOpacity(0.7),
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () => _confirmUninstall(app),
            ),
          ],
        ),
      ),
    );
  }

  void _showUsagePermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Usage Access Required'),
        content: const Text(
          'To accurately calculate app sizes and cache, the app needs "Usage Access" permission.\n\n'
          'Please find "Smart Phone Cleaner" in the next screen and enable "Allow usage tracking".',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _appService.openUsageStatsSettings();
            },
            child: const Text('Enable Now'),
          ),
        ],
      ),
    );
  }

  void _confirmUninstall(AppInfo app) {
    if (app.isSystemApp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System apps cannot be uninstalled directly.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Uninstall App'),
        content: Text('Do you want to uninstall ${app.appName}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _appService.uninstallApp(app.packageName);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );
  }
}
