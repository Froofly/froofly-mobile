import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import 'theme.dart';
import 'balance_manager.dart';
import 'offer_detail_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryName;
  final List<String> subcategories;

  const CategoryDetailsScreen({super.key, required this.categoryName, required this.subcategories});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  String _selectedSubcategory = 'All';
  List<Map<String, dynamic>>? _fetchedOffers;
  bool _isLoading = true;
  Set<String> _claimedOfferIds = {};
  String? _userId;
  double _latitude = 12.9716;
  double _longitude = 77.5946;
  Timer? _locationTimer;

  final Color primaryColor = const Color(0xFF0A3D62);

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetch();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserDataAndFetch() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');
      
      await _startLocationTracking();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        await _loadStoredLocationAndFetch();
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied.');
          await _loadStoredLocationAndFetch();
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        await _loadStoredLocationAndFetch();
        return;
      } 

      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 4),
        );
      }
      _latitude = position.latitude;
      _longitude = position.longitude;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', _latitude);
      await prefs.setDouble('longitude', _longitude);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      final prefs = await SharedPreferences.getInstance();
      _latitude = prefs.getDouble('latitude') ?? 12.9716;
      _longitude = prefs.getDouble('longitude') ?? 77.5946;
    }

    await Future.wait([
      _fetchClaims(),
      _fetchCategoryOffers(),
    ]);

    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      await _updateCurrentLocation();
    });
  }

  Future<void> _updateCurrentLocation() async {
    try {
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
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('latitude', _latitude);
        await prefs.setDouble('longitude', _longitude);
        
        _fetchCategoryOffers();
      }
    } catch (e) {
      debugPrint('Error updating location in timer: $e');
    }
  }

  Future<void> _loadStoredLocationAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _latitude = prefs.getDouble('latitude') ?? 12.9716;
    _longitude = prefs.getDouble('longitude') ?? 77.5946;
    await Future.wait([
      _fetchClaims(),
      _fetchCategoryOffers(),
    ]);
  }

  Future<void> _fetchClaims() async {
    if (_userId == null) return;
    try {
      final response = await http.get(Uri.parse('https://backend-froofly.onrender.com/offer/claims/$_userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Set<String> claimedIds = {};
        for (var c in data) {
          if (c['offerId'] != null) {
            claimedIds.add(c['offerId'].toString());
          }
        }
        if (mounted) {
          setState(() {
            _claimedOfferIds = claimedIds;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching claims: $e');
    }
  }

  Future<void> _fetchCategoryOffers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final String encodedCat = Uri.encodeComponent(widget.categoryName);
      final String encodedSub = Uri.encodeComponent(_selectedSubcategory);
      final url = 'https://backend-froofly.onrender.com/offer/explore?lat=$_latitude&lng=$_longitude&category=$encodedCat&subcategory=$encodedSub';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _fetchedOffers = data.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Error fetching category offers: $e');
    }

    if (mounted) {
      setState(() {
        _fetchedOffers = [];
        _isLoading = false;
      });
    }
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
        Uri.parse('https://backend-froofly.onrender.com/offer/claim/${offer['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': _userId}),
      );

      if (mounted) Navigator.pop(context); // Dismiss spinner

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final int updatedBalance = data['currentBalance'] ?? (currentBal - coins);

        await BalanceManager.instance.updateBalance(updatedBalance);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('currentBalance', updatedBalance);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully unlocked and added to orders!', style: GoogleFonts.poppins(color: Colors.white)),
              backgroundColor: const Color(0xFF2E9C68),
            ),
          );
        }

        await _fetchClaims();
        _fetchCategoryOffers();
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

  Future<void> _showOfferDetails(Map<String, dynamic> offer) async {
    final bool? updatedClaimed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailScreen(
          offer: offer,
          claimedOfferIds: _claimedOfferIds,
        ),
      ),
    );
    if (updatedClaimed == true) {
      await _fetchClaims();
      await _fetchCategoryOffers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF9F9F9);

    // Split fetched offers into hero drop and available drops, filtering out claimed ones
    Map<String, dynamic>? heroOffer;
    List<Map<String, dynamic>> listOffers = [];

    final availableOffers = _fetchedOffers != null
        ? _fetchedOffers!.where((offer) => !_claimedOfferIds.contains(offer['id'])).toList()
        : [];

    if (availableOffers.isNotEmpty) {
      if (_selectedSubcategory == 'All') {
        heroOffer = availableOffers.first;
        listOffers = availableOffers.skip(1).toList();
      } else {
        listOffers = availableOffers;
      }
    }

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
          ValueListenableBuilder<int>(
            valueListenable: BalanceManager.instance.balance,
            builder: (context, balance, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3F6),
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
                        _isLoading = true;
                      });
                      _fetchCategoryOffers();
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Featured Hero drop
                        if (_selectedSubcategory == 'All' && heroOffer != null) ...[
                          Text(
                            'Featured Drop',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildHeroCard(heroOffer),
                          const SizedBox(height: 28),
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
                              '${_fetchedOffers?.length ?? 0} REWARDS',
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
                        
                        if (listOffers.isEmpty && heroOffer == null)
                          _buildEmptyState()
                        else
                          Column(
                            children: listOffers.map((offer) {
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
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Map<String, dynamic> offer) {
    final merchant = offer['merchant'] ?? {};
    final String offerImg = (offer['images'] != null && (offer['images'] as List).isNotEmpty)
        ? offer['images'][0]
        : (merchant['shopLogo']?.isNotEmpty == true && merchant['shopLogo'].toString().startsWith('http')
            ? merchant['shopLogo']
            : 'assets/images/wellness.png');
    final String merchantName = merchant['businessName'] ?? offer['title'] ?? 'Merchant';
    final String description = offer['description'] ?? 'Tap to view exclusive coupon code.';

    return GestureDetector(
      onTap: () => _showOfferDetails(offer),
      child: Container(
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
              offerImg.startsWith('http')
                  ? Image.network(
                      offerImg,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      offerImg,
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
                      merchantName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _showOfferDetails(offer),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Deals Found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Merchants in ${widget.categoryName} haven\'t launched any campaigns yet. Check back soon!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
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
                  // Left side: Distance & Expiry (NO icon!)
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
                  // Right side: Unlock, under it View More!
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: isUnlocked ? null : () => _unlockOffer(offer),
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
                        onTap: () => _showOfferDetails(offer),
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
}

