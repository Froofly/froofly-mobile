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
            _buildFreeCard(),
            const SizedBox(height: 24),
            _buildPlusCard(),
            const SizedBox(height: 24),
            _buildProCard(),
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

  Widget _buildFreeCard() {
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
            'Froofly Free',
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
                'Free',
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
                  '/DEFAULT',
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
          _buildFeatureRow(Icons.local_offer, 'Standard offers', '', true),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.account_balance_wallet, 'Basic cashback (5–10%)', '', true),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.access_time_filled, 'Limited daily claims (2–3)', '', true),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.verified_user, 'Standard verification time', '', true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.textGrey, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Current Plan',
                style: GoogleFonts.poppins(
                  color: AppTheme.textGrey,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'Froofly Plus',
                style: GoogleFonts.poppins(
                  color: AppTheme.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
               const Icon(Icons.star, color: Color(0xFF4C3EE3), size: 24),
            ]
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹99',
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
          _buildFeatureRow(Icons.bolt, '+50% extra coins', ' on every bill', true),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.shopping_bag, 'Access to premium deals', '', true),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.speed, 'Faster reward approval', '', true),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.history_toggle_off, '5–6 claims per day', '', true),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.card_giftcard, 'Joining bonus: ₹100 coins', '', true),
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
                'Get Froofly Plus',
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
            border: Border.all(color: const Color(0xFFA61E4D), width: 2), // Magenta border
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA61E4D).withOpacity(0.15),
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
                    '₹199',
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
              _buildFeatureRow(Icons.rocket_launch, '2x coins on every bill', '', false),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.local_offer, 'VIP merchant offers', '', false),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.lock_open, 'Unlimited reward unlocks', '', false),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.speed, 'Instant / priority verification', '', false),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.card_giftcard, 'Joining bonus: ₹250 coins', '', false),
              const SizedBox(height: 16),
              _buildFeatureRow(Icons.military_tech, 'Profile badge', '', false),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA61E4D),
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
