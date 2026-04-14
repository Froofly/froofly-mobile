import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'widgets/deal_card.dart';

class _DealData {
  final String imagePath;
  final String brandName;
  final String subtitle;
  final String discountText;
  final String discountDesc;
  final String timeLeft;
  final String claimed;
  final String badgeText;
  final Color badgeColor;
  final Color discountColor;
  final String category; // 'Food', 'Retail', 'Health', 'Beauty', 'Travel', 'Entertainment'

  const _DealData({
    required this.imagePath,
    required this.brandName,
    required this.subtitle,
    required this.discountText,
    required this.discountDesc,
    required this.timeLeft,
    required this.claimed,
    required this.badgeText,
    required this.badgeColor,
    required this.discountColor,
    required this.category,
  });
}

class HomeDealsTab extends StatefulWidget {
  const HomeDealsTab({super.key});

  @override
  State<HomeDealsTab> createState() => _HomeDealsTabState();
}

class _HomeDealsTabState extends State<HomeDealsTab> {
  final List<String> _categories = [
    'All Deals',
    'Food',
    'Retail',
    'Health',
    'Beauty',
    'Travel',
    'Entertainment',
  ];
  int _selectedCategoryIndex = 0;

  // All deals data
  final List<_DealData> _allDeals = [
    // Food deals
    _DealData(
      imagePath: 'assets/images/coffee.png',
      brandName: 'Starbucks',
      subtitle: 'Gourmet Coffee & Snacks',
      discountText: '50% OFF',
      discountDesc: 'Sitewide for Froofly Gold Members',
      timeLeft: '4H LEFT',
      claimed: '1.2K CLAIMED',
      badgeText: 'TRENDING NOW',
      badgeColor: AppTheme.primaryPurple,
      discountColor: const Color(0xFF4C3EE3),
      category: 'Food',
    ),
    _DealData(
      imagePath: 'assets/images/burger.png',
      brandName: 'Burger King',
      subtitle: 'Flame-Grilled Goodness',
      discountText: 'BOGO FREE',
      discountDesc: 'On all Whopper® Junior Meals',
      timeLeft: '12H LEFT',
      claimed: '840 CLAIMED',
      badgeText: 'FLASH DEAL',
      badgeColor: AppTheme.magenta,
      discountColor: AppTheme.magenta,
      category: 'Food',
    ),
    _DealData(
      imagePath: 'assets/images/coffee.png',
      brandName: 'Pizza Hut',
      subtitle: 'Fresh Pizzas & Sides',
      discountText: '30% OFF',
      discountDesc: 'On all Large Pizzas',
      timeLeft: '6H LEFT',
      claimed: '620 CLAIMED',
      badgeText: 'HOT DEAL',
      badgeColor: const Color(0xFFE85D04),
      discountColor: const Color(0xFFE85D04),
      category: 'Food',
    ),
    // Retail deals
    _DealData(
      imagePath: 'assets/images/wellness.png',
      brandName: 'Nike Store',
      subtitle: 'Premium Sportswear',
      discountText: '\$20 OFF',
      discountDesc: 'On all Running Shoes above \$100',
      timeLeft: '2 DAYS LEFT',
      claimed: '980 CLAIMED',
      badgeText: 'MEMBER EXCLUSIVE',
      badgeColor: const Color(0xFF4C3EE3),
      discountColor: const Color(0xFF4C3EE3),
      category: 'Retail',
    ),
    _DealData(
      imagePath: 'assets/images/burger.png',
      brandName: 'Target',
      subtitle: 'Everything You Need',
      discountText: '15% OFF',
      discountDesc: 'Entire Purchase with Circle+',
      timeLeft: '5 DAYS LEFT',
      claimed: '1.5K CLAIMED',
      badgeText: 'TOP PICK',
      badgeColor: const Color(0xFF7A8FF6),
      discountColor: const Color(0xFF4C3EE3),
      category: 'Retail',
    ),
    // Health deals
    _DealData(
      imagePath: 'assets/images/wellness.png',
      brandName: 'Wellness Pharm',
      subtitle: 'Premium Health & Vitamins',
      discountText: '20% OFF',
      discountDesc: 'On all Immune Support Packs',
      timeLeft: '2 DAYS LEFT',
      claimed: '450 CLAIMED',
      badgeText: 'NEW ARRIVAL',
      badgeColor: const Color(0xFF7A8FF6),
      discountColor: const Color(0xFF4C3EE3),
      category: 'Health',
    ),
    _DealData(
      imagePath: 'assets/images/coffee.png',
      brandName: 'CVS Pharmacy',
      subtitle: 'Your Health Partner',
      discountText: '\$5 OFF',
      discountDesc: 'On purchases of \$25 or more',
      timeLeft: '3 DAYS LEFT',
      claimed: '320 CLAIMED',
      badgeText: 'EVERYDAY DEAL',
      badgeColor: const Color(0xFF2E9C68),
      discountColor: const Color(0xFF2E9C68),
      category: 'Health',
    ),
    // Beauty deals
    _DealData(
      imagePath: 'assets/images/wellness.png',
      brandName: 'Glow Spa',
      subtitle: 'Premium Spa & Salon',
      discountText: '40% OFF',
      discountDesc: 'Full Body Massage + Facial combo',
      timeLeft: '1 DAY LEFT',
      claimed: '750 CLAIMED',
      badgeText: 'EXCLUSIVE',
      badgeColor: AppTheme.magenta,
      discountColor: AppTheme.magenta,
      category: 'Beauty',
    ),
    // Travel deals
    _DealData(
      imagePath: 'assets/images/burger.png',
      brandName: 'Uber',
      subtitle: 'Ride Anywhere',
      discountText: '25% OFF',
      discountDesc: 'On your next 3 rides',
      timeLeft: '8H LEFT',
      claimed: '2.1K CLAIMED',
      badgeText: 'LIMITED TIME',
      badgeColor: const Color(0xFF4C3EE3),
      discountColor: const Color(0xFF4C3EE3),
      category: 'Travel',
    ),
    // Entertainment deals
    _DealData(
      imagePath: 'assets/images/coffee.png',
      brandName: 'AMC Theatres',
      subtitle: 'Movies & Entertainment',
      discountText: 'BUY 1 GET 1',
      discountDesc: 'On all movie tickets this weekend',
      timeLeft: '3 DAYS LEFT',
      claimed: '1.8K CLAIMED',
      badgeText: 'WEEKEND SPECIAL',
      badgeColor: const Color(0xFFA61E4D),
      discountColor: const Color(0xFFA61E4D),
      category: 'Entertainment',
    ),
  ];

