import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'theme.dart';
import 'balance_manager.dart';

class ChallengesScreen extends StatefulWidget {
  final VoidCallback? onScanPressed;

  const ChallengesScreen({
    super.key,
    this.onScanPressed,
  });

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  bool _isLoading = true;
  List<dynamic> _challenges = [];
  static const _baseUrl = 'https://backend-froofly.onrender.com';
  static const _primaryColor = Color(0xFF0A3D62);
  static const _bgColor = Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      final response = await http.get(
        Uri.parse('$_baseUrl/challenges?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _challenges = data;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching challenges: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separate challenges by runtime & type
    final dailyChallenges = _challenges
        .where((c) => c['challengeRuntime'] == 'Daily' && c['challengeType'] != 'Events')
        .toList();
        
    final otherGoals = _challenges
        .where((c) => 
            (c['challengeRuntime'] == 'Weekly' || 
             c['challengeRuntime'] == 'Bi-weekly' || 
             c['challengeRuntime'] == 'Monthly') && 
            c['challengeType'] != 'Events')
        .toList();

    final specialEvents = _challenges
        .where((c) => c['challengeType'] == 'Events')
        .toList();

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Challenges',
          style: GoogleFonts.poppins(
            color: _primaryColor,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: BalanceManager.instance.balance,
            builder: (context, currentBalance, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EBF0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: _primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      currentBalance.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF2D3436),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: _primaryColor),
            onPressed: _fetchChallenges,
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: _primaryColor),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            )
          : RefreshIndicator(
              color: _primaryColor,
              onRefresh: _fetchChallenges,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Daily Challenge Card (Gradient) ---
                    if (dailyChallenges.isNotEmpty) ...[
                      _buildDailyChallengeCard(dailyChallenges.first, _primaryColor),
                    ] else ...[
                      // Beautiful default dynamic placeholder if no daily challenge created
                      _buildDailyChallengePlaceholder(_primaryColor),
                    ],
                    
                    const SizedBox(height: 30),

                    // --- Goals Section (Weekly, Bi-weekly, Monthly) ---
                    _buildSectionHeader('Goals & Milestones', '', _primaryColor),
                    const SizedBox(height: 16),
                    if (otherGoals.isEmpty) ...[
                      _buildGoalsPlaceholder(),
                    ] else ...[
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: otherGoals.length,
                        itemBuilder: (context, index) {
                          return _buildGoalCard(otherGoals[index], _primaryColor);
                        },
                      ),
                    ],

                    const SizedBox(height: 30),

