import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Warna Utama (Emerald Green Islami)
  static const Color primaryColor = Color(0xFF047857); // Emerald 700
  static const Color secondaryColor = Color(0xFF10B981); // Emerald 500
  static const Color backgroundColor = Color(0xFFF3F4F6); // Gray 100
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color warningColor = Color(0xFFF59E0B); // Amber 500
  static const Color textDark = Color(0xFF1F2937); // Gray 800
  static const Color textLight = Color(0xFF6B7280); // Gray 500

  // Warna Aksen berdasarkan Role (Lebih modern)
  static const Color roleMurobbiColor = Color(0xFF3B82F6); // Blue 500
  static const Color roleWaliColor = Color(0xFF8B5CF6); // Violet 500
  static const Color roleKoordinatorColor = Color(0xFFF97316); // Orange 500
  static const Color roleTuColor = Color(0xFF14B8A6); // Teal 500
  static const Color roleKepsekColor = Color(0xFF6366F1); // Indigo 500

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(color: textDark, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(color: textDark, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.outfit(color: textDark, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.outfit(color: textDark, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.outfit(color: textDark, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.outfit(color: textDark),
        bodyMedium: GoogleFonts.outfit(color: textDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        color: surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.outfit(color: textLight),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }

  static Color getColorForRole(String role) {
    switch (role.toLowerCase()) {
      case 'murobbi':
        return roleMurobbiColor;
      case 'wali':
        return roleWaliColor;
      case 'koordinator':
        return roleKoordinatorColor;
      case 'tu':
        return roleTuColor;
      case 'kepala sekolah':
        return roleKepsekColor;
      default:
        return primaryColor;
    }
  }

  static IconData getIconForRole(String role) {
    switch (role.toLowerCase()) {
      case 'murobbi':
        return Icons.menu_book_rounded;
      case 'wali':
        return Icons.family_restroom_rounded;
      case 'koordinator':
        return Icons.analytics_rounded;
      case 'tu':
        return Icons.admin_panel_settings_rounded;
      case 'kepala sekolah':
        return Icons.account_balance_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}
