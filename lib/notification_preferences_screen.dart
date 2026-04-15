import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool _whatsappPromotional = true;
  bool _smsPromotional = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _whatsappPromotional = prefs.getBool('promoWhatsapp') ?? true;
      _smsPromotional = prefs.getBool('promoSms') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _updatePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      if (key == 'promoWhatsapp') _whatsappPromotional = value;
      if (key == 'promoSms') _smsPromotional = value;
    });
    // In a real app, you would also sync this with your backend here.
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bgColor = const Color(0xFFFCF6FB);
    final primaryColor = const Color(0xFF4C3EE3);
    final textDark = AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification Preferences',
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
              _buildPrefCard(
                icon: Icons.chat,
                title: 'WhatsApp messages',
                description: 'Receive WhatsApp updates about coupons, promotions and offers',
                value: _whatsappPromotional,
                onChanged: (val) => _updatePreference('promoWhatsapp', val),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
              _buildPrefCard(
                icon: Icons.chat_bubble_outline,
                title: 'Promotional SMS',
                description: 'Receive SMS updates about coupons, promotions and offers',
                value: _smsPromotional,
                onChanged: (val) => _updatePreference('promoSms', val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrefCard({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEADBFF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF4C3EE3), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFF4C3EE3), // AppTheme.primaryPurple
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
