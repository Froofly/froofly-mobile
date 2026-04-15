import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'delete_account_screen.dart';

class AccountPrivacyScreen extends StatelessWidget {
  const AccountPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFCF6FB);
    final textDark = AppTheme.textDark;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4C3EE3)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account Privacy',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
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
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDEDF4), // Slight red hue
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Color(0xFFD80B57), size: 20),
                ),
                title: Text(
                  'Request to delete account',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD80B57),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: AppTheme.textGrey.withOpacity(0.5), size: 24),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DeleteAccountScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
