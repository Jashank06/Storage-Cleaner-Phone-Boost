import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassmorphism_background.dart';
import '../widgets/confetti_overlay.dart';
import '../services/cleaner_service.dart';
import '../services/duplicate_service.dart';
import '../services/large_files_service.dart';
import '../services/whatsapp_cleaner_service.dart';
import '../services/deep_scan_service.dart';
import '../models/junk_file.dart';
import '../models/duplicate_group.dart';
import '../utils/format_utils.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  bool _isScanning = true;
  bool _isCleaning = false;
  bool _scanComplete = false;
  bool _isSuccess = false;
  bool _showConfetti = false;
  
  // Services
  final CleanerService _cleanerService = CleanerService();
  final DuplicateService _duplicateService = DuplicateService();
  final DeepScanService _deepScanService = DeepScanService();
  
  // Results
  int _junkSize = 0;
  int _duplicateSize = 0;
  int _deepJunkSize = 0;
  int _totalCleanable = 0;
  int _cleanedSize = 0;
  List<JunkFile> _junkFiles = [];
  List<JunkFile> _deepJunkFiles = [];
  
  // Animation
  late AnimationController _progressController;
  late AnimationController _beamController;
  VideoPlayerController? _videoController;
  bool _isFirstLoopCleared = false;
  final _videoReadyCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
      setState(() {});
    });

    _beamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initVideo();
    _startScan();
  }

  void _initVideo() {
    _videoController = VideoPlayerController.asset('assets/images/Robot_Video.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            // Set progress duration to match video duration for perfect sync
            _progressController.duration = _videoController!.value.duration;
          });
          _videoController?.setLooping(false);
          _videoController?.addListener(_videoListener);
          _videoController?.play();
          
          if (!_videoReadyCompleter.isCompleted) {
            _videoReadyCompleter.complete();
          }
        }
      }).catchError((e) {
        print('DEBUG: Video Initialization Error: $e');
        if (!_videoReadyCompleter.isCompleted) {
          _videoReadyCompleter.complete();
        }
      });
  }

  void _videoListener() {
    if (_videoController == null || !mounted) return;
    
    // Detect when the first play finishes
    if (!_isFirstLoopCleared && 
        _videoController!.value.position >= _videoController!.value.duration - const Duration(milliseconds: 200)) {
      print('DEBUG: First video loop finished. Muting and looping.');
      _isFirstLoopCleared = true;
      _videoController!.setVolume(0); // Mute for all future loops
      _videoController!.setLooping(true); // Enable looping now
      _videoController!.play(); // Keep it playing
    }
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _beamController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    print('DEBUG: Waiting for Video initialization...');
    // Ensure we wait for video to be ready before counting it towards scan duration
    await _videoReadyCompleter.future;
    
    print('DEBUG: Starting Scan Tasks and Animation...');
    _progressController.reset();
    
    // Performed in parallel for speed
    // We wait for BOTH the scan results AND the progress animation to reach 100%
    final results = await Future.wait<dynamic>([
      _cleanerService.scanJunkFiles(),
      _duplicateService.scanDuplicatePhotos(),
      _deepScanService.scanDeepJunk(),
      _progressController.forward(), // Wait for animation to reach 100%
    ]);
    
    print('DEBUG: Scan Tasks and Animation Complete. Results: ${results.length}');
    
    final junk = results[0] as List<JunkFile>;
    final duplicates = (results[1] as List).cast<DuplicateGroup>();
    final deepJunk = results[2] as List<JunkFile>;
    
    int dupSize = 0;
    for (var group in duplicates) {
       if (group.filePaths.length > 1) {
         dupSize += (group.totalSize - (group.totalSize / group.filePaths.length)).round();
       }
    }
    
    if (mounted) {
      print('DEBUG: Transitioning to results...');
      setState(() {
        _junkFiles = junk;
        _deepJunkFiles = deepJunk;
        _junkSize = _cleanerService.getTotalSize(junk);
        _deepJunkSize = _cleanerService.getTotalSize(deepJunk);
        _duplicateSize = dupSize;
        _totalCleanable = _junkSize + _duplicateSize + _deepJunkSize;
        _scanComplete = true;
        _isScanning = false;
      });
      // Optionally stop video or let it loop muted in background if needed
      // _videoController?.pause(); 
    }
  }

  Future<void> _cleanAll() async {
    setState(() => _isCleaning = true);
    
    // Clean Junk + Deep Junk
    int deleted = await _cleanerService.deleteJunkFiles([..._junkFiles, ..._deepJunkFiles]);
    
    if (mounted) {
      setState(() {
        _cleanedSize = deleted;
        _isCleaning = false;
        _isSuccess = true;
        _showConfetti = true;
      });
      
      // Auto-hide confetti after 3 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showConfetti = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConfettiOverlay(
        isPlaying: _showConfetti,
        child: Stack(
          children: [
            // 1. Full Screen Video Background
            if (_isScanning && _videoController != null && _videoController!.value.isInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ),
            
            // 2. Main Background Layer (Only visible when not scanning)
            if (!_isScanning)
              const GlassmorphismBackground(child: SizedBox.expand()),
            
            // 3. Dark Overlay to ensure readability during scan
            if (_isScanning)
              Container(color: Colors.black.withOpacity(0.3)),

            // 4. Content Layer
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  const Spacer(),
                  if (_isSuccess)
                    _buildSuccessUI()
                  else if (_isScanning)
                    _buildScanningAnimation()
                  else
                    _buildResults(),
                  const Spacer(),
                  if (_scanComplete && !_isSuccess)
                    _buildCleanButton()
                  else if (_isSuccess)
                    _buildDoneButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessUI() {
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonGreenPrimary.withOpacity(0.1),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Lottie.asset(
            'assets/lottie/success_check.json',
            repeat: false,
          ),
        ),
        const SizedBox(height: 48),
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.neonGreenGradient.createShader(bounds),
          child: const Text(
            'SYSTEM BOOSTED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, color: AppTheme.neonGreenPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recovered ${FormatUtils.formatBytes(_cleanedSize)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            foregroundColor: Colors.white,
            side: BorderSide(color: AppTheme.neonGreenPrimary.withOpacity(0.5)),
          ),
          child: const Text('DONE'),
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
            'System Scan',
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

  Widget _buildScanningAnimation() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large Glowing Percentage
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow
              Text(
                '${(_progressController.value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 110,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.2),
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 50,
                    ),
                    const Shadow(
                      color: AppTheme.neonGreenPrimary,
                      blurRadius: 80,
                    ),
                  ],
                ),
              ),
              // Main Text
              Text(
                '${(_progressController.value * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 110,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // High-Tech Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.neonGreenPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppTheme.neonGreenPrimary.withOpacity(0.5), width: 1.5),
            ),
            child: const Text(
              'NEURAL CORE SCANNING',
              style: TextStyle(
                color: AppTheme.neonGreenPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Analyzing Data Patterns...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.neonGreenPrimary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppTheme.neonGreenPrimary.withOpacity(0.4)),
          ),
          child: const Text(
            'INTELLIGENCE REPORT READY',
            style: TextStyle(
              color: AppTheme.neonGreenPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 36),
        Text(
          FormatUtils.formatBytes(_totalCleanable),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 76,
            fontWeight: FontWeight.w900,
            letterSpacing: -3,
            height: 1,
            shadows: [
              Shadow(
                color: AppTheme.neonGreenPrimary,
                blurRadius: 40,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'FOUND POTENTIAL OPTIMIZATION',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                _buildResultRow('System Redundant Files', _junkSize),
                const Divider(color: Colors.white10, height: 32),
                _buildResultRow('Deep Cache Repositories', _deepJunkSize),
                const Divider(color: Colors.white10, height: 32),
                _buildResultRow('Redundant Media Files', _duplicateSize),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String title, int size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(
            FormatUtils.formatBytes(size),
            style: const TextStyle(color: AppTheme.neonGreenPrimary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isCleaning ? null : _cleanAll,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.neonGreenPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isCleaning
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black))
              : const Text(
                  'CLEAN NOW',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
        ),
      ),
    );
  }
}
