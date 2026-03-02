import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glassmorphism_background.dart';
import '../services/duplicate_service.dart';
import '../models/duplicate_group.dart';
import '../utils/format_utils.dart';
import '../widgets/glass_card.dart';
import '../widgets/file_preview_icon.dart';

class DuplicateFinderScreen extends StatefulWidget {
  const DuplicateFinderScreen({super.key});

  @override
  State<DuplicateFinderScreen> createState() => _DuplicateFinderScreenState();
}

class _DuplicateFinderScreenState extends State<DuplicateFinderScreen> {
  final DuplicateService _duplicateService = DuplicateService();
  bool _isScanning = true;
  bool _isCleaning = false;
  List<DuplicateGroup> _duplicateGroups = [];
  int _totalRecoverableSize = 0;

  @override
  void initState() {
    super.initState();
    _scanDuplicates();
  }

  Future<void> _scanDuplicates() async {
    setState(() => _isScanning = true);
    final groups = await _duplicateService.scanDuplicatePhotos();
    
    // Auto-select all but one (the first one) in each group
    for (var group in groups) {
      if (group.filePaths.length > 1) {
        // Clear default selection
        group.selectedFiles.clear();
        // Select all except the first one (keep one copy)
        for (int i = 1; i < group.filePaths.length; i++) {
          group.selectedFiles.add(group.filePaths[i]);
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _duplicateGroups = groups;
        _recalculateTotalSize();
        _isScanning = false;
      });
    }
  }

  void _recalculateTotalSize() {
    int total = 0;
    for (var group in _duplicateGroups) {
      for (var path in group.selectedFiles) {
        try {
          // Estimate size based on group average or re-fetch if precise needed
          // For now, simpler approximation:
           total += (group.totalSize / group.filePaths.length).round(); 
        } catch (e) {
          // ignore
        }
      }
    }
    _totalRecoverableSize = total;
  }

  Future<void> _cleanDuplicates() async {
    setState(() => _isCleaning = true);
    final deleted = await _duplicateService.deleteDuplicates(_duplicateGroups);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recovered ${FormatUtils.formatBytes(deleted)}'),
          backgroundColor: AppTheme.neonGreenPrimary,
        ),
      );
      
      // Rescan after cleaning
      _scanDuplicates();
      setState(() => _isCleaning = false);
    }
  }
  
  void _toggleFileSelection(DuplicateGroup group, String path) {
    setState(() {
      if (group.selectedFiles.contains(path)) {
        group.selectedFiles.remove(path);
      } else {
        group.selectedFiles.add(path);
      }
      _recalculateTotalSize();
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
                    : _duplicateGroups.isEmpty 
                        ? _buildEmptyView()
                        : _buildResultsView(),
              ),
              if (!_isScanning && _duplicateGroups.isNotEmpty)
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
                'Duplicate Finder',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_isScanning && _duplicateGroups.isNotEmpty)
                Text(
                  '${_duplicateGroups.length} sets found',
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
            'Scanning for duplicates...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
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
          const Icon(Icons.library_add_check_rounded, size: 80, color: AppTheme.neonGreenPrimary),
          const SizedBox(height: 16),
          Text(
            'No duplicates found!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Your gallery is optimized.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _duplicateGroups.length,
      itemBuilder: (context, index) {
        final group = _duplicateGroups[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Set ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      FormatUtils.formatBytes(group.totalSize),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: group.filePaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, fileIndex) {
                    final path = group.filePaths[fileIndex];
                    final isSelected = group.selectedFiles.contains(path);
                    
                    return GestureDetector(
                      onTap: () => _toggleFileSelection(group, path),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: FilePreviewIcon(
                                path: path,
                                iconSize: 40,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppTheme.neonGreenPrimary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.neonGreenPrimary, width: 2),
                              ),
                              child: const Center(
                                child: Icon(Icons.check_circle, color: AppTheme.neonGreenPrimary, size: 32),
                              ),
                            )
                          else
                             // Add a label for "Keep" if this is the only unselected one? 
                             // Logic handles selection manually.
                             const SizedBox.shrink(),
                             
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FutureBuilder<int>(
                                future: File(path).length(),
                                builder: (context, snapshot) {
                                  return Text(
                                    FormatUtils.formatBytes(snapshot.data ?? 0),
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
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
            onPressed: (_isCleaning || _totalRecoverableSize == 0) ? null : _cleanDuplicates,
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
                  'DELETE SELECTED (${FormatUtils.formatBytes(_totalRecoverableSize)})',
                  style: TextStyle(
                    color: _totalRecoverableSize == 0 ? Colors.white38 : Colors.black,
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
