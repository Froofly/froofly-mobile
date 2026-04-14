import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';
import 'rewards_marketplace.dart';
import 'challenges_screen.dart';
import 'profile_screen.dart';
import 'theme.dart';
import 'coins_reward_screen.dart';
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
        _processImageWithOpenRouter(media);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking media: $e')),
        );
      }
    }
  }

  Future<void> _processImageWithOpenRouter(XFile media) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Setup OpenRouter
      const apiKey = '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'; 
      final bytes = await media.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 2. Prepare Payload & Send Request
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-3.2-11b-vision-instruct',
          'response_format': {'type': 'json_object'},
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': '''Analyze this payment screenshot. 
FIRST: Check if the transaction is "Successful", "Completed", or "Paid Successfully". 
If IT IS NOT successful (e.g., failed, pending, or different screen), return ONLY exactly this JSON: {"status": "rejected", "message": "Transaction was not successful. Please upload a successful payment screenshot."}.

SECOND: If successful, extract the data and return ONLY exactly this JSON format:
{
  "status": "success",
  "amount": 0.0,
  "transaction_id": "",
  "receiver_name": "",
  "receiver_upi": "",
  "sender_bank": "",
  "payment_app": "",
  "date": {"day": 1, "month": 1, "year": 2026},
  "time": {"hour": 1, "minute": 1, "period": "AM"}
}'''
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image'
                  }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        throw 'API Error: ${response.body}';
      }

      // 3. Extract text
      final responseData = jsonDecode(response.body);
      final text = responseData['choices']?[0]?['message']?['content'];
      if (text == null) throw 'AI returned empty response';

      // Extract the JSON block using Regex in case Llama outputted conversational text
      final RegExp jsonRegExp = RegExp(r'\{[\s\S]*\}');
      final match = jsonRegExp.firstMatch(text);
      if (match == null) throw 'Could not strictly extract JSON from AI response: $text';
      final Map<String, dynamic> data = jsonDecode(match.group(0)!);

      if (data['status'] == 'rejected') {
        if (mounted) {
          Navigator.pop(context); // pop loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
        return;
      }

      // 4. Save to Supabase
      final user = Supabase.instance.client.auth.currentUser;
      
      // Temporary bypass for rate limit testing
      String? targetUserId = user?.id;
      if (targetUserId == null) {
        final anyUser = await Supabase.instance.client.from('profiles').select('id').limit(1).maybeSingle();
        if (anyUser == null) throw 'No users exist in the database. Please wait for the rate limit to expire to add one!';
        targetUserId = anyUser['id'] as String;
      }

      // Start a transaction-like flow (manual sequence)
      // A. Save Main Proof
      final proofResponse = await Supabase.instance.client.from('transaction_proofs').insert({
        'user_id': targetUserId,
        'amount': data['amount'],
        'transaction_id': data['transaction_id'],
        'receiver_name': data['receiver_name'],
        'receiver_upi': data['receiver_upi'],
        'sender_bank': data['sender_bank'],
        'payment_app': data['payment_app'],
      }).select().single();

      final proofId = proofResponse['id'];

      // B. Save Date
      await Supabase.instance.client.from('transaction_dates').insert({
        'proof_id': proofId,
        'day': data['date']?['day'] ?? 1,
        'month': data['date']?['month'] ?? 1,
        'year': data['date']?['year'] ?? 2026,
      });

      // C. Save Time
      await Supabase.instance.client.from('transaction_times').insert({
        'proof_id': proofId,
        'hour': data['time']?['hour'] ?? 12,
        'minutes': data['time']?['minute'] ?? 0,
        'period': data['time']?['period'] ?? 'AM',
      });

      // E. Calculate Coins based on amount
      final double amount = double.tryParse(data['amount'].toString()) ?? 0.0;
      int coins = 0;
      if (amount >= 1 && amount <= 100) {
        coins = Random().nextInt(50) + 1; // 1 to 50
      } else if (amount > 100 && amount <= 1000) {
        coins = Random().nextInt(151) + 50; // 50 to 200
      } else if (amount > 1000) {
        coins = Random().nextInt(301) + 200; // 200 to 500
      }

      // F. Save to coin_ledger and update total balance
      if (coins > 0) {
        await Supabase.instance.client.from('coin_ledger').insert({
          'user_id': targetUserId,
          'amount': coins,
          'transaction_type': 'proof_upload',
          'description': 'Reward for uploading payment proof',
        });

        // Add to user's total coins 
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select('current_balance')
            .eq('id', targetUserId)
            .single();
            
        final int currentBalance = profileResponse['current_balance'] ?? 0;
        final int newBalance = currentBalance + coins;

        // Update the total balance in the database
        await Supabase.instance.client
            .from('profiles')
            .update({'current_balance': newBalance})
            .eq('id', targetUserId);
      }

      if (mounted) {
        Navigator.pop(context); // pop loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CoinsRewardScreen(coins: coins)),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Extraction failed: ${e.toString()}')),
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
            _buildOffstageNavigator(4, const ProfileScreen()),
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
