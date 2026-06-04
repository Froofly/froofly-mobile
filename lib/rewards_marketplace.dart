import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'theme.dart';
import 'category_details_screen.dart';
import 'balance_manager.dart';

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
  Timer? _refreshTimer;

  double _latitude = 12.9716; 
  double _longitude = 77.5946;
  String _locationName = 'Bengaluru (MG Road)';

  String? _userId;
  Set<String> _claimedOfferIds = {};

  final List<Map<String, dynamic>> _mockLocations = [
    {
      'name': 'Bengaluru (MG Road)',
      'lat': 12.9716,
      'lng': 77.5946,
    },
    {
      'name': 'Mumbai (Marine Drive)',
      'lat': 19.0760,
      'lng': 72.8777,
    },
    {
      'name': 'Delhi (Connaught Place)',
      'lat': 28.6139,
      'lng': 77.2090,
    },
    {
      'name': 'Dominate Proximity (0.2 km)',
      'lat': 12.9725,
      'lng': 77.5955,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _fetchOffers();
    });
    BalanceManager.instance.refreshTrigger.addListener(_onRefreshTriggered);
  }

  @override
  void dispose() {
    BalanceManager.instance.refreshTrigger.removeListener(_onRefreshTriggered);
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _onRefreshTriggered() {
    if (mounted) {
      _fetchClaims();
      _fetchOffers();
    }
  }

  Future<void> _fetchDeviceLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 4),
        );
      }

      if (mounted) {
        setState(() {
          _latitude = position!.latitude;
          _longitude = position.longitude;
          _locationName = 'My Location (GPS)';
        });
      }
    } catch (e) {
      debugPrint('Error fetching device location: $e');
    }
  }

  Future<void> _loadUserAndData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    final coins = prefs.getInt('currentBalance') ?? 0;
    
    if (coins > 0) {
      BalanceManager.instance.updateBalance(coins);
    }

    // Prioritize cached locations stored by the home screen tracker
    final double? cachedLat = prefs.getDouble('latitude');
    final double? cachedLng = prefs.getDouble('longitude');
    if (cachedLat != null && cachedLng != null) {
      _latitude = cachedLat;
      _longitude = cachedLng;
      _locationName = 'My Location (GPS)';
    } else {
      await _fetchDeviceLocation();
    }

    await Future.wait([
      _fetchClaims(),
      _fetchOffers(),
    ]);
  }

  Future<void> _fetchClaims() async {
    if (_userId == null) return;
    try {
      final response = await http.get(Uri.parse('https://cuajqhm529.execute-api.ap-south-1.amazonaws.com/offer/claims/$_userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Set<String> claimedIds = {};
        for (var c in data) {
          if (c['offerId'] != null) {
            claimedIds.add(c['offerId'].toString());
          }
        }
        setState(() {
          _claimedOfferIds = claimedIds;
        });
      }
    } catch (e) {
      debugPrint('Error fetching claims: $e');
    }
  }

  Future<void> _fetchOffers() async {
    if (!mounted) return;
    setState(() {
      _isLoadingOffers = true;
    });

    try {
      final url = 'https://cuajqhm529.execute-api.ap-south-1.amazonaws.com/offer/explore?lat=$_latitude&lng=$_longitude';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _fetchedOffers = data.cast<Map<String, dynamic>>();
            _isLoadingOffers = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Error fetching offers: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingOffers = false;
      });
    }
  }

  void _showLocationSwitcher() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Simulate Travel / Change Location',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Recalculates distances and priority boosts in real-time based on customer travels.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // GPS option
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _locationName == 'My Location (GPS)' ? primaryColor.withOpacity(0.05) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _locationName == 'My Location (GPS)' ? primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.my_location,
                    color: _locationName == 'My Location (GPS)' ? primaryColor : AppTheme.textGrey,
                  ),
                  title: Text(
                    'My Location (GPS)',
                    style: GoogleFonts.poppins(
                      fontWeight: _locationName == 'My Location (GPS)' ? FontWeight.bold : FontWeight.w500,
                      color: _locationName == 'My Location (GPS)' ? primaryColor : AppTheme.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Use device real-time GPS coordinates',
                    style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textGrey),
                  ),
                  trailing: _locationName == 'My Location (GPS)'
                      ? Icon(Icons.check_circle, color: primaryColor)
                      : null,
                  onTap: () async {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    await _fetchDeviceLocation();
                    Navigator.pop(context); // close progress indicator
                    _fetchOffers();
                  },
                ),
              ),
              ..._mockLocations.map((loc) {
                final bool isSelected = _locationName == loc['name'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: isSelected ? primaryColor : AppTheme.textGrey,
                    ),
                    title: Text(
                      loc['name'],
                      style: GoogleFonts.poppins(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? primaryColor : AppTheme.textDark,
                      ),
                    ),
                    subtitle: Text(
                      'Lat: ${loc['lat']}, Lng: ${loc['lng']}',
                      style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textGrey),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: primaryColor)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _latitude = loc['lat'];
                        _longitude = loc['lng'];
                        _locationName = loc['name'];
                      });
                      _fetchOffers();
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showOfferDetails(Map<String, dynamic> offer) {
    final merchant = offer['merchant'] ?? {};
    final String shopLogo = merchant['shopLogo']?.isNotEmpty == true && merchant['shopLogo'].toString().startsWith('http')
        ? merchant['shopLogo']
        : 'assets/images/wellness.png';
    final String merchantName = merchant['businessName'] ?? offer['title'] ?? 'Merchant';
    final String offerTitle = offer['title'] ?? 'Special Deal';
    final String description = offer['description'] ?? 'No description provided.';
    final String offerType = offer['offerType'] ?? 'EXCLUSIVE';
    final int coins = offer['coinsRequired'] ?? 100;
    final List<dynamic> conditions = offer['conditions'] ?? [];
    
    final String road = merchant['addressRoad'] ?? '';
    final String street = merchant['addressStreet'] ?? '';
    final String fullAddress = [road, street].where((s) => s.isNotEmpty).join(', ');
    final String addressText = fullAddress.isNotEmpty ? fullAddress : 'Nearby store location';

    final bool isClaimed = _claimedOfferIds.contains(offer['id']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: shopLogo.startsWith('http')
                        ? Image.network(
                            shopLogo,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                          )
                        : Image.asset(
                            shopLogo,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                          ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              merchantName.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.verified, color: Colors.blue, size: 16),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        offerTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.magenta.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'OFFER TYPE: $offerType',
                          style: GoogleFonts.poppins(
                            color: AppTheme.magenta,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Rules & Conditions',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (conditions.isEmpty)
                        Text(
                          '• Valid on all days.\n• Present QR code at the counter before billing.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                            height: 1.6,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: conditions.map((rule) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(
                                      rule.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppTheme.textGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        'Direction',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.map_outlined, color: primaryColor, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Store Address',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    addressText,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textGrey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isClaimed
                      ? null
                      : () {
                          Navigator.pop(context);
                          _unlockOffer(offer);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClaimed ? const Color(0xFF2E9C68) : primaryColor,
                    disabledBackgroundColor: const Color(0xFF2E9C68),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isClaimed ? Icons.check_circle_outline : Icons.lock_open, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isClaimed ? 'UNLOCKED' : 'UNLOCK OFFER WITH $coins COINS',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      height: 220,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }

  Future<void> _unlockOffer(Map<String, dynamic> offer) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to unlock offers!')),
      );
      return;
    }

    final coins = offer['coinsRequired'] ?? 100;
    final currentBal = BalanceManager.instance.balance.value;
    if (currentBal < coins) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Insufficient Coins', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text(
            'You need $coins coins to unlock this deal. You currently have $currentBal coins.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.poppins(color: AppTheme.textGrey)),
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
        title: Text('Unlock Offer?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor)),
        content: Text(
          'Do you want to unlock "${offer['title']}" for $coins coins?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Unlock', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse('https://cuajqhm529.execute-api.ap-south-1.amazonaws.com/offer/claim/${offer['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': _userId}),
      );

      Navigator.pop(context); 

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final int updatedBalance = data['currentBalance'] ?? (currentBal - coins);

        await BalanceManager.instance.updateBalance(updatedBalance);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('currentBalance', updatedBalance);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully unlocked and added to orders!', style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: const Color(0xFF2E9C68),
          ),
        );

        await _fetchClaims();
        _fetchOffers();
        BalanceManager.instance.triggerRefresh();
      } else {
        final err = json.decode(response.body);
        throw err['message'] ?? 'Claim failed';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unlock offer: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : _fetchedOffers != null && _fetchedOffers!.where((offer) => !_claimedOfferIds.contains(offer['id'])).isNotEmpty
              ? Column(
                  children: _fetchedOffers!
                      .where((offer) => !_claimedOfferIds.contains(offer['id']))
                      .map((offer) {
                    final merchant = offer['merchant'] ?? {};
                    final String offerImg = (offer['images'] != null && (offer['images'] as List).isNotEmpty)
                        ? offer['images'][0]
                        : (merchant['shopLogo']?.isNotEmpty == true && merchant['shopLogo'].toString().startsWith('http')
                            ? merchant['shopLogo']
                            : 'assets/images/wellness.png');
                    
                    final String merchantName = merchant['businessName'] ?? offer['title'] ?? 'Merchant';
                    final String offerTitle = offer['title'] ?? 'Special Deal';
                    final int coins = offer['coinsRequired'] ?? 100;
                    final String distance = offer['distance'] ?? 'Nearby';
                    
                    String expiryText = 'Expires in 3 days';
                    if (offer['validityEnd'] != null) {
                      try {
                        final end = DateTime.parse(offer['validityEnd']);
                        final diff = end.difference(DateTime.now()).inDays;
                        expiryText = diff > 0 ? 'Expires in $diff days' : 'Expires today';
                      } catch (_) {}
                    }
                    
                    final bool isClaimed = _claimedOfferIds.contains(offer['id']);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildDealCard(
                        offer: offer,
                        imagePath: offerImg,
                        title: merchantName,
                        subtitle: offerTitle,
                        badgeText: offer['offerType'] == 'PERCENTAGE' ? '${offer['maxDiscount']}% OFF' : 'EXCLUSIVE',
                        badgeColor: AppTheme.magenta,
                        iconData: Icons.local_offer,
                        footerText: distance,
                        expiryText: expiryText,
                        coinsRequired: coins,
                        isUnlocked: isClaimed,
                        isNetworkImage: offerImg.startsWith('http'),
                      ),
                    );
                  }).toList(),
                )
              : Column(
                  children: [
                    _buildDealCard(
                      offer: const {},
                      imagePath: 'assets/images/wellness.png',
                      title: 'Glow Spa',
                      subtitle: '20% Off Massage',
                      badgeText: 'EXCLUSIVE DROP',
                      badgeColor: AppTheme.magenta,
                      iconData: Icons.spa,
                      footerText: '0.8 km away',
                      expiryText: 'Expires in 3 days',
                      coinsRequired: 200,
                      isUnlocked: false,
                    ),
                    const SizedBox(height: 16),
                    _buildDealCard(
                      offer: const {},
                      imagePath: 'assets/images/burger.png',
                      title: 'Burger King',
                      subtitle: 'BOGO Whopper',
                      badgeText: 'FLASH DEAL',
                      badgeColor: const Color(0xFF008080),
                      iconData: Icons.lunch_dining,
                      footerText: '1.2 km away',
                      expiryText: 'Expires in 2 days',
                      coinsRequired: 100,
                      isUnlocked: false,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildDealCard({
    required Map<String, dynamic> offer,
    required String imagePath,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData iconData,
    required String footerText,
    required String expiryText,
    required int coinsRequired,
    required bool isUnlocked,
    bool isNetworkImage = false,
  }) {
    return GestureDetector(
      onTap: offer.isNotEmpty ? () => _showOfferDetails(offer) : null,
      child: Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          footerText,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expiryText,
                          style: GoogleFonts.poppins(
                            color: AppTheme.magenta,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: isUnlocked
                            ? null
                            : (offer.isNotEmpty ? () => _unlockOffer(offer) : null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUnlocked ? const Color(0xFF2E9C68) : const Color(0xFF00A86B),
                          disabledBackgroundColor: const Color(0xFF2E9C68),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          elevation: isUnlocked ? 0 : 4,
                          shadowColor: const Color(0xFF00A86B).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isUnlocked) ...[
                              const Icon(Icons.lock_outline, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              isUnlocked ? 'Unlocked' : 'Unlock',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
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
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.stars, size: 10, color: Color(0xFFFFD700)),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: offer.isNotEmpty ? () => _showOfferDetails(offer) : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Text(
                            'VIEW MORE',
                            style: GoogleFonts.poppins(
                              color: primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          GestureDetector(
            onTap: _showLocationSwitcher,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 12, color: primaryColor),
                const SizedBox(width: 4),
                Text(
                  _locationName,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 14, color: primaryColor),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ValueListenableBuilder<int>(
          valueListenable: BalanceManager.instance.balance,
          builder: (context, balance, child) {
            return Container(
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
                    child: const Icon(Icons.stars, color: Colors.amber, size: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    balance.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: GoogleFonts.poppins(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 16),
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
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
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
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
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

