import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'dart:math';
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
import 'balance_manager.dart';

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
              color: const Color(0xFF0A3D62).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0A3D62), size: 32),
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
      builder: (context) => const ScreenshotProcessingDialog(),
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

      // 422 = transaction not completed keyword not found, 409 = duplicate transaction
      if (response.statusCode == 422 || response.statusCode == 409) {
        String title = 'Transaction Not Completed';
        String message = 'We could not verify a successful payment in your screenshot.\n\nPlease upload a screenshot that shows:\n"Transaction Successful", "Paid to" or "Payment Completed".';
        
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['message'] != null) {
            message = errorBody['message'];
          }
          if (response.statusCode == 409 || errorBody['errorType'] == 'DUPLICATE_TRANSACTION') {
            title = 'Duplicate Transaction';
          }
        } catch (_) {}

        if (mounted) {
          Navigator.pop(context); // pop loading dialog
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              barrierColor: Colors.black54,
              pageBuilder: (_, __, ___) => TransactionFailedScreen(
                title: title,
                message: message,
              ),
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
      final int totalBalance = data['currentBalance'] ?? 0;

      // Update global balance
      if (totalBalance > 0) {
        await BalanceManager.instance.updateBalance(totalBalance);
      }

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
        backgroundColor: const Color(0xFFF9F9F9),
        body: Stack(
          children: [
            _buildOffstageNavigator(0, const HomeDealsTab()),
            _buildOffstageNavigator(1, const RewardsMarketplace()),
            const Offstage(offstage: true, child: SizedBox()), // Placeholder for FAB position
            _buildOffstageNavigator(3, ChallengesScreen(onScanPressed: _onUploadPressed)),
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
            color: const Color(0xFF0A3D62).withOpacity(0.4),
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
    final primaryColor = const Color(0xFF0A3D62);

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

class ScreenshotProcessingDialog extends StatefulWidget {
  const ScreenshotProcessingDialog({super.key});

  @override
  State<ScreenshotProcessingDialog> createState() => _ScreenshotProcessingDialogState();
}

class _ScreenshotProcessingDialogState extends State<ScreenshotProcessingDialog> with TickerProviderStateMixin {
  late AnimationController _coinRotationController;
  late AnimationController _laserScanController;
  late Animation<double> _laserPosition;
  
  int _statusIndex = 0;
  Timer? _statusTimer;
  
  final List<String> _statusMessages = [
    'Uploading screenshot securely...',
    'Extracting transaction details...',
    'Verifying merchant & signature...',
    'Running fraud validation checks...',
    'Generating your reward coins...',
    'Almost done! Preparing your wallet...',
  ];

  @override
  void initState() {
    super.initState();
    
    // Coin rotation animation controller (spins continuously)
    _coinRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    
    // Laser scan animation controller (moves up and down)
    _laserScanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    
    _laserPosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserScanController, curve: Curves.easeInOut),
    );
    
    // Cycle status messages
    _statusTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (mounted) {
        setState(() {
          _statusIndex = (_statusIndex + 1) % _statusMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _coinRotationController.dispose();
    _laserScanController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.classicNavy.withOpacity(0.95),
                  const Color(0xFF041E30).withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppTheme.champaignGold.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.classicNavy.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: AppTheme.champaignGold.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Scanning Mockup
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer decorative portal
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 2,
                        ),
                      ),
                    ),
                    
                    // Middle scanning card frame (resembles receipt/screen)
                    Container(
                      width: 90,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(4, (index) {
                          double width = index == 0 ? 30.0 : (index == 3 ? 20.0 : 50.0);
                          return Container(
                            height: 6,
                            width: width,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                    
                    // Moving Laser Line
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _laserPosition,
                        builder: (context, child) {
                          // Define laser bounds based on middle scanning card height
                          // Middle card is 120 high, centered in 160 height Stack
                          // Offset starts at (160 - 120) / 2 = 20, ends at 140
                          double topOffset = 20.0 + (_laserPosition.value * 120.0);
                          return Stack(
                            children: [
                              Positioned(
                                top: topOffset,
                                left: 35, // Centered horizontally relative to the 90 wide card (160-90)/2 = 35
                                child: Container(
                                  width: 90,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppTheme.champaignGold,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.champaignGold.withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    // Rotating & Pulsing Coin hovering in front
                    Positioned(
                      bottom: 0,
                      right: 15,
                      child: AnimatedBuilder(
                        animation: _coinRotationController,
                        builder: (context, child) {
                          double scale = 1.0 + (sin(_coinRotationController.value * 2 * pi) * 0.12);
                          double rotation = _coinRotationController.value * 2 * pi;
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // perspective
                              ..rotateY(rotation)
                              ..scale(scale),
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.monetization_on,
                                color: AppTheme.champaignGold,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 28),
                
                // Status caption
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _statusMessages[_statusIndex],
                    key: ValueKey<int>(_statusIndex),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Bottom premium loading indicator dots/progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 150)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusIndex % 4 == index
                                ? AppTheme.champaignGold
                                : Colors.white.withOpacity(0.15),
                            boxShadow: _statusIndex % 4 == index
                                ? [
                                    BoxShadow(
                                      color: AppTheme.champaignGold.withOpacity(0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
