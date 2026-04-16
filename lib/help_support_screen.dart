import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'general_inquiry_screen.dart';
import 'order_related_screen.dart';
import 'suggestion_screen.dart';
import 'membership_faq_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          'Help & Support',
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
              _buildSettingsItem(context, Icons.info_outline, 'General Inquiry', const Color(0xFF4C3EE3)),
              _buildDivider(),
              _buildSettingsItem(context, Icons.lightbulb_outline, 'Suggestions', const Color(0xFF4C3EE3)),
              _buildDivider(),
              _buildSettingsItem(context, Icons.star_outline, 'Froofly Membership', const Color(0xFF4C3EE3)),
              _buildDivider(),
              _buildSettingsItem(context, Icons.local_shipping_outlined, 'Order Related', const Color(0xFF4C3EE3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFEADBFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppTheme.textDark,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppTheme.textGrey.withOpacity(0.5), size: 24),
      onTap: () {
        if (title == 'General Inquiry') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GeneralInquiryScreen()),
          );
        } else if (title == 'Order Related') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderRelatedScreen()),
          );
        } else if (title == 'Suggestions') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SuggestionScreen()),
          );
        } else if (title == 'Froofly Membership') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MembershipFaqScreen()),
          );
        }
      },
    );
  }
}
