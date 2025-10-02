import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Government of India Official Colors
  static const Color govtSaffron = Color(0xFFFF9933);  // India flag saffron
  static const Color govtWhite = Color(0xFFFFFFFF);
  static const Color govtGreen = Color(0xFF138808);    // India flag green
  static const Color govtNavy = Color(0xFF000080);     // Ashoka Chakra blue
  
  // Primary Color Palette (Government Branding)
  static const Color primaryColor = govtNavy;
  static const Color primaryDarkColor = Color(0xFF000050);
  static const Color primaryLightColor = Color(0xFF3333B3);
  static const Color secondaryColor = govtGreen;
  static const Color secondaryDarkColor = Color(0xFF00600F);
  static const Color secondaryLightColor = Color(0xFF4CAF50);
  static const Color accentColor = govtSaffron;
  
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFB300);
  static const Color successColor = govtGreen;
  static const Color infoColor = Color(0xFF1976D2);
  
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF616161);
  static const Color dividerColor = Color(0xFFBDBDBD);
  
  // Status Colors (High Contrast for Accessibility)
  static const Color statusPending = Color(0xFFFFB300);      // Bright orange
  static const Color statusInProgress = Color(0xFF1976D2);   // Bright blue
  static const Color statusCompleted = govtGreen;            // Flag green
  static const Color statusOnHold = Color(0xFF757575);       // Medium gray
  static const Color statusCancelled = Color(0xFFD32F2F);    // Bright red
  static const Color statusDelayed = Color(0xFFD32F2F);      // Bright red
  
  // Accessibility - Minimum Touch Target Sizes
  static const double minTouchTarget = 48.0;
  static const double preferredTouchTarget = 56.0;
  static const double largeTouchTarget = 64.0;
  
  // Light Theme (Optimized for Accessibility)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onError: Colors.white,
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white, size: 28),
      titleTextStyle: GoogleFonts.notoSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      toolbarHeight: 64,
    ),
    
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: surfaceColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        minimumSize: const Size(120, 56), // Increased from 48 to 56
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.notoSans(
          fontSize: 18, // Increased from 16
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 2),
        minimumSize: const Size(120, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(80, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      extendedSizeConstraints: BoxConstraints.tightFor(height: 56),
      extendedIconLabelSpacing: 12,
      extendedPadding: EdgeInsets.symmetric(horizontal: 24),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2.5),
      ),
      labelStyle: GoogleFonts.notoSans(
        color: textSecondaryColor,
        fontSize: 18, // Increased from 16
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.notoSans(
        color: textSecondaryColor,
        fontSize: 16, // Increased from 14
      ),
      helperStyle: GoogleFonts.notoSans(
        fontSize: 14,
        color: textSecondaryColor,
      ),
      errorStyle: GoogleFonts.notoSans(
        fontSize: 14,
        color: errorColor,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      constraints: const BoxConstraints(minHeight: 56),
    ),
    
    textTheme: TextTheme(
      // Display styles - Page titles
      displayLarge: GoogleFonts.notoSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.notoSans(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.notoSans(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
        height: 1.3,
      ),
      // Headlines - Section headers
      headlineLarge: GoogleFonts.notoSans(
        fontSize: 24, // Increased from 22
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.notoSans(
        fontSize: 22, // Increased from 20
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.notoSans(
        fontSize: 20, // Increased from 18
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.4,
      ),
      // Titles - Card headers
      titleLarge: GoogleFonts.notoSans(
        fontSize: 20, // Increased from 18
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.notoSans(
        fontSize: 18, // Increased from 16
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.notoSans(
        fontSize: 16, // Increased from 14
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.4,
      ),
      // Body - Main content
      bodyLarge: GoogleFonts.notoSans(
        fontSize: 18, // Increased from 16
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.notoSans(
        fontSize: 16, // Increased from 14
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.notoSans(
        fontSize: 14, // Increased from 12
        fontWeight: FontWeight.normal,
        color: textSecondaryColor,
        height: 1.5,
      ),
      // Labels - Buttons and chips
      labelLarge: GoogleFonts.notoSans(
        fontSize: 16, // Increased from 14
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.notoSans(
        fontSize: 14, // Increased from 12
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.notoSans(
        fontSize: 12, // Increased from 10
        fontWeight: FontWeight.w600,
        color: textSecondaryColor,
        height: 1.4,
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
      selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 14),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[200]!,
      selectedColor: primaryLightColor,
      labelStyle: GoogleFonts.notoSans(
        fontSize: 16, // Increased from 14
        color: textPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide(color: Colors.grey[400]!, width: 1),
    ),
    
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    
    iconTheme: const IconThemeData(
      color: textPrimaryColor,
      size: 28, // Increased from 24
    ),
    
    listTileTheme: ListTileThemeData(
      minVerticalPadding: 16,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      titleTextStyle: GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
      subtitleTextStyle: GoogleFonts.notoSans(
        fontSize: 14,
        color: textSecondaryColor,
      ),
    ),
  );
  
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryLightColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    
    colorScheme: const ColorScheme.dark(
      primary: primaryLightColor,
      secondary: secondaryLightColor,
      surface: Color(0xFF1E1E1E),
      error: errorColor,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF1E1E1E),
    ),
    
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
    ),
  );
}