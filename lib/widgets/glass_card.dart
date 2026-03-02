import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// ULTRA PREMIUM 3D Liquid Glass Card
/// Features:
/// - Neumorphism + Glassmorphism hybrid
/// - Multiple depth layers
/// - Animated shimmer effect
/// - Inner/outer shadows for 3D pop
/// - Gradient mesh background
class GlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool hasGreenGlow;
  final VoidCallback? onTap;
  final Gradient? customGradient;
  final bool isDark;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(20),
    this.hasGreenGlow = false,
    this.customGradient,
    this.isDark = false,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Stack(
            children: [
              // Base card with neumorphism + glass
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        // Multi-layer gradient for depth
                        gradient: widget.customGradient ?? (widget.isDark 
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.4),
                                const Color(0xFF1A1A1A).withOpacity(0.5),
                                Colors.black.withOpacity(0.3),
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.neonGreenPrimary.withOpacity(0.3),
                                AppTheme.neonGreenSecondary.withOpacity(0.2),
                                const Color(0xFF00CC77).withOpacity(0.25),
                                AppTheme.neonGreenPrimary.withOpacity(0.2),
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            )),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        border: Border.all(
                          color: AppTheme.neonGreenPrimary.withOpacity(0.5),
                          width: 2.5,
                        ),
                        boxShadow: [
                          // NEUMORPHISM: Top-left light shadow
                          BoxShadow(
                            color: Colors.white.withOpacity(0.6),
                            offset: const Offset(-4, -4),
                            blurRadius: 16,
                            spreadRadius: 0,
                          ),
                          // NEUMORPHISM: Bottom-right dark shadow
                          BoxShadow(
                            color: AppTheme.neonGreenPrimary.withOpacity(0.3),
                            offset: const Offset(6, 6),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                          // Deep 3D shadow
                          BoxShadow(
                            color: AppTheme.neonGreenPrimary.withOpacity(0.25),
                            offset: const Offset(0, 16),
                            blurRadius: 40,
                            spreadRadius: -8,
                          ),
                          // Mid-level shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 8),
                            blurRadius: 24,
                            spreadRadius: 0,
                          ),
                          // Green glow (always subtle)
                          BoxShadow(
                            color: AppTheme.neonGreenPrimary.withOpacity(0.4),
                            offset: const Offset(0, 4),
                            blurRadius: 28,
                            spreadRadius: 0,
                          ),
                          // Extra intense glow for active states
                          if (widget.hasGreenGlow)
                            BoxShadow(
                              color: AppTheme.neonGreenPrimary.withOpacity(0.6),
                              offset: const Offset(0, 8),
                              blurRadius: 50,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Child content layer
              // We don't use infinity here so the card can wrap its content 
              // when used outside of a GridView (like the Storage Section)
              Padding(
                padding: widget.padding,
                child: widget.child,
              ),
              
              // Animated shimmer overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.15 * _shimmerController.value),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: [
                                _shimmerController.value - 0.3,
                                _shimmerController.value,
                                _shimmerController.value + 0.3,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Inner highlight for extra depth
              Positioned(
                top: 1,
                left: widget.borderRadius / 2,
                right: widget.borderRadius / 2,
                child: IgnorePointer(
                  child: Container(
                    height: widget.borderRadius,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(widget.borderRadius - 2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
