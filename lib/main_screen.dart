import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'rewards_marketplace.dart';
import 'challenges_screen.dart';
import 'profile_screen.dart';
import 'theme.dart';
import 'coins_reward_screen.dart';
import 'transaction_failed_screen.dart';
import 'dart:math';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();

  Future<void> _onUploadPressed() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Payment Screenshot',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUploadOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickMedia(ImageSource.camera);
                  },
                ),
                _buildUploadOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickMedia(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4C3EE3).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4C3EE3), size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? media = await _picker.pickImage(source: source);
      if (media != null && mounted) {
        _processImageWithBackend(media);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking media: $e')),
        );
      }
    }
  }

  Future<void> _processImageWithBackend(XFile media) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      
      if (userId == null) {
        throw 'User not logged in';
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://froofly-backend.onrender.com/payment/upload-screenshot'),
      );
      
      request.fields['userId'] = userId;
      request.files.add(await http.MultipartFile.fromPath(
        'screenshot',
        media.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 422 = transaction not completed keyword not found
      if (response.statusCode == 422) {
        if (mounted) {
          Navigator.pop(context); // pop loading dialog
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              barrierColor: Colors.black54,
              pageBuilder: (_, __, ___) => const TransactionFailedScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
        return;
      }

      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw errorBody['message'] ?? 'Upload failed';
      }

      final data = jsonDecode(response.body);
      final int coins = data['coins'] ?? 0;

      if (mounted) {
        Navigator.pop(context); // pop loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoinsRewardScreen(
              coins: coins,
              amount: (data['amount'] ?? 0).toDouble(),
              transactionId: data['transactionId'] ?? '',
              isJackpot: data['isJackpot'] ?? false,
            ),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Keys for nested navigators to keep state of each tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _onUploadPressed();
      return; 
    }

    if (_selectedIndex == index) {
      // Pop to first route if tapped on the active tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildOffstageNavigator(int index, Widget child) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // A clean "WillPopScope" fallback for Android back button to manage nested navs
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_selectedIndex != 0) {
             // Go back to Home tab if it's the first route but not on Home
            setState(() { _selectedIndex = 0; });
            return false;
          }
        }
        // Let system handle back button if on Home tab and it's the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF6FB),
        body: Stack(
          children: [
            _buildOffstageNavigator(0, const HomeDealsTab()),
            _buildOffstageNavigator(1, const RewardsMarketplace()),
            const Offstage(offstage: true, child: SizedBox()), // Placeholder for FAB position
            _buildOffstageNavigator(3, const ChallengesScreen()),
            _buildOffstageNavigator(4, ProfileScreen(onGoHome: () {
              setState(() {
                _selectedIndex = 0;
              });
            })),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: _buildUploadFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildUploadFab() {
    return Container(
      height: 60,
      width: 60,
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5F51E5), Color(0xFF8676FD)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C3EE3).withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.local_offer, 'DEALS', 0),
              _buildNavItem(Icons.explore, 'EXPLORE', 1),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(Icons.emoji_events, 'CHALLENGES', 3),
              _buildNavItem(Icons.person, 'PROFILE', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final primaryColor = const Color(0xFF4C3EE3);

    return Expanded(
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : AppTheme.textGrey.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? primaryColor : AppTheme.textGrey.withOpacity(0.5),
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
