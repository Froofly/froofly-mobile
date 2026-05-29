import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryName;
  final List<String> subcategories;

  const CategoryDetailsScreen({super.key, required this.categoryName, required this.subcategories});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  String _selectedSubcategory = 'All';

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF9F9F9);
    final primaryColor = const Color(0xFF0A3D62);

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
          '${widget.categoryName} Offers',
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
      body: Column(
        children: [
          // Subcategories Filter
          if (widget.subcategories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.subcategories.length,
                itemBuilder: (context, index) {
                  final sub = widget.subcategories[index];
                  final isSelected = sub == _selectedSubcategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSubcategory = sub;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? primaryColor : AppTheme.textGrey.withOpacity(0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        sub,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedSubcategory == 'All') ...[
                    Text(
                      'Top Rated in ${widget.categoryName}',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHeroCard(),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedSubcategory == 'All' ? 'Available Offers' : '$_selectedSubcategory Offers',
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
          ),
        ],
      ),
    );
  }

  List<Widget> _getOffersList() {
    if (widget.categoryName.contains('Food')) {
      return [
        _buildDealCard(
          imagePath: 'assets/images/burger.png',
          title: 'Burger King',
          subtitle: 'BOGO Premium Meal',
          badgeText: 'FLASH DEAL',
          badgeColor: const Color(0xFF008080),
          iconData: Icons.lunch_dining,
          footerText: '0.8 KM AWAY',
          coinsRequired: 150,
          isUnlocked: false,
        ),
        const SizedBox(height: 16),
        _buildDealCard(
          imagePath: 'assets/images/coffee.png',
          title: 'Starbucks',
          subtitle: 'Free Pastry',
          badgeText: 'UNLOCKED',
          badgeColor: const Color(0xFF0A3D62),
          iconData: Icons.coffee,
          footerText: '1.2 KM AWAY',
          coinsRequired: 0,
          isUnlocked: true,
        ),
        const SizedBox(height: 16),
        _buildDealCard(
          imagePath: 'assets/images/burger.png',
          title: 'Pizza Hut',
          subtitle: '30% Off Large Pizza',
          badgeText: '',
          badgeColor: Colors.transparent,
          iconData: Icons.local_pizza,
          footerText: '2.5 KM AWAY',
          coinsRequired: 120,
          isUnlocked: false,
        ),
      ];
    } else if (widget.categoryName.contains('Retail')) {
      return [
        _buildDealCard(
          imagePath: 'assets/images/wellness.png',
          title: 'Nike Store',
          subtitle: '\$20 Off Shoes',
          badgeText: 'HOT DEAL',
          badgeColor: const Color(0xFFD4AF37),
          iconData: Icons.snowshoeing,
          footerText: '3.1 KM AWAY',
          coinsRequired: 300,
          isUnlocked: false,
        ),
        const SizedBox(height: 16),
        _buildDealCard(
          imagePath: 'assets/images/wellness.png',
          title: 'Target',
          subtitle: '15% Entire Purchase',
          badgeText: 'UNLOCKED',
          badgeColor: const Color(0xFF0A3D62),
          iconData: Icons.local_mall,
          footerText: '1.0 KM AWAY',
          coinsRequired: 0,
          isUnlocked: true,
        ),
      ];
    } else if (widget.categoryName.contains('Wellness') || widget.categoryName.contains('Fitness')) {
      return [
        _buildDealCard(
          imagePath: 'assets/images/wellness.png',
          title: 'Anytime Fitness',
          subtitle: '1 Free Month Trial',
          badgeText: 'EXCLUSIVE DROP',
          badgeColor: AppTheme.magenta,
          iconData: Icons.fitness_center,
          footerText: '1.5 KM AWAY',
          coinsRequired: 400,
          isUnlocked: false,
        ),
        const SizedBox(height: 16),
        _buildDealCard(
          imagePath: 'assets/images/wellness.png',
          title: 'Yoga Studio',
          subtitle: '1 Free Class',
          badgeText: '',
          badgeColor: Colors.transparent,
          iconData: Icons.self_improvement,
          footerText: '0.6 KM AWAY',
          coinsRequired: 100,
          isUnlocked: false,
        ),
      ];
    }

    // Default 
    return [
      _buildDealCard(
        imagePath: 'assets/images/wellness.png',
        title: 'Aura Service',
        subtitle: '15% Off Total Bill',
        badgeText: 'LIMITED TIME',
        badgeColor: const Color(0xFF0A3D62),
        iconData: Icons.star,
        footerText: '0.5 KM AWAY',
        coinsRequired: 100,
        isUnlocked: false,
      ),
      const SizedBox(height: 16),
      _buildDealCard(
        imagePath: 'assets/images/wellness.png',
        title: 'Premium Studio',
        subtitle: 'Free Consultation',
        badgeText: 'UNLOCKED',
        badgeColor: const Color(0xFF0A3D62),
        iconData: Icons.verified,
        footerText: '1.1 KM AWAY',
        coinsRequired: 0,
        isUnlocked: true,
      ),
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
                        backgroundColor: const Color(0xFF0A3D62),
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

  Widget _buildDealCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData iconData,
    required String footerText,
    required int coinsRequired,
    required bool isUnlocked,
  }) {
    final primaryColor = const Color(0xFF0A3D62);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                    );
                  },
                ),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                if (badgeText.isNotEmpty)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
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
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    footerText,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUnlocked ? primaryColor : const Color(0xFFFF4757),
                    foregroundColor: Colors.white,
                    elevation: isUnlocked ? 0 : 4,
                    shadowColor: const Color(0xFFFF4757).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isUnlocked) ...[
                        const Icon(Icons.lock_outline, size: 16),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        isUnlocked ? 'Claim' : 'Unlock',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (!isUnlocked) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '$coinsRequired',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.stars, size: 12, color: Color(0xFFFFD700)),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
