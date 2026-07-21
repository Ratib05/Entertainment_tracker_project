import 'package:flutter/material.dart';

/// AppTheme provides a centralized theme configuration for the entire app.
/// This class defines colors, typography, component styling, and other
/// visual properties to maintain a consistent design system.
class AppTheme {
  // Dark theme palette (Movies)
  static const _graphite = Color(0xFF353535);
  static const _stormyTeal = Color(0xFF3C6E71);
  static const _ashGrey = Color(0xFF9EB7B8);
  static const _alabasterGrey = Color(0xFFD9D9D9);
  static const _yaleBlue = Color(0xFF284B63);

  // Light theme palette (Games)
  static const _magentaBloom = Color(0xFFDB2763);
  static const _yellowGreen = Color(0xFFB0DB43);
  static const _neonIce = Color(0xFF12EAEA);
  static const _icyBlue = Color(0xFFBCE7FD);
  static const _lilac = Color(0xFFC492B1);

  /// dark() creates a dark Material 3 theme for movie mode.
  /// Features a dark background with Yale Blue accents.
  static ThemeData dark() {
    // Use Yale Blue as the primary seed color for dark theme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _yaleBlue,
      brightness: Brightness.dark,
    );

    return ThemeData(
      // Enable Material 3 design system (latest Material design)
      useMaterial3: true,
      colorScheme: colorScheme,

      // ========== SCAFFOLD & BACKGROUND ==========
      // Graphite background for movie mode
      scaffoldBackgroundColor: _graphite,

      // ========== APP BAR STYLING ==========
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _graphite,
        foregroundColor: _alabasterGrey,
      ),

      // ========== FLOATING ACTION BUTTON STYLING ==========
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _yaleBlue,
        foregroundColor: _alabasterGrey,
        elevation: 2,
      ),

      // ========== INPUT FIELD STYLING ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A22),
        labelStyle: const TextStyle(color: _ashGrey),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _stormyTeal),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _stormyTeal),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _yaleBlue, width: 2),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ========== CARD STYLING ==========
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1A1A22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _stormyTeal),
        ),
      ),
      
      // ========== TEXT STYLING ==========
      // Use Material 3 typography designed for white text on dark backgrounds
      textTheme: Typography.whiteMountainView,
      
      // ========== SEGMENTED BUTTON STYLING ==========
      // Segmented buttons are used for toggle/selection groups (e.g., "Film" vs "Show")
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          // Customize text color based on selection state
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            // Selected buttons show white text
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            // Unselected buttons show muted gray text
            return Colors.grey.shade400;
          }),
        ),
      ),
    );
  }

  /// light() creates a light Material 3 theme for game mode.
  /// Features a light background with vibrant accent colors.
  static ThemeData light() {
    // Use Neon Ice as the primary seed color for light theme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _neonIce,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // ========== SCAFFOLD & BACKGROUND ==========
      // Alabaster Grey background for game mode
      scaffoldBackgroundColor: _alabasterGrey,

      // ========== APP BAR STYLING ==========
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _alabasterGrey,
        foregroundColor: _graphite,
      ),

      // ========== FLOATING ACTION BUTTON STYLING ==========
      // Icy Blue for FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _icyBlue,
        foregroundColor: _graphite,
        elevation: 2,
      ),

      // ========== INPUT FIELD STYLING ==========
      // Lilac borders for input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: _yellowGreen),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _lilac),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _lilac),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _magentaBloom, width: 2),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ========== CARD STYLING ==========
      // Neon Ice borders for cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _neonIce, width: 2),
        ),
      ),

      // ========== TEXT STYLING ==========
      textTheme: Typography.blackMountainView,

      // ========== SEGMENTED BUTTON STYLING ==========
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _magentaBloom;
            }
            return _lilac;
          }),
        ),
      ),
    );
  }
}
