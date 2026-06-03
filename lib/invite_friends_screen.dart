import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'theme.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  int _selectedTab = 0;
  bool _isLoading = true;

  String _referralCode = '';
  int _totalInvited = 0;
  int _totalJoined = 0;
  int _coinsEarned = 0;
  List<dynamic> _friends = [];

  static const _primaryColor = Color(0xFF0A3D62);
  static const _bgColor = Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    _fetchReferrals();
  }

  Future<void> _fetchReferrals() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    try {
      final res = await http.get(Uri.parse('https://cuajqhm529.execute-api.ap-south-1.amazonaws.com/auth/referrals/$userId'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _referralCode = data['referralCode'] ?? '';
          _totalInvited = data['totalInvited'] ?? 0;
          _totalJoined = data['totalJoined'] ?? 0;
          _coinsEarned = data['coinsEarned'] ?? 0;
          _friends = data['friends'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching referrals: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: 'https://froofly.app/invite?code=$_referralCode'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite link copied!', style: GoogleFonts.poppins()),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showShareSheet() {
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
                'Share Your Invite Link',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Send this link to your friends. You earn 100 coins when they sign up!',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    icon: Icons.chat,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.pop(context);
                      _copyLink();
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.share,
                    label: 'Twitter',
                    color: const Color(0xFF1DA1F2),
                    onTap: () {
                      Navigator.pop(context);
                      _copyLink();
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.camera_alt,
                    label: 'Instagram',
                    color: const Color(0xFFE1306C),
                    onTap: () {
                      Navigator.pop(context);
                      _copyLink();
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.copy,
                    label: 'Copy Link',
                    color: _primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      _copyLink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 28,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Invite Friends',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopStats(),
                  const SizedBox(height: 24),
                  _buildTabBar(),
                  const SizedBox(height: 24),
                  _buildTabContent(),
                ],
              ),
            ),
    );
  }

  // ─── TOP STATS ──────────────────────────────────────────────────────────

  Widget _buildTopStats() {
    String nextMilestone = '3rd';
    int nextReward = 300;
    if (_totalJoined >= 3) { nextMilestone = '5th'; nextReward = 500; }
    if (_totalJoined >= 5) { nextMilestone = '10th'; nextReward = 1500; }
    if (_totalJoined >= 10) { nextMilestone = 'Max'; nextReward = 0; }

    return Row(
      children: [
        _buildStatCard('Your coins', '$_coinsEarned', 'total earned'),
        const SizedBox(width: 12),
        _buildStatCard('Friends invited', '$_totalInvited', '$_totalJoined joined'),
        const SizedBox(width: 12),
        _buildStatCard('Next reward', nextMilestone, nextReward == 0 ? 'Milestones complete' : 'friend = $nextReward coins'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 10, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(color: AppTheme.textDark, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(color: AppTheme.textGrey.withValues(alpha: 0.8), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB BAR ────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Row(
      children: [
        _buildTabButton(0, 'Invite'),
        const SizedBox(width: 12),
        _buildTabButton(1, 'How it works'),
        const SizedBox(width: 12),
        _buildTabButton(2, 'Rewards'),
      ],
    );
  }

  Widget _buildTabButton(int index, String text) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.textDark : AppTheme.textGrey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: isSelected ? AppTheme.textDark : AppTheme.textGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 0) return _buildInviteTab();
    if (_selectedTab == 1) return _buildHowItWorksTab();
    return _buildRewardsTab();
  }

  // ─── INVITE TAB ─────────────────────────────────────────────────────────

  Widget _buildInviteTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR INVITE LINK',
          style: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.textGrey.withValues(alpha: 0.2), style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _referralCode.isEmpty ? 'Loading...' : _referralCode,
                style: GoogleFonts.poppins(color: AppTheme.textDark, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 2),
              ),
              ElevatedButton(
                onPressed: _referralCode.isNotEmpty ? _copyLink : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0EDEC),
                  foregroundColor: AppTheme.textDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text('Copy link', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _showShareSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7F5F5),
              foregroundColor: AppTheme.textDark,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Share invite', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_outward_rounded, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'FRIENDS (${_friends.length})',
          style: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        ..._friends.map((f) => _buildFriendCard(f)),
      ],
    );
  }

  Widget _buildFriendCard(dynamic friend) {
    final name = friend['name'] as String;
    final isJoined = friend['state'] == 'Joined';
    final coins = friend['coins'] as String;

    String initials = '?';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) initials = parts[0][0].toUpperCase();
    else if (parts.length >= 2) initials = '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textGrey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isJoined ? const Color(0xFFE6EBF0) : const Color(0xFFFCEFE5),
            radius: 20,
            child: Text(
              initials,
              style: GoogleFonts.poppins(
                color: isJoined ? _primaryColor : const Color(0xFFD87B32),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isJoined ? const Color(0xFFE5F8ED) : const Color(0xFFFCEFE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isJoined ? 'Joined' : 'Pending',
              style: GoogleFonts.poppins(
                color: isJoined ? const Color(0xFF2E9C68) : const Color(0xFFD87B32),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              coins,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: isJoined ? const Color(0xFF2E9C68) : AppTheme.textGrey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HOW IT WORKS TAB ───────────────────────────────────────────────────

  Widget _buildHowItWorksTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textGrey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildStepRow(1, 'Share your invite link', 'Copy your unique link or code and send it to friends via WhatsApp, email, or social media.'),
          const Divider(height: 32, thickness: 1, color: Color(0xFFF9F9F9)),
          _buildStepRow(2, 'Friend signs up', 'Your friend clicks the link and creates a new account. Existing users are not eligible.'),
          const Divider(height: 32, thickness: 1, color: Color(0xFFF9F9F9)),
          _buildStepRow(3, 'You both earn coins', 'You get 100 coins. Your friend gets 50 welcome coins when they activate.'),
          const Divider(height: 32, thickness: 1, color: Color(0xFFF9F9F9)),
          _buildStepRow(4, 'Bonus on activity', 'Earn up to 1500 extra coins when 3, 5 or 10 of your referred friends activate.'),
        ],
      ),
    );
  }

  Widget _buildStepRow(int number, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFE6EBF0),
          radius: 16,
          child: Text(
            number.toString(),
            style: GoogleFonts.poppins(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(desc, style: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── REWARDS TAB ────────────────────────────────────────────────────────

  Widget _buildRewardsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textGrey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildRewardRow(Icons.access_time_filled, 'Per referral (join)', 'Friend signs up using your link', '100 coins', const Color(0xFFD3C8FF), const Color(0xFF6750A4)),
          const Divider(height: 32, thickness: 1, color: Color(0xFFF9F9F9)),
          _buildRewardRow(Icons.star_rounded, 'Activity bonus', 'Friend completes their first action', '50 coins', const Color(0xFFD1F2EB), const Color(0xFF1E8449)),
          const Divider(height: 32, thickness: 1, color: Color(0xFFF9F9F9)),
          _buildRewardRow(Icons.arrow_forward_rounded, '3rd friend milestone', 'Invite 3 friends who join', '300 coins', const Color(0xFFFFE0B2), const Color(0xFFE65100)),
          const Divider(height: 32, thickness: 1, color: Color(0xFFF9F9F9)),
          _buildRewardRow(Icons.arrow_forward_rounded, '5th friend milestone', 'Invite 5 friends who join', '500 coins', const Color(0xFFFFE0B2), const Color(0xFFE65100)),
          const Divider(height: 32, thickness: 1, color: Color(0xFFF9F9F9)),
          _buildRewardRow(Icons.shopping_bag_rounded, '10th friend milestone', 'Invite 10 friends who join', '1500 coins', const Color(0xFFD6EAF8), const Color(0xFF154360)),
        ],
      ),
    );
  }

  Widget _buildRewardRow(IconData icon, String title, String desc, String coinText, Color iconBg, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFCEFE5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFFD87B32), size: 10),
              const SizedBox(width: 6),
              Text(coinText, style: GoogleFonts.poppins(color: const Color(0xFFD87B32), fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
        )
      ],
    );
  }
}

