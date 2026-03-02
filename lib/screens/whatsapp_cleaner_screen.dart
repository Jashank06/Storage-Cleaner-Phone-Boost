import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glassmorphism_background.dart';
import '../services/whatsapp_cleaner_service.dart';
import '../utils/format_utils.dart';
import '../widgets/file_preview_icon.dart';

class WhatsAppCleanerScreen extends StatefulWidget {
  const WhatsAppCleanerScreen({super.key});

  @override
  State<WhatsAppCleanerScreen> createState() => _WhatsAppCleanerScreenState();
}

class _WhatsAppCleanerScreenState extends State<WhatsAppCleanerScreen> with SingleTickerProviderStateMixin {
  final WhatsAppCleanerService _whatsAppService = WhatsAppCleanerService();
  bool _isScanning = true;
  bool _isCleaning = false;
  List<WhatsAppMedia> _allMedia = [];
  late TabController _tabController;
  
  final List<String> _tabs = ['Images', 'Videos', 'Voice', 'Docs', 'Status'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scanWhatsApp();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _scanWhatsApp() async {
    setState(() => _isScanning = true);
    final media = await _whatsAppService.scanWhatsAppMedia();
    
    if (mounted) {
      setState(() {
        _allMedia = media;
        _isScanning = false;
      });
    }
  }

  List<WhatsAppMedia> _getMediaByCategory(String tab) {
    switch (tab) {
      case 'Images': return _allMedia.where((m) => m.category == 'Images').toList();
      case 'Videos': return _allMedia.where((m) => m.category.contains('Videos')).toList();
      case 'Voice': return _allMedia.where((m) => m.category.contains('Voice')).toList();
      case 'Docs': return _allMedia.where((m) => m.category.contains('Documents')).toList();
      case 'Status': return _allMedia.where((m) => m.category == 'Status').toList();
      default: return [];
    }
  }

  int _getSelectedSize() {
    return _allMedia.where((m) => m.isSelected).fold(0, (sum, m) => sum + m.size);
  }

  Future<void> _deleteSelected() async {
    setState(() => _isCleaning = true);
    final toDelete = _allMedia.where((m) => m.isSelected).toList();
    final deleted = await _whatsAppService.deleteWhatsAppMedia(toDelete);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleaned ${FormatUtils.formatBytes(deleted)}'),
          backgroundColor: AppTheme.neonGreenPrimary,
        ),
      );
      
      _scanWhatsApp(); // Rescan
      setState(() => _isCleaning = false);
    }
  }

  void _toggleSelection(WhatsAppMedia media) {
    setState(() {
      media.isSelected = !media.isSelected;
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
              _buildTabBar(),
              Expanded(
                child: _isScanning 
                    ? _buildScanningView()
                    : TabBarView(
                        controller: _tabController,
                        children: _tabs.map((tab) => _buildMediaList(tab)).toList(),
                      ),
              ),
              if (!_isScanning && _allMedia.isNotEmpty)
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
          const Text(
            'WhatsApp Cleaner',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: AppTheme.neonGreenPrimary,
      labelColor: AppTheme.neonGreenPrimary,
      unselectedLabelColor: Colors.white70,
      tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
    );
  }

  Widget _buildScanningView() {
    return const Center(child: CircularProgressIndicator(color: AppTheme.neonGreenPrimary));
  }
  
  Widget _buildMediaList(String tab) {
    final mediaList = _getMediaByCategory(tab);
    
    if (mediaList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.perm_media_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'No media found', 
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        final media = mediaList[index];
        return GestureDetector(
          onTap: () => _toggleSelection(media),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FilePreviewIcon(
                  path: media.path,
                  size: media.size,
                ),
              ),
              if (media.isSelected)
                Container(
                  color: AppTheme.neonGreenPrimary.withOpacity(0.4),
                  child: const Center(
                    child: Icon(Icons.check_circle, color: AppTheme.neonGreenPrimary, size: 32),
                  ),
                ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    FormatUtils.formatBytes(media.size),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final selectedSize = _getSelectedSize();
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
            onPressed: (_isCleaning || selectedSize == 0) ? null : _deleteSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGreenPrimary,
              disabledBackgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isCleaning 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black))
              : Text(
                  'DELETE SELECTED (${FormatUtils.formatBytes(selectedSize)})',
                  style: TextStyle(
                    color: selectedSize == 0 ? Colors.white38 : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
