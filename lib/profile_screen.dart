import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'theme.dart';
import 'membership_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'My Profile',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            _buildAvatarSection(),
            const SizedBox(height: 16),
            _buildBalanceCard(context, primaryColor),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 32),
            _buildAnalyticsHeader(),
            const SizedBox(height: 16),
            _buildChartCard(),
            const SizedBox(height: 16),
            _buildUploadCategoriesCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('ACCOUNT SETTINGS'),
            const SizedBox(height: 16),
            _buildSettingsList(),
            const SizedBox(height: 32),
            _buildSectionHeader('OTHER INFORMATION'),
            const SizedBox(height: 16),
            _buildOtherInformationList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4C3EE3), width: 3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF7ADCF6), // cyan background behind avatar
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.face, size: 50, color: Colors.white), // Placeholder for Alex Johnson image
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF4C3EE3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Alex Johnson',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PREMIUM MEMBER',
          style: GoogleFonts.poppins(
            color: const Color(0xFF6B5DE8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'CURRENT BALANCE',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '2,450',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Coins',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF7DE4FF), // Cyan
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MembershipScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7DE4FF), // Cyan
              foregroundColor: AppTheme.textDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Earn More',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatBox('128', 'TOTAL\nBILLS'),
        const SizedBox(width: 12),
        _buildStatBox('14', 'ACHIEVEMENTS'),
        const SizedBox(width: 12),
        _buildStatBox('342', 'FRIENDS'),
      ],
    );
  }

  Widget _buildStatBox(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF1FB), // Very light pinkish
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppTheme.textDark.withOpacity(0.7),
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Spend & Earn Analytics',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'LAST 7 DAYS',
          style: GoogleFonts.poppins(
            color: const Color(0xFF4C3EE3),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COINS EARNED',
                style: GoogleFonts.poppins(
                  color: AppTheme.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F8ED), // Light green
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+12%',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2E9C68), // Green
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Custom Spline Chart Approximation
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _CurvedChartPainter(),
            ),
          ),
          const SizedBox(height: 16),
          // X-Axis Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
              return Text(
                day,
                style: GoogleFonts.poppins(
                  color: AppTheme.textGrey.withOpacity(0.7),
                  fontSize: 10,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCategoriesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
          Text(
            'UPLOAD CATEGORIES',
            style: GoogleFonts.poppins(
              color: AppTheme.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildCategoryProgress('FOOD', '45%', 0.45, const Color(0xFF4C3EE3)),
          const SizedBox(height: 16),
          _buildCategoryProgress('RETAIL', '30%', 0.30, const Color(0xFF7ADCF6)),
          const SizedBox(height: 16),
          _buildCategoryProgress('HEALTH', '25%', 0.25, const Color(0xFFFD8AAB)),
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(String name, String percentage, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              percentage,
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EFFF),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppTheme.textDark.withOpacity(0.7),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
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
          _buildSettingsItem(Icons.edit, 'Edit Profile', const Color(0xFF4C3EE3), false),
          _buildDivider(),
          _buildSettingsItem(Icons.credit_card, 'Payment Methods', const Color(0xFF4C3EE3), false),
          _buildDivider(),
          _buildSettingsItem(Icons.notifications, 'Notification Settings', const Color(0xFF4C3EE3), false),
          _buildDivider(),
          _buildSettingsItem(Icons.help_outline, 'Help & Support', const Color(0xFF4C3EE3), false),
          _buildDivider(),
          _buildSettingsItem(Icons.logout, 'Log Out', const Color(0xFFD80B57), true), // Red color for logout
        ],
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

  Widget _buildSettingsItem(IconData icon, String title, Color color, bool hideArrow) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: hideArrow ? const Color(0xFFFDEDF4) : const Color(0xFFEADBFF), // red bg for logout, purple otherwise
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: hideArrow ? const Color(0xFFD80B57) : AppTheme.textDark,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: hideArrow
          ? null
          : Icon(Icons.chevron_right, color: AppTheme.textGrey.withOpacity(0.5), size: 24),
      onTap: () {},
    );
  }

  Widget _buildOtherInformationList() {
    return Container(
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
          _buildSettingsItem(Icons.share, 'Share the App', const Color(0xFF4C3EE3), false),
          _buildDivider(),
          _buildSettingsItem(Icons.info_outline, 'About Us', const Color(0xFF4C3EE3), false),
          _buildDivider(),
          _buildSettingsItem(Icons.privacy_tip_outlined, 'Account Privacy', const Color(0xFF4C3EE3), false),
          _buildDivider(),
          _buildSettingsItem(Icons.question_answer_outlined, 'FAQs', const Color(0xFF4C3EE3), false),
          _buildDivider(),
          _buildExpandableSettingsItem(Icons.article_outlined, 'General Info', const Color(0xFF4C3EE3)),
        ],
      ),
    );
  }

  Widget _buildExpandableSettingsItem(IconData icon, String title, Color color) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      shape: const Border(), // remove top/bottom borders when expanded
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
      iconColor: AppTheme.textGrey.withOpacity(0.5),
      collapsedIconColor: AppTheme.textGrey.withOpacity(0.5),
      children: [
        _buildSubItem('Terms and Conditions'),
        _buildSubItem('Privacy Policy'),
        _buildSubItem('Third-party Licenses'),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSubItem(String title) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppTheme.textDark.withOpacity(0.8),
          fontSize: 13,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppTheme.textGrey.withOpacity(0.5), size: 20),
      onTap: () {},
    );
  }

}


class _CurvedChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Generate a simple curved line that looks like the mockup
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4C3EE3), Color(0xFF7ADCF6)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Points imitating the graph shape
    final p0 = Offset(0, size.height * 0.8);
    final p1 = Offset(size.width * 0.2, size.height * 0.5);
    final p2 = Offset(size.width * 0.4, size.height * 0.8);
    final p3 = Offset(size.width * 0.6, size.height * 0.1); // Peak
    final p4 = Offset(size.width * 0.8, size.height * 0.7); // Dip
    final p5 = Offset(size.width, size.height * 0.2);       // End

    path.moveTo(p0.dx, p0.dy);
    
    // Smooth bezier curve based on control points
    _addBezierCurve(path, p0, p1);
    _addBezierCurve(path, p1, p2);
    _addBezierCurve(path, p2, p3);
    _addBezierCurve(path, p3, p4);
    _addBezierCurve(path, p4, p5);

    canvas.drawPath(path, paint);

    // Draw little dots along the path to simulate the screenshot dots
    final dotPaintCyan = Paint()..color = const Color(0xFF7ADCF6)..style = PaintingStyle.fill;
    final dotPaintBlue = Paint()..color = const Color(0xFF4C3EE3)..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.65), 3, dotPaintBlue);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.45), 3, dotPaintBlue);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.4), 3, dotPaintBlue);
    canvas.drawCircle(p5, 4, dotPaintCyan);
  }

  void _addBezierCurve(Path path, Offset start, Offset end) {
    final cx1 = start.dx + (end.dx - start.dx) / 2;
    final cy1 = start.dy;
    final cx2 = cx1;
    final cy2 = end.dy;
    path.cubicTo(cx1, cy1, cx2, cy2, end.dx, end.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
