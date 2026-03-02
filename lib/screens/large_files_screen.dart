import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glassmorphism_background.dart';
import '../services/large_files_service.dart';
import '../models/large_file.dart';
import '../utils/format_utils.dart';
import '../widgets/glass_card.dart';
import '../widgets/file_preview_icon.dart';

class LargeFilesScreen extends StatefulWidget {
  const LargeFilesScreen({super.key});

  @override
  State<LargeFilesScreen> createState() => _LargeFilesScreenState();
}

class _LargeFilesScreenState extends State<LargeFilesScreen> {
  final LargeFilesService _largeFilesService = LargeFilesService();
  bool _isScanning = true;
  bool _isCleaning = false;
  List<LargeFile> _largeFiles = [];
  int _selectedSize = 0;

  @override
  void initState() {
    super.initState();
    _scanFiles();
  }

  Future<void> _scanFiles() async {
    setState(() => _isScanning = true);
    final files = await _largeFilesService.scanLargeFiles();
    
    if (mounted) {
      setState(() {
        _largeFiles = files;
        _recalculateSelectedSize();
        _isScanning = false;
      });
    }
  }

  void _recalculateSelectedSize() {
    _selectedSize = _largeFiles
        .where((f) => f.isSelected)
        .fold(0, (sum, f) => sum + f.size);
  }

  Future<void> _deleteFiles() async {
    setState(() => _isCleaning = true);
    final deleted = await _largeFilesService.deleteLargeFiles(_largeFiles);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${FormatUtils.formatBytes(deleted)}'),
          backgroundColor: AppTheme.neonGreenPrimary,
        ),
      );
      
      _scanFiles();
      setState(() => _isCleaning = false);
    }
  }

  void _toggleSelection(LargeFile file) {
    setState(() {
      file.isSelected = !file.isSelected;
      _recalculateSelectedSize();
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
              Expanded(
                child: _isScanning 
                    ? _buildScanningView()
                    : _largeFiles.isEmpty 
                        ? _buildEmptyView()
                        : _buildResultsView(),
              ),
              if (!_isScanning && _largeFiles.isNotEmpty)
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Large Files',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_isScanning && _largeFiles.isNotEmpty)
                Text(
                  '${_largeFiles.length} files > 100MB',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
            ],
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
            'Scanning for large files...',
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
          const Icon(Icons.folder_open, size: 80, color: AppTheme.neonGreenPrimary),
          const SizedBox(height: 16),
          Text(
            'No large files found!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Your storage is efficient.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _largeFiles.length,
      itemBuilder: (context, index) {
        final file = _largeFiles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: SizedBox(
                width: 48, 
                height: 48,
                child: FilePreviewIcon(
                  path: file.path,
                  iconSize: 24,
                ),
              ),
              title: Text(
                file.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${FormatUtils.formatBytes(file.size)} • ${file.fileType}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  Text(
                    file.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                ],
              ),
              trailing: Checkbox(
                value: file.isSelected,
                onChanged: (val) => _toggleSelection(file),
                activeColor: AppTheme.neonGreenPrimary,
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white54, width: 2),
              ),
              onTap: () => _toggleSelection(file),
            ),
          ),
        );
      },
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
            onPressed: (_isCleaning || _selectedSize == 0) ? null : _deleteFiles,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGreenPrimary,
              disabledBackgroundColor: Colors.grey[800],
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
                  'DELETE SELECTED (${FormatUtils.formatBytes(_selectedSize)})',
                  style: TextStyle(
                    color: _selectedSize == 0 ? Colors.white38 : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
