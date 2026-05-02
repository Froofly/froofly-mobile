import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF9F9F9);
    final textDark = AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A3D62)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo or Header Graphic
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE6EBF0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A3D62).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.volunteer_activism_outlined,
                size: 64,
                color: Color(0xFF0A3D62),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'A Smarter Offline Economy',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph(
                      'Froofly is a smart rewards platform designed to bridge the gap between offline spending and real value. Every day, people spend money at local shops, cafés, and services—but get nothing in return. At the same time, small businesses struggle to attract and retain customers in an increasingly competitive market.'),
                  const SizedBox(height: 16),
                  _buildParagraph(
                      'Froofly solves both problems with a simple idea: reward real-world actions.'),
                  const SizedBox(height: 16),
                  _buildParagraph(
                      'With Froofly, users can discover nearby offers, visit stores, and earn rewards by simply uploading proof of their purchase. No fake engagement, no hidden conditions—just genuine savings for real spending.'),
                  const SizedBox(height: 16),
                  _buildParagraph(
                      'For businesses, Froofly is not just another marketing platform. It is a performance-driven customer acquisition engine and making it a risk-free and result-oriented solution.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A3D62), Color(0xFFD4AF37)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A3D62).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Mission',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'To build a smarter offline economy—where every transaction creates value for both customers and businesses.\n\nWe believe the future of local commerce is not just about discounts, but about trust, transparency, and measurable outcomes.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppTheme.textGrey,
        fontSize: 14,
        height: 1.6,
      ),
    );
  }
}
