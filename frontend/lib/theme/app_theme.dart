import 'package:flutter/material.dart';

/// AppTheme provides a centralized theme configuration for the entire app.
/// This class defines colors, typography, component styling, and other
/// visual properties to maintain a consistent design system.
class AppTheme {
  /// Primary seed color used for Material 3 color scheme generation.
  /// Purple (0xFF9333EA) serves as the base for all derived colors.
  static const _seedColor = Color(0xFF9333EA);

  /// light() creates a Material 3 theme with a light color scheme.
  /// Note: Despite "light()" naming, this theme uses a dark background
  /// (very dark gray #0F0F12) for a dark-mode aesthetic.
  static ThemeData light() {
    // Generate a complete Material 3 color scheme from the seed color
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      // Enable Material 3 design system (latest Material design)
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // ========== SCAFFOLD & BACKGROUND ==========
      // Dark background color for the main content area
      scaffoldBackgroundColor: const Color(0xFF0F0F12),
      
      // ========== APP BAR STYLING ==========
      appBarTheme: AppBarTheme(
        // Title aligned to the left (not centered)
        centerTitle: false,
        // Remove drop shadow below app bar
        elevation: 0,
        // Remove shadow when content scrolls under app bar
        scrolledUnderElevation: 0,
        // Match scaffold background for seamless appearance
        backgroundColor: const Color(0xFF0F0F12),
        // Text/icon color in the app bar (white for dark background)
        foregroundColor: Colors.white,
      ),
      
      // ========== FLOATING ACTION BUTTON STYLING ==========
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        // Use primary color from generated color scheme
        backgroundColor: colorScheme.primary,
        // Text/icon color inside the FAB
        foregroundColor: colorScheme.onPrimary,
        // Slight shadow for depth
        elevation: 2,
      ),
      
      // ========== INPUT FIELD STYLING ==========
      inputDecorationTheme: InputDecorationTheme(
        // Fill the input field with a background color
        filled: true,
        // Slightly lighter dark color for input fields
        fillColor: const Color(0xFF1A1A22),
        // Label text color (light gray)
        labelStyle: TextStyle(color: Colors.grey.shade400),
        
        // Default/idle state border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A35)),
        ),
        
        // Border when field is enabled but not focused
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A35)),
        ),
        
        // Border when field is focused (active)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          // Highlight with primary color and thicker border
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        
        // Padding inside the input field for text/icons
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // ========== CARD STYLING ==========
      cardTheme: CardThemeData(
        // Remove drop shadow
        elevation: 0,
        // Dark background matching input fields
        color: const Color(0xFF1A1A22),
        // Rounded corners with subtle border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A35)),
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
}
