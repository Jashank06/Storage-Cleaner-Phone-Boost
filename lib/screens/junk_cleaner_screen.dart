import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassmorphism_background.dart';
import '../services/cleaner_service.dart';
import '../models/junk_file.dart';
import '../utils/format_utils.dart';

class JunkCleanerScreen extends StatefulWidget {
  const JunkCleanerScreen({super.key});

  @override
  State<JunkCleanerScreen> createState() => _JunkCleanerScreenState();
}

class _JunkCleanerScreenState extends State<JunkCleanerScreen> {
  final CleanerService _cleanerService = CleanerService();
  bool _isScanning = true;
  bool _isCleaning = false;
  List<JunkFile> _junkFiles = [];
  Map<JunkCategory, int> _categorySizes = {};
  int _totalSize = 0;

  @override
  void initState() {
    super.initState();
    _scanJunk();
  }

  Future<void> _scanJunk() async {
    setState(() => _isScanning = true);
    final files = await _cleanerService.scanJunkFiles();
    
    // Calculate sizes per category
    final Map<JunkCategory, int> sizes = {};
    for (var file in files) {
      sizes[file.category] = (sizes[file.category] ?? 0) + file.size;
    }

    if (mounted) {
      setState(() {
        _junkFiles = files;
        _categorySizes = sizes;
        _totalSize = files.fold(0, (sum, file) => sum + file.size);
        _isScanning = false;
      });
    }
  }

  Future<void> _cleanJunk() async {
    setState(() => _isCleaning = true);
    final deleted = await _cleanerService.deleteJunkFiles(_junkFiles.where((f) => f.isSelected).toList());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleaned ${FormatUtils.formatBytes(deleted)}'),
          backgroundColor: AppTheme.neonGreenPrimary,
        ),
      );
      
      // Rescan after cleaning
      _scanJunk();
      setState(() => _isCleaning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassmorphismBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isScanning 
                    ? _buildScanningView()
                    : _junkFiles.isEmpty 
                        ? _buildEmptyView()
                        : _buildResultsView(),
              ),
              if (!_isScanning && _junkFiles.isNotEmpty)
                _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Junk Cleaner',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.neonGreenPrimary),
          const SizedBox(height: 20),
          Text(
            'Scanning for junk files...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: AppTheme.neonGreenPrimary),
          const SizedBox(height: 16),
          Text(
            'No junk files found!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Your system is clean.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Size Header
        Center(
          child: Column(
            children: [
              Text(
                FormatUtils.formatBytes(_totalSize),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: AppTheme.neonGreenPrimary,
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              Text(
                'Total Junk Found',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Categories
        ...JunkCategory.values.map((category) {
          final size = _categorySizes[category] ?? 0;
          if (size == 0) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _getCategoryIcon(category),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCategoryName(category),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          FormatUtils.formatBytes(size),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: true, // Simplified: All selected by default for now
                    onChanged: (val) {},
                    activeColor: AppTheme.neonGreenPrimary,
                    checkColor: Colors.black,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isCleaning ? null : _cleanJunk,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGreenPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isCleaning 
              ? const SizedBox(
                  width: 24, 
                  height: 24, 
                  child: CircularProgressIndicator(color: Colors.black)
                )
              : Text(
                  'CLEAN ${FormatUtils.formatBytes(_totalSize)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Icon _getCategoryIcon(JunkCategory category) {
    IconData icon;
    Color color;
    
    switch (category) {
      case JunkCategory.cache:
        icon = Icons.cached;
        color = Colors.orangeAccent;
        break;
      case JunkCategory.temp:
        icon = Icons.folder_open;
        color = Colors.blueAccent;
        break;
      case JunkCategory.apk:
        icon = Icons.android;
        color = Colors.greenAccent;
        break;
      case JunkCategory.log:
        icon = Icons.article;
        color = Colors.grey;
        break;
      case JunkCategory.emptyFolders:
        icon = Icons.folder_outlined;
        color = Colors.white70;
        break;
    }
    
    return Icon(icon, color: color, size: 28);
  }

  String _getCategoryName(JunkCategory category) {
    switch (category) {
      case JunkCategory.cache: return 'App Cache';
      case JunkCategory.temp: return 'Temporary Files';
      case JunkCategory.apk: return 'Obsolete APKs';
      case JunkCategory.log: return 'System Logs';
      case JunkCategory.emptyFolders: return 'Empty Folders';
    }
  }
}
