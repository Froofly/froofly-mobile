import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color classicNavy = Color(0xFF0A3D62); // Logo & FAB (Primary)
  static const Color ivoryWhite = Color(0xFFF9F9F9); // Overall background
  static const Color champaignGold = Color(0xFFD4AF37); // Selected category & Flash Deal (Accent)
  static const Color richCharcoal = Color(0xFF2D3436); // Text dark
  
  static const Color primaryPurple = classicNavy; // Keeping name for compatibility, but it's Navy now
  static const Color backgroundLight = ivoryWhite; 
  static const Color magenta = champaignGold; 
  static const Color lightLavender = Color(0xFFE6EBF0); // Modified to fit Navy better (lighter navy/grey)
  static const Color textDark = richCharcoal;
  static const Color textGrey = Color(0xFF88849E);
  static const Color lightBlue = Color(0xFFD4AF37); // Use gold for arrow buttons instead of light blue
  
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(color: textDark, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.poppins(color: textDark, fontWeight: FontWeight.bold),
        bodyMedium: GoogleFonts.poppins(color: textDark),
        bodySmall: GoogleFonts.poppins(color: textGrey),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryPurple,
        unselectedItemColor: textGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
