import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF4C3EE3); // Logo & FAB
  static const Color backgroundLight = Color(0xFFF9F5FA); // Overall background
  static const Color magenta = Color(0xFFD80B57); // Selected category & Flash Deal
  static const Color lightLavender = Color(0xFFEADBFF); // Unselected category & Coin pill
  static const Color textDark = Color(0xFF1E1C38);
  static const Color textGrey = Color(0xFF88849E);
  static const Color lightBlue = Color(0xFF7ADCF6); // Circular arrow button
  
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
