import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'widgets/deal_card.dart';
import 'balance_manager.dart';

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
      discountColor: const Color(0xFF0A3D62),
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
      badgeColor: const Color(0xFF0A3D62),
      discountColor: const Color(0xFF0A3D62),
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
      discountColor: const Color(0xFF0A3D62),
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
      discountColor: const Color(0xFF0A3D62),
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
      badgeColor: const Color(0xFF0A3D62),
      discountColor: const Color(0xFF0A3D62),
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

  Future<void> _unlockDeal(_DealData deal) async {
    final int coinsRequired = 100;
    final currentBal = BalanceManager.instance.balance.value;

    if (currentBal < coinsRequired) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Insufficient Coins',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.classicNavy),
          ),
          content: Text(
            'You need $coinsRequired coins to unlock this deal. You currently have $currentBal coins.\n\nUpload payment screenshots on the Challenges page to earn more coins!',
            style: GoogleFonts.poppins(color: AppTheme.textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.poppins(color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Unlock Offer?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
        content: Text(
          'Do you want to unlock "${deal.brandName} - ${deal.discountText}" for $coinsRequired coins?',
          style: GoogleFonts.poppins(color: AppTheme.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Unlock', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final int newBalance = currentBal - coinsRequired;
    await BalanceManager.instance.updateBalance(newBalance);

    final int len = deal.brandName.length;
    final String brandSub = deal.brandName.substring(0, len < 3 ? len : 3).toUpperCase();
    final String couponCode = 'FRFL-${brandSub}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F8ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.celebration, color: Color(0xFF2E9C68), size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Congratulations!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You have successfully unlocked "${deal.brandName} - ${deal.discountText}"!\n\nUse Coupon Code below at the counter:\n',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  couponCode,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.magenta,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E9C68),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Awesome!',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deals = _filteredDeals;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
                : PageView.builder(
                    scrollDirection: Axis.vertical,
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
                        onUnlockPressed: () => _unlockDeal(d),
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
      backgroundColor: const Color(0xFFF9F9F9),
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
        ValueListenableBuilder<int>(
          valueListenable: BalanceManager.instance.balance,
          builder: (context, currentBalance, child) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightLavender,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: AppTheme.primaryPurple, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    currentBalance.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
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
