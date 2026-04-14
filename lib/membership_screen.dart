import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFCF6FB);
    final primaryColor = const Color(0xFF4C3EE3);

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
          'Froofly Plus',
          style: GoogleFonts.poppins(
            color: primaryColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: AppTheme.textGrey),
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
            _buildHeaderBadge(),
            const SizedBox(height: 16),
            _buildTitleArea(),
            const SizedBox(height: 32),
            _buildPlusCard(),
            const SizedBox(height: 24),
            _buildProCard(),
            const SizedBox(height: 48),
            Text(
              'Compare Plans',
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            _buildCompareTable(),
            const SizedBox(height: 48),
            _buildBottomBanner(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEADBFF), // light purple
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Color(0xFFA61E4D), size: 12), // dark pink star
          const SizedBox(width: 4),
          Text(
            'PREMIUM MEMBERSHIP',
            style: GoogleFonts.poppins(
              color: const Color(0xFFA61E4D),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleArea() {
    return Column(
      children: [
        Text(
          'Maximize Your',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4C3EE3), Color(0xFFD80B57)], // Blue to Magenta
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'Earnings',
            style: GoogleFonts.poppins(
              color: Colors.white, // Color is masked
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Choose a plan that fits your lifestyle\nand start earning more coins on\nevery bill.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppTheme.textGrey.withOpacity(0.8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPlusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Froofly Plus',
            style: GoogleFonts.poppins(
              color: AppTheme.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$4.99',
                style: GoogleFonts.poppins(
                  color: AppTheme.textDark,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  '/mo',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFeatureRow(Icons.bolt, '1.5x Multiplier', ' on all bill\nuploads', true),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.schedule, 'Early access to Flash Deals', '', true),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.support_agent, '24/7 Support', '', true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4C3EE3), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Select Plan',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4C3EE3),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProCard() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF4C3EE3), width: 2), // Blue border
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4C3EE3).withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 8),
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
                    'Froofly Pro',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Icon(Icons.workspace_premium, color: Color(0xFFA61E4D), size: 24),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$9.99',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textDark,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      '/mo',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFeatureRow(Icons.rocket_launch, '2.5x Multiplier on all bills', '', false),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.local_offer, 'Exclusive VIP Merchant\nOffers', '', false),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.lock_open, 'Unlimited Reward Unlocks', '', false),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.military_tech, 'Featured Badge on Profile', '', false),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.error_outline, 'Priority Customer Support', '', false),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C3EE3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Get Froofly Pro',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Badge
        Positioned(
          top: -12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFA61E4D), // Dark magenta
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'BEST VALUE',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String boldText, String lightText, bool isPlus) {
    Color iconBg = isPlus ? const Color(0xFFF0F4FF) : const Color(0xFFFFF0F5);
    Color iconColor = isPlus ? const Color(0xFF4C3EE3) : const Color(0xFFA61E4D);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 12,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: boldText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: lightText,
                  style: TextStyle(color: AppTheme.textDark.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompareTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9EEFB), // Very light pink table bg
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('FEATURE', style: _tableHeaderStyle(AppTheme.textGrey)),
              ),
              Expanded(
                flex: 1,
                child: Center(child: Text('PLUS', style: _tableHeaderStyle(AppTheme.textGrey))),
              ),
              Expanded(
                flex: 1,
                child: Center(child: Text('PRO', style: _tableHeaderStyle(const Color(0xFFA61E4D)))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _tableRow('Bill Multiplier', '1.5x', '2.5x', true),
          const SizedBox(height: 24),
          _tableRow('Merchant\nAccess', 'Standard', 'VIP Only', true),
          const SizedBox(height: 24),
          _tableRow('Support\nSpeed', 'Standard', 'Priority', false),
          const SizedBox(height: 24),
          _tableRow('Monthly Limit', 'Cap: \$2k', 'Unlimited', true),
        ],
      ),
    );
  }

  TextStyle _tableHeaderStyle(Color color) {
    return GoogleFonts.poppins(
      color: color,
      fontSize: 8,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
    );
  }

  Widget _tableRow(String feature, String plus, String pro, bool isProBlue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            feature,
            style: GoogleFonts.poppins(
              color: AppTheme.textDark,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              plus,
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              pro,
              style: GoogleFonts.poppins(
                color: isProBlue ? const Color(0xFF4C3EE3) : const Color(0xFF4C3EE3),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B5DE8), Color(0xFFC8A5FE)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          // Simulated background pattern inside the card
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.amp_stories_outlined,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join 50,000+\nFroofly Earners',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Power up your savings and\njoin the fastest-growing\nrewards ecosystem.',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

