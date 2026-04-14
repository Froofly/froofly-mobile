import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFDF7FC);
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
          '$categoryName Offers',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Rated ${categoryName}s',
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _buildHeroCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Offers',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '3 REWARDS NEARBY',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._getOffersList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _getOffersList() {
    final cyanColor = const Color(0xFF7DE4FF);
    final primaryColor = const Color(0xFF4C3EE3);
    final purplePill = const Color(0xFFEADBFF);

    if (categoryName == 'Food') {
      return [
        _buildOfferCard(title: 'Burger King', subtitle: 'BOGO Premium Meal', icon: Icons.lunch_dining, iconBgColor: purplePill, coinsRequired: 150, isUnlocked: false, actionText: 'Unlock', actionColor: cyanColor, distance: '0.8 km', actualPrice: 499, discountPrice: 349),
        const SizedBox(height: 16),
        _buildOfferCard(title: 'Starbucks', subtitle: 'Free Pastry', icon: Icons.coffee, iconBgColor: purplePill, coinsRequired: 0, isUnlocked: true, actionText: 'Use Now', actionColor: primaryColor, distance: '1.2 km', actualPrice: 350, discountPrice: 0),
        const SizedBox(height: 16),
        _buildOfferCard(title: 'Pizza Hut', subtitle: '30% Off Large Pizza', icon: Icons.local_pizza, iconBgColor: purplePill, coinsRequired: 120, isUnlocked: false, actionText: 'Unlock', actionColor: cyanColor, distance: '2.5 km', actualPrice: 599, discountPrice: 419),
      ];
    } else if (categoryName == 'Retail') {
      return [
        _buildOfferCard(title: 'Nike Store', subtitle: '\$20 Off Shoes', icon: Icons.snowshoeing, iconBgColor: purplePill, coinsRequired: 300, isUnlocked: false, actionText: 'Unlock', actionColor: cyanColor, distance: '3.1 km', actualPrice: 2999, discountPrice: 2499),
        const SizedBox(height: 16),
        _buildOfferCard(title: 'Target', subtitle: '15% Entire Purchase', icon: Icons.local_mall, iconBgColor: purplePill, coinsRequired: 0, isUnlocked: true, actionText: 'Use Now', actionColor: primaryColor, distance: '1.0 km', actualPrice: 1500, discountPrice: 1275),
        const SizedBox(height: 16),
        _buildOfferCard(title: 'Best Buy', subtitle: '10% Off Electronics', icon: Icons.computer, iconBgColor: purplePill, coinsRequired: 500, isUnlocked: false, actionText: 'Unlock', actionColor: cyanColor, distance: '4.2 km', actualPrice: 5000, discountPrice: 4500),
      ];
    } else if (categoryName == 'Fitness') {
      return [
        _buildOfferCard(title: 'Anytime Fitness', subtitle: '1 Free Month', icon: Icons.fitness_center, iconBgColor: purplePill, coinsRequired: 400, isUnlocked: false, actionText: 'Unlock', actionColor: cyanColor, distance: '1.5 km', actualPrice: 1999, discountPrice: 0),
        const SizedBox(height: 16),
        _buildOfferCard(title: 'GNC', subtitle: '25% Off Protein', icon: Icons.medication, iconBgColor: purplePill, coinsRequired: 0, isUnlocked: true, actionText: 'Use Now', actionColor: primaryColor, distance: '2.3 km', actualPrice: 1200, discountPrice: 900),
        const SizedBox(height: 16),
        _buildOfferCard(title: 'Yoga Studio', subtitle: '1 Free Class', icon: Icons.self_improvement, iconBgColor: purplePill, coinsRequired: 100, isUnlocked: false, actionText: 'Unlock', actionColor: cyanColor, distance: '0.6 km', actualPrice: 500, discountPrice: 0),
      ];
    }

    // Default (Salon and others)
    return [
      _buildOfferCard(title: 'Aura Salon', subtitle: '15% Off Haircut', icon: Icons.content_cut, iconBgColor: purplePill, coinsRequired: 100, isUnlocked: false, actionText: 'Unlock', actionColor: cyanColor, distance: '0.5 km', actualPrice: 800, discountPrice: 680),
      const SizedBox(height: 16),
      _buildOfferCard(title: 'The Barber Shop', subtitle: 'Free Beard Trim', icon: Icons.face, iconBgColor: purplePill, coinsRequired: 0, isUnlocked: true, actionText: 'Use Now', actionColor: primaryColor, distance: '1.1 km', actualPrice: 300, discountPrice: 0),
      const SizedBox(height: 16),
      _buildOfferCard(title: 'Luxe Nails', subtitle: '10% Off Manicure', icon: Icons.spa, iconBgColor: purplePill, coinsRequired: 80, isUnlocked: false, actionText: 'Unlock', actionColor: cyanColor, distance: '2.0 km', actualPrice: 600, discountPrice: 540),
    ];
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/wellness.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF261D4C).withOpacity(0.95),
                    const Color(0xFF5A45A0).withOpacity(0.4),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 24,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.magenta,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'FEATURED DROP',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Velvet Touch\nStudio',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Experience the ultimate glow-up\nwith our master stylists.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C3EE3),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        'View Exclusive Deals',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required int coinsRequired,
    required bool isUnlocked,
    required String actionText,
    required Color actionColor,
    required String distance,
    required double actualPrice,
    required double discountPrice,
  }) {
    final primaryColor = const Color(0xFF4C3EE3);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: primaryColor, size: 28),
                ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Distance row
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.textGrey, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          distance,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price and coins row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Price section
                if (discountPrice > 0) ...[
                  Text(
                    '₹${actualPrice.toInt()}',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${discountPrice.toInt()}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E9C68),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F8ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${((1 - discountPrice / actualPrice) * 100).toInt()}% OFF',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF2E9C68),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else if (actualPrice > 0) ...[
                  Text(
                    '₹${actualPrice.toInt()}',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FREE',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E9C68),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const Spacer(),
                // Coins section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEDF4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUnlocked ? Icons.check_circle : Icons.monetization_on,
                        color: const Color(0xFFA61E4D),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isUnlocked ? 'Unlocked' : '$coinsRequired Coins',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF671B36),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Action button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: actionColor == const Color(0xFF7DE4FF) ? const Color(0xFF1B6C82) : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                actionText,
                style: GoogleFonts.poppins(
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
}
