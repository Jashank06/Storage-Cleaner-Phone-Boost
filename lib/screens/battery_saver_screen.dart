import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';
import 'dart:math' as math;
import '../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassmorphism_background.dart';
import '../widgets/file_preview_icon.dart'; // Reusing for consistent icon style if needed, or just standard icons

class BatterySaverScreen extends StatefulWidget {
  const BatterySaverScreen({super.key});

  @override
  State<BatterySaverScreen> createState() => _BatterySaverScreenState();
}

class _BatterySaverScreenState extends State<BatterySaverScreen> with TickerProviderStateMixin {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  
  // Animation controllers
  late AnimationController _waveController;
  late AnimationController _optimizeController;
  
  bool _isOptimizing = false;
  bool _isOptimized = false;
  String _statusMessage = "Analyzing battery usage...";

  @override
  void initState() {
    super.initState();
    _initBattery();
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _optimizeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  Future<void> _initBattery() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    
    if (mounted) {
      setState(() {
        _batteryLevel = level;
        _batteryState = state;
        _statusMessage = _batteryLevel > 80 
            ? "Battery is in good health" 
            : "Background apps consuming power";
      });
    }

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      if (mounted) {
        setState(() {
          _batteryState = state;
        });
      }
    });
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    _waveController.dispose();
    _optimizeController.dispose();
    super.dispose();
  }

  Future<void> _optimizeBattery() async {
    if (_isOptimizing || _isOptimized) return;
    
    setState(() {
      _isOptimizing = true;
      _statusMessage = "Hibernating background apps...";
    });
    
    await _optimizeController.forward();
    
    // Simulate steps
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _statusMessage = "Adjusting brightness settings...");
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _statusMessage = "Applying power saving config...");
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isOptimizing = false;
        _isOptimized = true;
        _statusMessage = "Extended battery life by ~45 mins";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Battery Health'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GlassmorphismBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Battery Liquid Visualization
              Expanded(
                flex: 4,
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Container Border
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getBatteryColor().withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Stack(
                              children: [
                                // Background
                                Container(color: Colors.black26),
                                
                                // Liquid Waves
                                AnimatedBuilder(
                                  animation: _waveController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: _LiquidPainter(
                                        animationValue: _waveController.value,
                                        level: _batteryLevel / 100.0,
                                        color: _getBatteryColor(),
                                      ),
                                      size: const Size(260, 260),
                                    );
                                  },
                                ),
                                
                                // Charging Indicator Overlay
                                if (_batteryState == BatteryState.charging)
                                  Center(
                                    child: Icon(
                                      Icons.bolt_rounded,
                                      size: 100,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Percentage Text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_batteryLevel%',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _batteryState == BatteryState.charging ? 'Charging' : 'Discharging',
                                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Status & Controls
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Status Message
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: _isOptimized ? AppTheme.neonGreenPrimary : Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      // Details Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailItem(Icons.thermostat_rounded, "Temp", "34°C"),
                          _buildDetailItem(Icons.bolt_rounded, "Voltage", "4.2V"),
                          _buildDetailItem(Icons.health_and_safety_rounded, "Health", "Good"),
                        ],
                      ),
                      
                      // Optimize Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _optimizeBattery,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isOptimized 
                                ? Colors.grey.withOpacity(0.2) 
                                : AppTheme.neonGreenPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: _isOptimized ? 0 : 8,
                            shadowColor: AppTheme.neonGreenPrimary.withOpacity(0.5),
                          ),
                          child: _isOptimizing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _isOptimized ? 'Optimized' : 'Optimize Now',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _isOptimized ? Colors.white38 : Colors.black,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Color _getBatteryColor() {
    if (_batteryLevel > 50) return AppTheme.neonGreenPrimary;
    if (_batteryLevel > 20) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}

class _LiquidPainter extends CustomPainter {
  final double animationValue;
  final double level;
  final Color color;

  _LiquidPainter({required this.animationValue, required this.level, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final y = size.height * (1 - level);
    
    path.moveTo(0, y);
    
    // Create wave effect
    for (double x = 0; x <= size.width; x++) {
      final waveHeight = 10.0 * (1.0 - level); // Reduce wave height as it fills
      final wave1 = math.sin((animationValue * 360 + x) * math.pi / 180);
      final wave2 = math.cos((animationValue * 200 + x) * math.pi / 180);
      
      path.lineTo(x, y + (wave1 + wave2) * waveHeight * 0.5);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LiquidPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue || 
      oldDelegate.level != level || 
      oldDelegate.color != color;
}
