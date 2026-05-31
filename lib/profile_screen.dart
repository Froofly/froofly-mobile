import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'theme.dart';
import 'balance_manager.dart';
import 'membership_screen.dart';
import 'sign_in_screen.dart';
import 'notification_preferences_screen.dart';
import 'help_support_screen.dart';
import 'account_privacy_screen.dart';
import 'edit_profile_screen.dart';
import 'about_us_screen.dart';
import 'invite_friends_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onGoHome;
  const ProfileScreen({super.key, this.onGoHome});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = '';
  String _email = '';
  String _phoneNumber = '';
  String _frooflyId = '';
  String _avatarUrl = '';
  bool _isLoading = true;
  int _totalBills = 0;
  int _achievements = 0;
  int _totalClaims = 0;
  String _membershipPlan = 'Froofly Free';



  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Immediately update UI with local data
    setState(() {
      _fullName = prefs.getString('fullName') ?? '';
      _email = prefs.getString('email') ?? '';
      _phoneNumber = prefs.getString('phoneNumber') ?? '';
      _frooflyId = prefs.getString('frooflyId') ?? '';
      _membershipPlan = prefs.getString('membershipPlan') ?? 'Froofly Free';
      _avatarUrl = prefs.getString('avatarUrl') ?? '';
    });

    final userId = prefs.getString('userId');
    String avatarUrl = _avatarUrl;

    int fetchedTotalBills = 0;
    int fetchedAchievements = 0;
    int fetchedTotalClaims = 0;

    if (userId != null && userId.isNotEmpty) {
      try {
        final responses = await Future.wait([
          http.get(Uri.parse('https://backend-froofly.onrender.com/auth/stats/$userId')),
          (() async {
            bool localFileExists = false;
            if (avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
              localFileExists = await File(avatarUrl).exists();
            }

            if (avatarUrl.isEmpty || !localFileExists) {
              return http.get(Uri.parse('https://backend-froofly.onrender.com/avatar/$userId'));
            }
            return null;
          })(),
        ]);

        final http.Response? statsResponse = responses[0];
        final http.Response? avatarResponse = responses[1];

        if (statsResponse != null && statsResponse.statusCode == 200) {
          final data = jsonDecode(statsResponse.body);
          fetchedTotalBills = data['totalBills'] ?? 0;
          fetchedAchievements = data['achievements'] ?? 0;
          fetchedTotalClaims = data['totalClaims'] ?? 0;
        }

        if (avatarResponse != null && avatarResponse.statusCode == 200) {
          final data = jsonDecode(avatarResponse.body);
          final base64String = data['base64'] as String?;
          if (base64String != null) {
            final bytes = base64Decode(base64String);
            final dir = await getApplicationDocumentsDirectory();
            final file = File('${dir.path}/avatar_$userId.png');
            await file.writeAsBytes(bytes);
            avatarUrl = file.path;
            await prefs.setString('avatarUrl', avatarUrl);
          }
        }
      } catch (e) {
        debugPrint('Error fetching data/avatar: $e');
      }
    }

    if (!mounted) return;

    setState(() {
      _avatarUrl = avatarUrl;
      _totalBills = fetchedTotalBills;
      _achievements = fetchedAchievements;
      _totalClaims = fetchedTotalClaims;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Log Out',
              style: GoogleFonts.poppins(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  /// Returns user initials for the avatar fallback (e.g. "Alex Johnson" → "AJ")
  String get _initials {
    final parts = _fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF9F9F9);
    final primaryColor = const Color(0xFF0A3D62);
    final textDark = AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () {
            if (widget.onGoHome != null) {
              widget.onGoHome!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  _buildAvatarSection(primaryColor),
                  const SizedBox(height: 16),
                  _buildBalanceCard(context, primaryColor),
                  const SizedBox(height: 16),
                  _buildInfoCard(primaryColor),
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 32),
                  _buildSettingsList(),
                ],
              ),
            ),
    );
  }

  // ─── Avatar ──────────────────────────────────────────────────────────────

  Widget _buildAvatarSection(Color primaryColor) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0A3D62), width: 3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipOval(
                  child: _avatarUrl.isNotEmpty
                      ? (_avatarUrl.startsWith('http')
                          ? Image.network(
                              _avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, s) => _buildInitialsAvatar(),
                            )
                          : Image.file(
                              File(_avatarUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, s) => _buildInitialsAvatar(),
                            ))
                      : _buildInitialsAvatar(),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF0A3D62),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _fullName.isNotEmpty ? _fullName : 'Froofly User',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _membershipPlan == 'Froofly Free' ? Colors.grey.shade200 : const Color(0xFFE6EBF0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _membershipPlan,
            style: GoogleFonts.poppins(
              color: _membershipPlan == 'Froofly Free' ? AppTheme.textGrey : primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_frooflyId.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ID: $_frooflyId',
              style: GoogleFonts.poppins(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A3D62), Color(0xFFD4AF37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
    );
  }

  // ─── Balance card ─────────────────────────────────────────────────────────

  Widget _buildBalanceCard(BuildContext context, Color primaryColor) {
    return ValueListenableBuilder<int>(
      valueListenable: BalanceManager.instance.balance,
      builder: (context, currentBalance, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'CURRENT BALANCE',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentBalance.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Coins',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD4AF37),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MembershipScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: AppTheme.textDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Earn More',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── User info card ───────────────────────────────────────────────────────

  Widget _buildInfoCard(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', _email.isNotEmpty ? _email : '—', primaryColor),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF9F9F9)),
          ),
          _buildInfoRow(
            Icons.phone_outlined,
            'Phone',
            _phoneNumber.isNotEmpty ? _phoneNumber : '—',
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color primaryColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE6EBF0),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppTheme.textGrey,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Stats row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatBox(_totalBills.toString(), 'TOTAL\nBILLS'),
        const SizedBox(width: 12),
        _buildStatBox(_achievements.toString(), 'ACHIEVEMENTS'),
        const SizedBox(width: 12),
        _buildStatBox(_totalClaims.toString(), 'TOTAL\nCLAIMS'),
      ],
    );
  }

  Widget _buildStatBox(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppTheme.textDark.withOpacity(0.7),
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(Icons.edit, 'Edit Profile', const Color(0xFF0A3D62), false, onTap: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );
            if (updated == true) _loadUserData();
          }),
          _buildDivider(),
          _buildSettingsItem(Icons.info_outline, 'About Us', const Color(0xFF0A3D62), false, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsScreen()),
            );
          }),
          _buildDivider(),
          _buildSettingsItem(Icons.shopping_bag_outlined, 'Orders', const Color(0xFF0A3D62), false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                );
              }),
          _buildDivider(),
          _buildSettingsItem(Icons.notifications, 'Notification Preferences', const Color(0xFF0A3D62), false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationPreferencesScreen()),
                );
              }),
          _buildDivider(),
          _buildSettingsItem(Icons.help_outline, 'Help & Support', const Color(0xFF0A3D62), false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                );
              }),
          _buildDivider(),
          _buildSettingsItem(Icons.privacy_tip_outlined, 'Account Privacy', const Color(0xFF0A3D62), false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountPrivacyScreen()),
                );
              }),
          _buildDivider(),
          _buildSettingsItem(Icons.share, 'Invite your Friends', const Color(0xFF0A3D62), false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InviteFriendsScreen()),
                );
              }),
          _buildDivider(),
          _buildSettingsItem(Icons.logout, 'Log Out', const Color(0xFFD4AF37), true, onTap: _logout),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, Color color, bool hideArrow,
      {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: hideArrow ? const Color(0xFFF9F9F9) : const Color(0xFFE6EBF0),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: hideArrow ? const Color(0xFFD4AF37) : AppTheme.textDark,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: hideArrow
          ? null
          : Icon(Icons.chevron_right, color: AppTheme.textGrey.withOpacity(0.5), size: 24),
      onTap: onTap,
    );
  }


}