                    // --- Special Events Section ---
                    _buildSectionHeader('Special Events', '', _primaryColor),
                    const SizedBox(height: 16),
                    _buildSpecialEventsScroll(specialEvents),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
    );
  }

  // --- Daily Challenge Card Renderer ---
  Widget _buildDailyChallengeCard(dynamic challenge, Color primaryColor) {
    final title = challenge['title'] ?? 'Daily Challenge';
    final reward = challenge['rewardAmount'] ?? 10;
    final progress = challenge['progress'] ?? 0;
    final required = challenge['requiredUploadCount'] ?? 1;
    final double percent = progress / required;
    final isCompleted = progress >= required;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5F51E5),
            Color(0xFF8676FD),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5F51E5).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DAILY CHALLENGE',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+$reward',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Coins',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 240,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$progress/$required Bills',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (percent * 100).round().clamp(0, 100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  flex: ((1.0 - percent) * 100).round().clamp(0, 100),
                  child: Container(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isCompleted ? null : widget.onScanPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                disabledBackgroundColor: Colors.white.withOpacity(0.3),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                isCompleted ? '✓ Completed' : 'Scan New Bill',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Dynamic Goals / Milestones Cards ---
  Widget _buildGoalCard(dynamic challenge, Color primaryColor) {
    final title = challenge['title'] ?? 'Goal Milestone';
    final reward = challenge['rewardAmount'] ?? 0;
    final progress = challenge['progress'] ?? 0;
    final required = challenge['requiredUploadCount'] ?? 1;
    final double percent = required > 0 ? (progress / required) : 0;
    final isCompleted = progress >= required;
    final runtime = challenge['challengeRuntime'] ?? 'Weekly';

    // Premium dynamic icon picker based on keywords in title
    IconData cardIcon = Icons.emoji_events;
    Color iconBg = const Color(0xFFE6EBF0);
    Color iconColor = const Color(0xFF0A3D62);

    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('dine') || lowerTitle.contains('food') || lowerTitle.contains('restaurant') || lowerTitle.contains('eat') || lowerTitle.contains('visit')) {
      cardIcon = Icons.restaurant;
      iconBg = const Color(0xFFFFF9E6);
      iconColor = const Color(0xFFD4AF37);
    } else if (lowerTitle.contains('pharmacy') || lowerTitle.contains('medical') || lowerTitle.contains('health') || lowerTitle.contains('pill') || lowerTitle.contains('clinic')) {
      cardIcon = Icons.medical_services;
      iconBg = const Color(0xFFFFF0F5);
      iconColor = const Color(0xFFFD8AAB);
    } else if (lowerTitle.contains('grocery') || lowerTitle.contains('shop') || lowerTitle.contains('store') || lowerTitle.contains('supermarket') || lowerTitle.contains('bag')) {
      cardIcon = Icons.shopping_bag;
      iconBg = const Color(0xFFE5F8ED);
      iconColor = const Color(0xFF2E9C68);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(cardIcon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  runtime.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: iconColor,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppTheme.textDark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isCompleted ? 'Completed!' : '$progress of $required completed',
            style: GoogleFonts.poppins(
              color: AppTheme.textGrey,
              fontSize: 10,
            ),
          ),
          const Spacer(),
          if (isCompleted) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF2E9C68), size: 16),
                const SizedBox(width: 4),
                Text(
                  'Completed',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2E9C68),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                '+$reward Coins',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFA61E4D),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percent.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '+$reward Coins',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFA61E4D),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: widget.onScanPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9F9F9),
                      foregroundColor: const Color(0xFF2D3436),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Scan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- Dynamic Special Events Scroll ---
  Widget _buildSpecialEventsScroll(List<dynamic> events) {
    if (events.isEmpty) {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.lightLavender.withOpacity(0.3),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, color: _primaryColor, size: 28),
              const SizedBox(height: 8),
              Text(
                'More Special Events Coming Soon...',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: events.length,
        itemBuilder: (context, index) {
          final ev = events[index];
          final title = ev['title'] ?? 'Special Event';
          final desc = ev['description'] ?? 'Participate and earn coins!';
          final reward = ev['rewardAmount'] ?? 100;
          final isCompleted = ev['status'] == 'completed';

          return Container(
            margin: const EdgeInsets.only(right: 16),
            child: _buildSpecialEventCard(
              title,
              '$desc\nReward: +$reward Coins',
              'assets/images/coffee.png', // Generic default asset
              !isCompleted ? const Color(0xFFD4AF37) : const Color(0xFF8C8CA1),
              !isCompleted ? 'LIVE' : 'ENDED',
            ),
          );
        },
      ),
    );
  }

  // --- Special Event Card Item UI ---
  Widget _buildSpecialEventCard(String title, String subtitle, String imagePath, Color badgeColor, String statusText) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image part (Top half)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            child: Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFFE6EBF0), // Default premium placeholder color
              child: const Icon(Icons.image, color: Colors.white, size: 40),
            ),
          ),
          // Content part (Bottom half overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white, Colors.white12],
                  stops: [0.0, 0.8, 1.0],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textGrey,
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: widget.onScanPressed,
                    child: Row(
                      children: [
                        Text(
                          'Upload Proof',
                          style: GoogleFonts.poppins(
                            color: _primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, color: _primaryColor, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Status Badge (LIVE / ENDED)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Placeholders when lists are empty ---
  Widget _buildDailyChallengePlaceholder(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.lightLavender,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DAILY CHALLENGE',
                style: GoogleFonts.poppins(
                  color: AppTheme.textDark,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Icon(Icons.emoji_events, color: _primaryColor, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Check back tomorrow!',
            style: GoogleFonts.poppins(
              color: AppTheme.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload payment receipts on other milestones to keep earning coins.',
            style: GoogleFonts.poppins(
              color: AppTheme.textGrey,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.tour, color: _primaryColor, size: 30),
            const SizedBox(height: 8),
            Text(
              'No active milestones currently.\nKeep scanning your bills to earn coins!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppTheme.textGrey,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionLabel, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (actionLabel.isNotEmpty)
          Text(
            actionLabel,
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
