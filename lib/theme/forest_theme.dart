import 'package:flutter/material.dart';

class ForestTheme {
  // Forest app color palette - brown and cream based
  static const Color creamBackground = Color(0xFFF5F0E8);
  static const Color creamSurface = Color(0xFFFFF8E7);
  static const Color brownLight = Color(0xFF8B7355);
  static const Color brownMedium = Color(0xFF6B5344);
  static const Color brownDark = Color(0xFF4A3728);
  static const Color brownVeryDark = Color(0xFF3D2817);
  static const Color greenAccent = Color(0xFF7CB342);
  static const Color greenLight = Color(0xFF8BC34A);
  static const Color textBrown = Color(0xFF3D2817);
  static const Color textLightBrown = Color(0xFF6B5344);
  static const Color dividerBrown = Color(0xFFD4C4A8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: brownMedium,
        onPrimary: creamSurface,
        primaryContainer: brownLight,
        onPrimaryContainer: brownVeryDark,
        secondary: brownLight,
        onSecondary: creamSurface,
        secondaryContainer: creamSurface,
        onSecondaryContainer: brownMedium,
        tertiary: brownLight,
        onTertiary: creamSurface,
        tertiaryContainer: creamSurface,
        onTertiaryContainer: brownMedium,
        error: Colors.red,
        onError: Colors.white,
        background: creamBackground,
        onBackground: textBrown,
        surface: creamSurface,
        onSurface: textBrown,
        surfaceVariant: creamBackground,
        onSurfaceVariant: textLightBrown,
        outline: dividerBrown,
        outlineVariant: dividerBrown,
        shadow: brownDark,
        scrim: brownDark,
        inverseSurface: brownMedium,
        onInverseSurface: creamSurface,
        inversePrimary: creamSurface,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: creamSurface,
        foregroundColor: textBrown,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textBrown,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textBrown),
      ),

      // Scaffold theme
      scaffoldBackgroundColor: creamBackground,

      // Card theme
      cardTheme: CardTheme(
        color: creamSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: brownDark.withOpacity(0.1),
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: creamSurface,
        indicatorColor: brownLight.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: brownDark,
                fontWeight: FontWeight.w600,
              );
            }
            return const TextStyle(
              color: textLightBrown,
              fontWeight: FontWeight.normal,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: brownDark);
            }
            return const IconThemeData(color: textLightBrown);
          },
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return brownDark;
              }
              return brownMedium;
            },
          ),
          foregroundColor: WidgetStateProperty.all<Color>(creamSurface),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          elevation: WidgetStateProperty.all<double>(2),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(brownMedium),
          side: WidgetStateProperty.all<BorderSide>(
            BorderSide(color: brownMedium, width: 2),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ),

      // Choice chip theme
      chipTheme: ChipThemeData(
        backgroundColor: creamSurface,
        selectedColor: brownMedium,
        labelStyle: const TextStyle(
          color: textBrown,
        ),
        // selectedLabelStyle: const TextStyle(
        //   color: creamSurface,
        //   fontWeight: FontWeight.w600,
        // ),
        secondaryLabelStyle: const TextStyle(
          color: textBrown,
        ),
        side: BorderSide(color: brownLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        pressElevation: 0,
        checkmarkColor: creamSurface,
      ),

      // Segmented button theme
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return brownMedium;
              }
              return creamSurface;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return creamSurface;
              }
              return textBrown;
            },
          ),
          side: WidgetStateProperty.all<BorderSide>(
            BorderSide(color: brownLight, width: 1),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textBrown,
          fontSize: 57,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textBrown,
          fontSize: 45,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textBrown,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: textBrown,
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: textBrown,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textBrown,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textBrown,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textBrown,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textBrown,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textBrown,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textBrown,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: textLightBrown,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: textBrown,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: textBrown,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: textLightBrown,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // List tile theme
      listTileTheme: const ListTileThemeData(
        tileColor: creamSurface,
        textColor: textBrown,
        iconColor: brownMedium,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: dividerBrown,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