  List<_DealData> get _filteredDeals {
    if (_selectedCategoryIndex == 0) return _allDeals;
    final selectedCategory = _categories[_selectedCategoryIndex];
    return _allDeals.where((d) => d.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final deals = _filteredDeals;
    return Scaffold(
      backgroundColor: const Color(0xFFFCF6FB),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategoryList(),
          Expanded(
            child: deals.isEmpty
                ? Center(
                    child: Text(
                      'No deals available',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                        .copyWith(bottom: 100),
                    itemCount: deals.length,
                    itemBuilder: (context, index) {
                      final d = deals[index];
                      return DealCard(
                        imagePath: d.imagePath,
                        brandName: d.brandName,
                        subtitle: d.subtitle,
                        discountText: d.discountText,
                        discountDesc: d.discountDesc,
                        timeLeft: d.timeLeft,
                        claimed: d.claimed,
                        badgeText: d.badgeText,
                        badgeColor: d.badgeColor,
                        discountColor: d.discountColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFCF6FB),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Froofly',
        style: GoogleFonts.poppins(
          color: AppTheme.primaryPurple,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          letterSpacing: 1.0,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.lightLavender,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on, color: AppTheme.primaryPurple, size: 16),
              const SizedBox(width: 4),
              Text(
                '1,250',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: AppTheme.primaryPurple),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.magenta : AppTheme.lightLavender,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : AppTheme.textDark.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
