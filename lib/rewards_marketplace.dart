import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';
import 'category_details_screen.dart';

class RewardsMarketplace extends StatefulWidget {
  const RewardsMarketplace({super.key});

  @override
  State<RewardsMarketplace> createState() => _RewardsMarketplaceState();
}

class _RewardsMarketplaceState extends State<RewardsMarketplace> {
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color primaryColor = const Color(0xFF0A3D62);
  final Color coinPillColor = const Color(0xFFE6EBF0);

  // All available categories
  final List<Map<String, dynamic>> _allCategories = [
    {
      'icon': Icons.restaurant, 
      'label': 'Food & Beverage', 
      'subcategories': ['All', 'Restaurants', 'Cafes', 'Cloud Kitchens', 'Fast Food Outlets', 'Bakeries', 'Sweet Shops', 'Juice Centers', 'Ice Cream Parlors', 'Bars & Pubs', 'Fine Dining', 'Food Trucks', 'Catering Services', 'Mess / Tiffin Services', 'Street Food Vendors', 'Other']
    },
    {
      'icon': Icons.spa, 
      'label': 'Salons & Wellness', 
      'subcategories': ['All', 'Hair Salons', 'Beauty Parlors', 'Spa & Massage Centers', 'Skin Clinics', 'Nail Studios', 'Tattoo Studios', 'Fitness Centers / Gyms', 'Yoga Studios', 'Zumba / Dance Fitness', 'Weight Loss Centers', 'Ayurvedic Centers', 'Physiotherapy Clinics', 'Personal Trainers', 'Grooming Studios', 'Other']
    },
    {
      'icon': Icons.shopping_bag, 
      'label': 'Retail & Shopping', 
      'subcategories': ['All', 'Clothing Stores', 'Footwear Shops', 'Electronics Stores', 'Mobile Shops', 'Grocery Stores (Kirana)', 'Supermarkets', 'Furniture Stores', 'Jewellery Shops', 'Stationery Stores', 'Gift Shops', 'Cosmetic Stores', 'Toy Shops', 'Book Stores', 'Sports Equipment Stores', 'Other']
    },
    {
      'icon': Icons.local_hospital, 
      'label': 'Healthcare', 
      'subcategories': ['All', 'Hospitals', 'Clinics', 'Diagnostic Centers', 'Pharmacies', 'Dental Clinics', 'Eye Care Centers', 'Physiotherapy Centers', 'Veterinary Clinics', 'Home Healthcare Services', 'Nursing Homes', 'Mental Health Clinics', 'Blood Banks', 'Ambulance Services', 'Other']
    },
    {
      'icon': Icons.school, 
      'label': 'Education & Training', 
      'subcategories': ['All', 'Schools', 'Colleges', 'Coaching Institutes', 'Online Learning Platforms', 'Skill Development Centers', 'Computer Training Institutes', 'Language Institutes', 'Music Schools', 'Dance Academies', 'Tuition Centers', 'Competitive Exam Coaching', 'Corporate Training', 'Other']
    },
    {
      'icon': Icons.construction, 
      'label': 'Construction & Real Estate', 
      'subcategories': ['All', 'Builders', 'Contractors', 'Interior Designers', 'Architects', 'Real Estate Agencies', 'Property Dealers', 'Construction Material Suppliers', 'Civil Engineers', 'Renovation Services', 'Plumbing Services', 'Electrical Contractors', 'Painting Contractors', 'Other']
    },
    {
      'icon': Icons.local_shipping, 
      'label': 'Transport & Logistics', 
      'subcategories': ['All', 'Cab Services', 'Trucking Services', 'Delivery Services', 'Packers & Movers', 'Warehousing', 'Courier Services', 'Bike Rentals', 'Car Rentals', 'Freight Forwarding', 'Logistics Aggregators', 'Cold Storage', 'Other']
    },
    {
      'icon': Icons.agriculture, 
      'label': 'Agriculture & Allied', 
      'subcategories': ['All', 'Farming', 'Dairy', 'Poultry', 'Fisheries', 'Organic Farming', 'Agro Processing', 'Fertilizer Suppliers', 'Seed Suppliers', 'Farm Equipment Dealers', 'Nurseries', 'Animal Husbandry', 'Beekeeping', 'Other']
    },
    {
      'icon': Icons.factory, 
      'label': 'Manufacturing', 
      'subcategories': ['All', 'Textile Manufacturing', 'Food Processing Units', 'Leather Goods', 'Chemical Manufacturing', 'Pharmaceutical Manufacturing', 'Electronics Manufacturing', 'Furniture Manufacturing', 'Plastic Products', 'Metal Fabrication', 'Packaging Units', 'Handicrafts', 'Paper Products', 'Other']
    },
    {
      'icon': Icons.work, 
      'label': 'Professional Services', 
      'subcategories': ['All', 'Legal Services', 'Accounting / CA Firms', 'Consulting Firms', 'Marketing Agencies', 'IT Services', 'Recruitment Agencies', 'Event Management', 'Security Services', 'Facility Management', 'Business Consultants', 'Freelancers', 'Outsourcing Services', 'Other']
    },
    {
      'icon': Icons.hotel, 
      'label': 'Hospitality & Tourism', 
      'subcategories': ['All', 'Hotels', 'Resorts', 'Homestays', 'Travel Agencies', 'Tour Operators', 'Event Planners', 'Wedding Planners', 'Holiday Packages', 'Adventure Tourism', 'Ticket Booking Services', 'Cruise Services', 'Other']
    },
    {
      'icon': Icons.palette, 
      'label': 'Creative & Media', 
      'subcategories': ['All', 'Photography Studios', 'Video Production', 'Animation Studios', 'Graphic Design', 'Content Creation', 'Digital Marketing Agencies', 'Fashion Designers', 'Interior Designers', 'Printing Services', 'Advertising Agencies', 'Film Production', 'Other']
    },
    {
      'icon': Icons.eco, 
      'label': 'Energy & Environment', 
      'subcategories': ['All', 'Solar Energy Providers', 'EV Charging Stations', 'Waste Management', 'Recycling Units', 'Water Treatment', 'Green Consulting', 'Battery Solutions', 'Wind Energy', 'Environmental Services', 'Other']
    },
    {
      'icon': Icons.computer, 
      'label': 'Technology & Digital', 
      'subcategories': ['All', 'SaaS Companies', 'Mobile App Development', 'Web Development', 'E-commerce Businesses', 'AI/ML Services', 'Cybersecurity Firms', 'Cloud Services', 'Data Analytics', 'IT Support Services', 'Blockchain Services', 'Other']
    },
    {
      'icon': Icons.home_repair_service, 
      'label': 'Home Services', 
      'subcategories': ['All', 'Cleaning Services', 'Pest Control', 'Plumbing Services', 'Electrical Repairs', 'Appliance Repair', 'Car Washing', 'Home Painting', 'Carpentry', 'Security Services', 'Laundry Services', 'Maid Services', 'Other']
    },
    {
      'icon': Icons.storefront, 
      'label': 'Home-Based & Small Business', 
      'subcategories': ['All', 'Tailoring', 'Handmade Products', 'Candle Making', 'Home Bakery', 'Homemade Food', 'Handicrafts', 'Freelancers', 'Online Sellers', 'Boutique Businesses', 'Resellers', 'Other']
    },
  ];

