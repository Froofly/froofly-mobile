import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';
import 'widgets/deal_card.dart';
import 'balance_manager.dart';

class _DealData {
  final String id;
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
  final int coinsRequired;

  const _DealData({
    required this.id,
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
    required this.coinsRequired,
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
  
  Set<String> _claimedAdIds = {};
  String? _userId;
  double _latitude = 12.9716;
  double _longitude = 77.5946;
  List<dynamic>? _fetchedOffers;
  bool _isLoading = true;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _loadUserContextAndFetch();
    _initLocationTracking();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocationTracking() async {
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

      // Initial fetch of current location
      await _fetchAndUpdateLocation();

      // Setup periodic updates every 10 minutes (600 seconds)
      _locationTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
        debugPrint('Periodic location update triggered...');
        await _fetchAndUpdateLocation();
      });
    } catch (e) {
      debugPrint('Error initializing location tracking: $e');
    }
  }

  Future<void> _fetchAndUpdateLocation() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 4),
        );
      }

      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _latitude = position!.latitude;
        _longitude = position.longitude;
      });

      await prefs.setDouble('latitude', _latitude);
      await prefs.setDouble('longitude', _longitude);
      
      debugPrint('Updated location: $_latitude, $_longitude. Refreshing feeds...');
      
      // Refresh explore and deals with the new coordinates!
      await _fetchOffers();
    } catch (e) {
      debugPrint('Error fetching current location: $e');
    }
  }


  Future<void> _loadUserContextAndFetch() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');
      _latitude = prefs.getDouble('latitude') ?? 12.9716;
      _longitude = prefs.getDouble('longitude') ?? 77.5946;
      
      await Future.wait([
        _fetchClaims(),
        _fetchOffers(),
      ]);
    } catch (e) {
      debugPrint('Error loading user context: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchClaims() async {
    if (_userId == null) return;
    try {
      final response = await http.get(Uri.parse('https://cuajqhm529.execute-api.ap-south-1.amazonaws.com/offer/claims/$_userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Set<String> claimedIds = {};
        for (var c in data) {
          if (c['adId'] != null) {
            claimedIds.add(c['adId'].toString());
          }
        }
        if (mounted) {
          setState(() {
            _claimedAdIds = claimedIds;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching claims: $e');
    }
  }

  Future<void> _fetchOffers() async {
    try {
      String categoryParam = '';
      if (_selectedCategoryIndex > 0) {
        final categoryName = _categories[_selectedCategoryIndex];
        categoryParam = '&category=${Uri.encodeComponent(categoryName)}';
      }
      
      String userParam = '';
      if (_userId != null) {
        userParam = '&userId=$_userId';
      }
      
      final url = 'https://cuajqhm529.execute-api.ap-south-1.amazonaws.com/ad/explore?lat=$_latitude&lng=$_longitude$categoryParam$userParam';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _fetchedOffers = data;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching backend campaigns: $e');
    }
  }

  // All deals data
  final List<_DealData> _allDeals = [
    _DealData(
      id: '',
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
      coinsRequired: 100,
    ),
    _DealData(
      id: '',
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
      coinsRequired: 100,
    ),
    _DealData(
      id: '',
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
      coinsRequired: 100,
    ),
    // Retail deals
    _DealData(
      id: '',
      imagePath: 'assets/images/wellness.png',
      brandName: 'Nike Store',
      subtitle: 'Premium Sportswear',
      discountText: r'$20 OFF',
      discountDesc: 'On all Running Shoes above \$100',
      timeLeft: '2 DAYS LEFT',
      claimed: '980 CLAIMED',
      badgeText: 'MEMBER EXCLUSIVE',
      badgeColor: const Color(0xFF0A3D62),
      discountColor: const Color(0xFF0A3D62),
      category: 'Retail',
      coinsRequired: 100,
    ),
    _DealData(
      id: '',
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
      coinsRequired: 100,
    ),
    // Health deals
    _DealData(
      id: '',
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
      coinsRequired: 100,
    ),
    _DealData(
      id: '',
      imagePath: 'assets/images/coffee.png',
      brandName: 'CVS Pharmacy',
      subtitle: 'Your Health Partner',
      discountText: r'$5 OFF',
      discountDesc: 'On purchases of \$25 or more',
      timeLeft: '3 DAYS LEFT',
      claimed: '320 CLAIMED',
      badgeText: 'EVERYDAY DEAL',
      badgeColor: const Color(0xFF2E9C68),
      discountColor: const Color(0xFF2E9C68),
      category: 'Health',
      coinsRequired: 100,
    ),
    // Beauty deals
    _DealData(
      id: '',
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
      coinsRequired: 100,
    ),
    // Travel deals
    _DealData(
      id: '',
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
      coinsRequired: 100,
    ),
    // Entertainment deals
    _DealData(
      id: '',
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
      coinsRequired: 100,
    ),
  ];

  List<_DealData> get _filteredDeals {
    if (_selectedCategoryIndex == 0) return _allDeals;
    final selectedCategory = _categories[_selectedCategoryIndex];
    return _allDeals.where((d) => d.category == selectedCategory).toList();
  }

  List<Map<String, dynamic>> get _dealsToShow {
    if (_fetchedOffers != null && _fetchedOffers!.isNotEmpty) {
      final realDeals = _fetchedOffers!
          .where((d) => !_claimedAdIds.contains(d['id']))
          .cast<Map<String, dynamic>>()
          .toList();
      if (realDeals.isNotEmpty) {
        return realDeals;
      }
    }
    // If empty/loading/offline, map the local fallback deals
    return _filteredDeals.map((d) => {
      'id': d.id,
      'isMock': true,
      'imagePath': d.imagePath,
      'brandName': d.brandName,
      'subtitle': d.subtitle,
      'discountText': d.discountText,
      'discountDesc': d.discountDesc,
      'timeLeft': d.timeLeft,
      'claimed': d.claimed,
      'badgeText': d.badgeText,
      'badgeColor': d.badgeColor.value,
      'discountColor': d.discountColor.value,
      'coinsRequired': d.coinsRequired,
    }).toList();
  }

  Future<void> _unlockDeal(Map<String, dynamic> deal) async {
    final bool isMock = deal['isMock'] == true;
    final int coinsRequired = deal['coinsRequired'] ?? 100;
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
          'Do you want to unlock "${(deal['brandName'] ?? deal['title'] ?? '')} - ${(deal['discountText'] ?? deal['description'] ?? '')}" for $coinsRequired coins?',
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

    if (isMock) {
      final int newBalance = currentBal - coinsRequired;
      await BalanceManager.instance.updateBalance(newBalance);

      final String brandName = deal['brandName'] ?? '';
      final int len = brandName.length;
      final String brandSub = brandName.substring(0, len < 3 ? len : 3).toUpperCase();
      final String couponCode = 'FRFL-${brandSub}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

      _showCelebrationDialog(deal['brandName'] ?? '', deal['discountText'] ?? '', couponCode);
    } else {
      // Backend unlock!
      if (_userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to unlock offers!')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final response = await http.post(
          Uri.parse('https://cuajqhm529.execute-api.ap-south-1.amazonaws.com/ad/claim/${deal['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'userId': _userId}),
        );

        Navigator.pop(context); // pop loading spinner

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          final int updatedBalance = data['currentBalance'] ?? (currentBal - coinsRequired);

          await BalanceManager.instance.updateBalance(updatedBalance);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('currentBalance', updatedBalance);

          final String couponCode = 'FRFL-${deal['id'].toString().substring(deal['id'].toString().length - 8).toUpperCase()}';
          
          final String brand = deal['merchant']?['businessName'] ?? deal['title'] ?? 'Merchant';
          final String title = deal['title'] ?? 'Unlocked Deal';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully unlocked and added to orders!', style: GoogleFonts.poppins(color: Colors.white)),
              backgroundColor: const Color(0xFF2E9C68),
            ),
          );
          
          // Re-fetch claims and offers to update claim state if needed
          await _fetchClaims();
          _fetchOffers();
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
  }

  void _showCelebrationDialog(String brand, String offerTitle, String couponCode) {
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
                'You have successfully unlocked "$brand - $offerTitle"!\n\nUse Coupon Code below at the counter:\n',
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
    final deals = _dealsToShow;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : deals.isEmpty
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
                          final bool isMock = d['isMock'] == true;
                          
                          final String imagePath = isMock 
                              ? (d['imagePath'] ?? 'assets/images/wellness.png')
                              : (d['images'] != null && (d['images'] as List).isNotEmpty
                                  ? d['images'][0].toString()
                                  : (d['merchant'] != null &&
                                         d['merchant']['shopLogo'] != null &&
                                         d['merchant']['shopLogo'].toString().startsWith('http')
                                      ? d['merchant']['shopLogo'].toString()
                                      : 'assets/images/wellness.png'));
                          
                          final String brandName = isMock 
                              ? (d['brandName'] ?? 'Merchant')
                              : (d['merchant']?['businessName'] ?? d['title'] ?? 'Merchant');

                          final String rawSubtitle = isMock
                               ? (d['subtitle'] ?? '')
                               : (d['description'] ?? 'Exclusive Drop');
                           final String subtitle = rawSubtitle.startsWith('Campaign Type:')
                               ? 'Exclusive Deal available for Froofly members.'
                               : rawSubtitle;

                          final String discountText = isMock
                              ? (d['discountText'] ?? '')
                              : (d['offerType'] == 'PERCENTAGE'
                                  ? '${d['discountValue']}% OFF'
                                  : (d['offerType'] == 'FLAT_DISCOUNT'
                                      ? '\$${d['discountValue']} OFF'
                                      : 'EXCLUSIVE'));

                          final String discountDesc = isMock
                              ? (d['discountDesc'] ?? '')
                              : (d['title'] ?? 'Special Deal');

                          String timeLeft = '3 DAYS LEFT';
                          if (isMock) {
                            timeLeft = d['timeLeft'] ?? '3 DAYS LEFT';
                          } else if (d['campaignEndDate'] != null) {
                            try {
                              final end = DateTime.parse(d['campaignEndDate']);
                              final diff = end.difference(DateTime.now()).inDays;
                              timeLeft = diff > 0 ? '$diff DAYS LEFT' : 'TODAY';
                            } catch (_) {}
                          }

                          final String claimed = isMock
                              ? (d['claimed'] ?? '0 CLAIMED')
                              : ('${d['totalClaims'] ?? 0} CLAIMED');

                          final String badgeText = isMock
                              ? (d['badgeText'] ?? '')
                              : (d['offerType'] == 'PERCENTAGE' ? 'PERCENTAGE OFF' : 'EXCLUSIVE');

                          final Color badgeColor = isMock
                              ? Color(d['badgeColor'] ?? AppTheme.primaryPurple.value)
                              : AppTheme.magenta;

                          final Color discountColor = isMock
                              ? Color(d['discountColor'] ?? AppTheme.primaryPurple.value)
                              : const Color(0xFF0A3D62);

                          final bool isExternal = isMock
                              ? false
                              : (d['campaignType'] == 'Leads' || d['campaignType'] == 'Promotion');

                          final String? targetLink = isMock ? null : d['linkUrl'];
                          
                          final bool isUnlocked = isMock ? false : _claimedAdIds.contains(d['id']);
                          
                          final String distanceVal = isMock
                              ? (d['distance'] ?? '0.8 mi')
                              : (d['distance'] ?? 'Nearby');

                          return DealCard(
                            imagePath: imagePath,
                            brandName: brandName,
                            subtitle: subtitle,
                            discountText: discountText,
                            discountDesc: discountDesc,
                            timeLeft: timeLeft,
                            claimed: claimed,
                            badgeText: badgeText,
                            badgeColor: badgeColor,
                            discountColor: discountColor,
                            distance: distanceVal,
                            onUnlockPressed: () => _unlockDeal(d),
                            isNetworkImage: !isMock && imagePath.startsWith('http'),
                            isExternalLink: isExternal,
                            linkUrl: targetLink,
                            isUnlocked: isUnlocked,
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
        const SizedBox(width: 16),
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
                _isLoading = true;
              });
              _fetchOffers().then((_) {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
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

