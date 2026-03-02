import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Liquid Glass Theme with Neon Green Accent
/// Background: Dark Navy (#0F172A)
/// Primary: Liquid Glass White (semi-transparent)
/// Accent: Neon Green (#00FF88, #10D97A)
class AppTheme {
  // Color Palette
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color neonGreenPrimary = Color(0xFF00FF88);
  static const Color neonGreenSecondary = Color(0xFF10D97A);
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFFB4B9C4);
  
  // Glass Colors
  static final Color glassWhite = Colors.white.withOpacity(0.1);
  static final Color glassWhiteStrong = Colors.white.withOpacity(0.15);
  static final Color glassWhiteWeak = Colors.white.withOpacity(0.08);
  
  // Shadow & Glow Colors
  static final Color shadowDark = Colors.black.withOpacity(0.3);
  static final Color innerGlow = Colors.white.withOpacity(0.1);
  static final Color greenGlow = neonGreenPrimary.withOpacity(0.3);
  
  // Gradients
  static const LinearGradient neonGreenGradient = LinearGradient(
    colors: [neonGreenPrimary, neonGreenSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static final LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.15),
      Colors.white.withOpacity(0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Get Material Theme
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        surface: backgroundDark,
        primary: neonGreenPrimary,
        secondary: neonGreenSecondary,
        onSurface: Colors.white,
        onPrimary: Colors.black,
      ),
      
      // Typography
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.9),
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white.withOpacity(0.9),
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white.withOpacity(0.8),
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textGrey,
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // Elevated Button Theme (for CTAs)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreenPrimary,
          foregroundColor: Colors.black, // Better contrast on neon green
          elevation: 8,
          shadowColor: greenGlow,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Card Theme (frosted dark glass)
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
  
  // 3D Glass Box Decoration
  static BoxDecoration glassDecoration({
    double borderRadius = 24,
    bool hasGreenGlow = false,
  }) {
    return BoxDecoration(
      gradient: glassGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        // Outer shadow
        BoxShadow(
          color: shadowDark,
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: 0,
        ),
        // Inner glow (simulated with inset-like effect)
        BoxShadow(
          color: innerGlow,
          offset: const Offset(0, -2),
          blurRadius: 8,
          spreadRadius: -2,
        ),
        // Optional green glow
        if (hasGreenGlow)
          BoxShadow(
            color: greenGlow,
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
      ],
    );
  }
}