  bool _showAllCategories = false;
  List<Map<String, dynamic>>? _fetchedOffers;
  bool _isLoadingOffers = true;

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    try {
      final response = await http.get(Uri.parse('https://froofly-backend.onrender.com/offer/explore'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _fetchedOffers = data.cast<Map<String, dynamic>>();
          _isLoadingOffers = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error fetching offers: $e');
    }
    
    // Fallback or failed state
    if (mounted) {
      setState(() {
        _isLoadingOffers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildCategoriesSection(),
            const SizedBox(height: 30),
            _buildAllOffersSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAllOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'All Deals & Offers',
                style: GoogleFonts.poppins(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  color: coinPillColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _isLoadingOffers
            ? const Center(child: CircularProgressIndicator())
            : _fetchedOffers != null && _fetchedOffers!.isNotEmpty
              ? Column(
                  children: _fetchedOffers!.map((offer) {
                    final merchant = offer['merchant'] ?? {};
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildDealCard(
                        imagePath: merchant['shopLogo']?.isNotEmpty == true && merchant['shopLogo'].toString().startsWith('http')
                            ? merchant['shopLogo'] 
                            : 'assets/images/wellness.png',
                        title: merchant['businessName'] ?? offer['title'] ?? 'Store',
                        subtitle: offer['title'] ?? 'Special Offer',
                        badgeText: offer['offerType'] == 'PERCENTAGE' ? '${offer['maxDiscount']}% OFF' : 'EXCLUSIVE',
                        badgeColor: AppTheme.magenta,
                        iconData: Icons.local_offer,
                        footerText: offer['distance'] ?? 'Nearby',
                        coinsRequired: offer['coinsRequired'] ?? 100,
                        isUnlocked: false,
                        isNetworkImage: merchant['shopLogo']?.isNotEmpty == true && merchant['shopLogo'].toString().startsWith('http'),
                      ),
                    );
                  }).toList(),
                )
              : Column(
                  children: [
                    _buildDealCard(
                      imagePath: 'assets/images/wellness.png',
                      title: 'Glow Spa',
                      subtitle: '20% Off Massage',
                      badgeText: 'EXCLUSIVE DROP',
                      badgeColor: AppTheme.magenta,
                      iconData: Icons.spa,
                      footerText: 'EXPIRES IN 3 DAYS',
                      coinsRequired: 200,
                      isUnlocked: false,
                    ),
                    const SizedBox(height: 16),
                    _buildDealCard(
                      imagePath: 'assets/images/burger.png',
                      title: 'Burger King',
                      subtitle: 'BOGO Whopper',
                      badgeText: 'FLASH DEAL',
                      badgeColor: const Color(0xFF008080),
                      iconData: Icons.lunch_dining,
                      footerText: 'REDEEM NEARBY',
                      coinsRequired: 100,
                      isUnlocked: false,
                    ),
                    const SizedBox(height: 16),
                    _buildDealCard(
                      imagePath: 'assets/images/coffee.png',
                      title: 'CVS Pharmacy',
                      subtitle: '\$5 Off \$25',
                      badgeText: '',
                      badgeColor: Colors.transparent,
                      iconData: Icons.medical_services,
                      footerText: 'VALID TILL SUNDAY',
                      coinsRequired: 50,
                      isUnlocked: true,
                    ),
                  ],
                ),
        ),
      ],
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
    bool isNetworkImage = false,
  }) {
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
                isNetworkImage 
                  ? Image.network(
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
                    )
                  : Image.asset(
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
                              const Icon(Icons.monetization_on, size: 12, color: Color(0xFFFFD700)),
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Explore',
        style: GoogleFonts.poppins(
          color: primaryColor,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: coinPillColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.attach_money, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 4),
              Text(
                '2,450',
                style: GoogleFonts.poppins(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.notifications, color: primaryColor),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final displayedCategories = _showAllCategories ? _allCategories : _allCategories.take(4).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: GoogleFonts.poppins(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllCategories = !_showAllCategories;
                  });
                },
                child: Text(
                  _showAllCategories ? 'SHOW LESS' : 'VIEW ALL',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _showAllCategories
            ? _buildCategoriesGrid(displayedCategories)
            : SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: displayedCategories
                      .map((c) => _buildCategoryItem(c['icon'] as IconData, c['label'] as String, c['subcategories'] as List<String>))
                      .toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildCategoriesGrid(List<Map<String, dynamic>> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final c = categories[index];
          return _buildCategoryGridItem(c['icon'] as IconData, c['label'] as String, c['subcategories'] as List<String>);
        },
      ),
    );
  }

  Widget _buildCategoryGridItem(IconData icon, String label, List<String> subcategories) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsScreen(categoryName: label, subcategories: subcategories),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppTheme.textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, List<String> subcategories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailsScreen(categoryName: label, subcategories: subcategories),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}
