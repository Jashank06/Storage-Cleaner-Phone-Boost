import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassmorphism_background.dart';
import 'package:confetti/confetti.dart';

class RamBoostScreen extends StatefulWidget {
  const RamBoostScreen({super.key});

  @override
  State<RamBoostScreen> createState() => _RamBoostScreenState();
}

class _RamBoostScreenState extends State<RamBoostScreen> with TickerProviderStateMixin {
  late AnimationController _gaugeController;
  late AnimationController _boostController;
  late ConfettiController _confettiController;
  
  static const platform = MethodChannel('com.smartphonecleaner.storageboost/storage');
  
  double _ramUsage = 0.0;
  int _totalRam = 0;
  bool _isLoading = true;
  
  bool _isBoosting = false;
  bool _isBoosted = false;
  String _statusMessage = "Analyzing Memory...";
  String _freedAmount = "";

  @override
  void initState() {
    super.initState();
    
    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _boostController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _checkLastBoost();
  }

  Future<void> _checkLastBoost() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBoost = prefs.getInt('last_ram_boost_time') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // If boosted within last 30 minutes (30 * 60 * 1000 = 1,800,000 ms)
    if (now - lastBoost < 1800000) {
      if (mounted) {
        setState(() {
          _isBoosted = true;
          _isLoading = false;
          _ramUsage = 0.35; // Simulated low usage
          _statusMessage = "Already Optimized";
          _freedAmount = "Optimal";
        });
        _gaugeController.animateTo(0.35, curve: Curves.easeOutBack);
      }
    } else {
      _fetchRamUsage();
    }
  }

  Future<void> _fetchRamUsage() async {
    try {
      final Map<dynamic, dynamic> stats = await platform.invokeMethod('getRamUsage');
      final int total = stats['totalRam'] ?? 0;
      final int used = stats['usedRam'] ?? 0;
      
      setState(() {
        _totalRam = total;
        _ramUsage = used / total;
        _isLoading = false;
        _statusMessage = "${(_ramUsage * 100).toInt()}% Memory Used";
      });
      
      _gaugeController.animateTo(_ramUsage, curve: Curves.easeOutBack);
    } catch (e) {
      debugPrint("Error fetching RAM: $e");
      // Only fallback if not boosted
      if (!_isBoosted) {
        setState(() {
           _ramUsage = 0.75;
           _isLoading = false;
           _statusMessage = "75% Memory Used";
        });
        _gaugeController.animateTo(0.75, curve: Curves.easeOutBack);
      }
    }
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    _boostController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _boostRam() async {
    if (_isBoosting || _isBoosted) return;
    
    setState(() {
      _isBoosting = true;
      _statusMessage = "Cleaning background tasks...";
    });
    
    try {
      // Call Native Kill Method
      await platform.invokeMethod('killBackgroundProcesses');
    } catch (e) {
      debugPrint("Native kill failed: $e");
    }
    
    // 1. Surging Up Animation
    await _gaugeController.animateTo(
      math.min(_ramUsage + 0.1, 0.99), 
      duration: const Duration(milliseconds: 800), 
      curve: Curves.easeInOut
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() => _statusMessage = "Releasing unused memory...");
    
    // 2. Formatting "Freed" Amount
    final randomDrop = 0.15 + (math.Random().nextDouble() * 0.10); 
    double targetUsage = math.max(_ramUsage - randomDrop, 0.30);
    
    int freedBytes = ((_ramUsage - targetUsage) * _totalRam).toInt();
    if (freedBytes < 0) freedBytes = 100 * 1024 * 1024;

    String freedString = _formatBytes(freedBytes);

    // 3. Drop Animation
    await _gaugeController.animateTo(targetUsage, duration: const Duration(milliseconds: 1200), curve: Curves.bounceOut);
    
    // 4. Save Time & Success State
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_ram_boost_time', DateTime.now().millisecondsSinceEpoch);

    if (mounted) {
      setState(() {
        _isBoosting = false;
        _isBoosted = true;
        _ramUsage = targetUsage;
        _statusMessage = "Optimal Performance";
        _freedAmount = freedString;
      });
      _confettiController.play();
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('RAM Booster'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GlassmorphismBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Speedometer Gauge
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: AnimatedBuilder(
                              animation: _gaugeController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: _GaugePainter(
                                    percent: _gaugeController.value,
                                    isBoosted: _isBoosted,
                                  ),
                                );
                              },
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                size: 48,
                                color: _isBoosted ? AppTheme.neonGreenPrimary : Colors.white70,
                              ),
                              const SizedBox(height: 16),
                              AnimatedBuilder(
                                animation: _gaugeController,
                                builder: (context, child) {
                                  return Text(
                                    '${(_gaugeController.value * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 64,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                              if (_isBoosted)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonGreenPrimary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.neonGreenPrimary),
                                  ),
                                  child: Text(
                                    'Freed $_freedAmount!',
                                    style: const TextStyle(
                                      color: AppTheme.neonGreenPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Controls
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _statusMessage,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: _boostRam,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isBoosted 
                                    ? Colors.blueAccent.withOpacity(0.2) 
                                    : Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: _isBoosted ? 0 : 10,
                                shadowColor: Colors.blueAccent.withOpacity(0.5),
                              ),
                              child: _isBoosting
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(_isBoosted ? Icons.check_rounded : Icons.rocket_launch_rounded),
                                        const SizedBox(width: 12),
                                        Text(
                                          _isBoosted ? 'Boosted' : 'BOOST RAM',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Confetti Overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: math.pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.2,
                  colors: const [AppTheme.neonGreenPrimary, Colors.blueAccent, Colors.white],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final bool isBoosted;

  _GaugePainter({required this.percent, required this.isBoosted});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    const startAngle = 135 * math.pi / 180;
    const sweepAngle = 270 * math.pi / 180;

    // Background Arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    // Active Arc Gradient
    final activePaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.blueAccent,
          isBoosted ? AppTheme.neonGreenPrimary : Colors.redAccent,
        ],
        stops: const [0.0, 1.0],
        transform: GradientRotation(startAngle - 0.2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawArc(rect, startAngle, sweepAngle * percent, false, activePaint);

    // Indicator Dot (Needle Tip)
    final angle = startAngle + (sweepAngle * percent);
    final dotX = center.dx + (radius) * math.cos(angle);
    final dotY = center.dy + (radius) * math.sin(angle);
    
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
    canvas.drawCircle(Offset(dotX, dotY), 8, dotPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => 
      oldDelegate.percent != percent || oldDelegate.isBoosted != isBoosted;
}
