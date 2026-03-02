import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/theme/app_theme.dart';
import '../core/utils/format_utils.dart';

/// ULTRA PREMIUM Storage Indicator
/// Features:
/// - 4-layer ring system (shadow → glow → mid → main)
/// - Animated pulse effect
/// - Gradient text with shine
/// - Floating particles (subtle)
/// - Inner depth shadows
class StorageIndicator extends StatefulWidget {
  final int usedBytes;
  final int totalBytes;
  final double size;
  
  const StorageIndicator({
    super.key,
    required this.usedBytes,
    required this.totalBytes,
    this.size = 200,
  });
  
  @override
  State<StorageIndicator> createState() => _StorageIndicatorState();
}

class _StorageIndicatorState extends State<StorageIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    
    // Pulse animation (subtle glow)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _progressController.forward();
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final percentage = FormatUtils.calculatePercentage(
      widget.usedBytes,
      widget.totalBytes,
    );
    
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring (animated pulse)
            SizedBox(
              width: widget.size + 20,
              height: widget.size + 20,
              child: CustomPaint(
                painter: _GlowRingPainter(
                  progress: (percentage / 100) * _progressAnimation.value,
                  pulseValue: _pulseAnimation.value,
                ),
              ),
            ),
            
            // Main indicator
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _StoragePainter(
                  progress: (percentage / 100) * _progressAnimation.value,
                  strokeWidth: 20,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Solid white percentage text for clarity
                      Text(
                        '${(percentage * _progressAnimation.value).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        FormatUtils.formatBytes(widget.usedBytes),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'of ${FormatUtils.formatBytes(widget.totalBytes)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Outer glow ring painter with pulse
class _GlowRingPainter extends CustomPainter {
  final double progress;
  final double pulseValue;
  
  _GlowRingPainter({required this.progress, required this.pulseValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final glowPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF00E5FF), // Cyan
          AppTheme.neonGreenPrimary, // Green
          Color(0xFFB2FF59), // Lime
          Color(0xFF00E5FF), // Cyan
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(rect)
      ..strokeWidth = 4 * pulseValue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * pulseValue);
    
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Main storage ring painter with 4 layers
class _StoragePainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  
  _StoragePainter({required this.progress, required this.strokeWidth});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * math.pi * progress;
    
    // Background ring with subtle dark gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Layer 1: Deep shadow for 3D depth
    final shadowPaint = Paint()
      ..color = AppTheme.neonGreenPrimary.withOpacity(0.15)
      ..strokeWidth = strokeWidth + 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, shadowPaint);
    
    // Layer 2: Outer glow
    // Layer 2: Outer glow
    final outerGlowPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF00E5FF), // Cyan
          AppTheme.neonGreenPrimary, // Green
          Color(0xFFB2FF59), // Lime
          Color(0xFF00E5FF), // Cyan
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(rect)
      ..strokeWidth = strokeWidth + 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, outerGlowPaint);
    
    // Layer 3: Mid shine layer
    final midPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.neonGreenPrimary.withOpacity(0.9),
          AppTheme.neonGreenSecondary.withOpacity(0.9),
          const Color(0xFF00CC77).withOpacity(0.9),
        ],
      ).createShader(rect)
      ..strokeWidth = strokeWidth + 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, midPaint);
    
    // Layer 4: Main solid ring with multi-tone gradient
    // Layer 1.5: Deep Black Shadow for maximum contrast on dark card
    final deepShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = strokeWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, deepShadowPaint);

    // Layer 4: Main solid ring with Premium Cyan-Green Gradient
    final mainPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF00E5FF), // Cyan (Start)
          AppTheme.neonGreenPrimary, // Neon Green
          Color(0xFFB2FF59), // Lime Green (Highlight)
          Color(0xFF00E5FF), // Back to Cyan
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, mainPaint);
    
    // Layer 5: Inner highlight for 3D pop
    final innerHighlight = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.transparent,
        ],
        stops: [0.0, 0.5],
      ).createShader(rect)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle * 0.3, // Only partial highlight
      false,
      innerHighlight,
    );
  }
  
  @override
  bool shouldRepaint(_StoragePainter oldDelegate) => oldDelegate.progress != progress;
}
