import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Premium animated glassmorphism background
/// Apple/Google Material You inspired design
class GlassmorphismBackground extends StatefulWidget {
  final Widget child;
  
  const GlassmorphismBackground({
    super.key,
    required this.child,
  });
  
  @override
  State<GlassmorphismBackground> createState() => _GlassmorphismBackgroundState();
}

class _GlassmorphismBackgroundState extends State<GlassmorphismBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  
  @override
  void initState() {
    super.initState();
    
    // Multiple animation controllers for different orbs
    _controller1 = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _controller2 = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
    
    _controller3 = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background (App Theme)
        Container(
          color: AppTheme.backgroundDark,
        ),
        
        // Dark gradient overlay for depth
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.backgroundDark,
                const Color(0xFF1E293B), // Slightly lighter navy
                AppTheme.backgroundDark,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Animated orb 1 (Neon green - subtle)
        AnimatedBuilder(
          animation: _controller1,
          builder: (context, child) {
            return Positioned(
              top: -100 + (math.sin(_controller1.value * 2 * math.pi) * 50),
              left: -50 + (math.cos(_controller1.value * 2 * math.pi) * 30),
              child: _buildGlassOrb(
                size: 400,
                color: AppTheme.neonGreenPrimary.withOpacity(0.15),
                blur: 100,
              ),
            );
          },
        ),
        
        // Animated orb 2 (Cyan tint - very subtle)
        AnimatedBuilder(
          animation: _controller2,
          builder: (context, child) {
            return Positioned(
              top: 200 + (math.cos(_controller2.value * 2 * math.pi) * 40),
              right: -100 + (math.sin(_controller2.value * 2 * math.pi) * 50),
              child: _buildGlassOrb(
                size: 350,
                color: Colors.blueAccent.withOpacity(0.1),
                blur: 90,
              ),
            );
          },
        ),
        
        // Animated orb 3 (Light green)
        AnimatedBuilder(
          animation: _controller3,
          builder: (context, child) {
            return Positioned(
              bottom: -80 + (math.sin(_controller3.value * 2 * math.pi) * 60),
              left: 100 + (math.cos(_controller3.value * 2 * math.pi) * 40),
              child: _buildGlassOrb(
                size: 300,
                color: AppTheme.neonGreenSecondary.withOpacity(0.1),
                blur: 80,
              ),
            );
          },
        ),
        
        // Static orb for depth (white glow)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: -150,
          child: _buildGlassOrb(
            size: 500,
            color: AppTheme.neonGreenPrimary.withOpacity(0.05),
            blur: 120,
          ),
        ),
        
        // Content on top
        widget.child,
      ],
    );
  }
  
  Widget _buildGlassOrb({
    required double size,
    required Color color,
    required double blur,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blur,
            spreadRadius: blur / 2,
          ),
        ],
      ),
    );
  }
}
