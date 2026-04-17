import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'theme.dart';
import 'membership_screen.dart';
import 'sign_in_screen.dart';
import 'notification_preferences_screen.dart';
import 'help_support_screen.dart';
import 'account_privacy_screen.dart';
import 'edit_profile_screen.dart';
import 'about_us_screen.dart';
import 'invite_friends_screen.dart';

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
  int _currentBalance = 0;
  String _avatarUrl = '';
  bool _isLoading = true;
  int _totalBills = 0;
  int _achievements = 0;
  String _membershipPlan = 'Froofly Free';

  List<double> _coinsEarnedList = [0, 0, 0, 0, 0, 0, 0];
  String _percentageChange = '0%';
  List<Map<String, dynamic>> _uploadCategories = [];

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
      _currentBalance = prefs.getInt('currentBalance') ?? 0;
      _membershipPlan = prefs.getString('membershipPlan') ?? 'Froofly Free';
      _avatarUrl = prefs.getString('avatarUrl') ?? '';
    });

    final userId = prefs.getString('userId');
    String avatarUrl = _avatarUrl;

    int fetchedTotalBills = 0;
    int fetchedAchievements = 0;
    List<double> fetchedCoinsList = _coinsEarnedList;
    String fetchedPercentage = _percentageChange;
    List<Map<String, dynamic>> fetchedCategories = _uploadCategories;

    if (userId != null && userId.isNotEmpty) {
      try {
        // 1. Fetch Stats
        final statsResponse = await http.get(Uri.parse('https://froofly-backend.onrender.com/auth/stats/$userId'));
        if (statsResponse.statusCode == 200) {
          final data = jsonDecode(statsResponse.body);
          fetchedTotalBills = data['totalBills'] ?? 0;
          fetchedAchievements = data['achievements'] ?? 0;
          if (data['analytics'] != null) {
            final a = data['analytics'];
            if (a['coinsEarnedList'] != null) {
              fetchedCoinsList = List<double>.from(a['coinsEarnedList'].map((x) => (x as num).toDouble()));
            }
            if (a['percentageChange'] != null) {
              fetchedPercentage = a['percentageChange'];
            }
            if (a['categories'] != null) {
              fetchedCategories = List<Map<String, dynamic>>.from(a['categories']);
            }
          }
        }

        // 2. Sync Avatar from Upstash Redis if local is missing
        bool localFileExists = false;
        if (avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
          localFileExists = await File(avatarUrl).exists();
        }

        if (avatarUrl.isEmpty || !localFileExists) {
          final avatarResponse = await http.get(Uri.parse('https://froofly-backend.onrender.com/avatar/$userId'));
          if (avatarResponse.statusCode == 200) {
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
      _coinsEarnedList = fetchedCoinsList;
      _percentageChange = fetchedPercentage;
      _uploadCategories = fetchedCategories;
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
                color: const Color(0xFFD80B57),
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
      Navigator.of(context).pushAndRemoveUntil(
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
    final bgColor = const Color(0xFFFCF6FB);
    final primaryColor = const Color(0xFF4C3EE3);
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
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPreferencesScreen()),
              );
            },
          ),
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
                  _buildAnalyticsHeader(),
                  const SizedBox(height: 16),
                  _buildChartCard(),
                  const SizedBox(height: 16),
                  _buildUploadCategoriesCard(),
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
                border: Border.all(color: const Color(0xFF4C3EE3), width: 3),
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
                  color: Color(0xFF4C3EE3),
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
            color: _membershipPlan == 'Froofly Free' ? Colors.grey.shade200 : const Color(0xFFEADBFF),
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
          colors: [Color(0xFF4C3EE3), Color(0xFF7ADCF6)],
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
                _currentBalance.toString(),
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
                    color: const Color(0xFF7DE4FF),
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
              backgroundColor: const Color(0xFF7DE4FF),
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
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF3EFFF)),
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
            color: const Color(0xFFEADBFF),
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
        _buildStatBox('342', 'FRIENDS'),
      ],
    );
  }

  Widget _buildStatBox(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF1FB),
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

  // ─── Analytics ────────────────────────────────────────────────────────────

  Widget _buildAnalyticsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Spend & Earn Analytics',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'LAST 7 DAYS',
          style: GoogleFonts.poppins(
            color: const Color(0xFF4C3EE3),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COINS EARNED',
                style: GoogleFonts.poppins(
                  color: AppTheme.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F8ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _percentageChange,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2E9C68),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _CurvedChartPainter(_coinsEarnedList),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
              return Text(
                day,
                style: GoogleFonts.poppins(
                  color: AppTheme.textGrey.withOpacity(0.7),
                  fontSize: 10,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCategoriesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPLOAD CATEGORIES',
            style: GoogleFonts.poppins(
              color: AppTheme.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (_uploadCategories.isEmpty)
            Text(
              'No recent spending categories.',
              style: GoogleFonts.poppins(
                color: AppTheme.textGrey.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ..._uploadCategories.map((c) {
             final hexStr = c['colorHex'] as String;
             final colorVal = int.tryParse(hexStr) ?? 0xFF4C3EE3;
             return Column(
               children: [
                 _buildCategoryProgress(c['name'], c['percentage'], c['value'], Color(colorVal)),
                 const SizedBox(height: 16),
               ],
             );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(String name, String percentage, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style:
                    GoogleFonts.poppins(color: AppTheme.textDark, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(percentage,
                style:
                    GoogleFonts.poppins(color: AppTheme.textDark, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EFFF),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
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
          _buildSettingsItem(Icons.edit, 'Edit Profile', const Color(0xFF4C3EE3), false, onTap: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );
            if (updated == true) _loadUserData();
          }),
          _buildDivider(),
          _buildSettingsItem(Icons.info_outline, 'About Us', const Color(0xFF4C3EE3), false, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsScreen()),
            );
          }),
          _buildDivider(),
          _buildSettingsItem(Icons.shopping_bag_outlined, 'Orders', const Color(0xFF4C3EE3), false,
              onTap: () {}),
          _buildDivider(),
          _buildSettingsItem(Icons.notifications, 'Notification Preferences', const Color(0xFF4C3EE3), false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationPreferencesScreen()),
                );
              }),
          _buildDivider(),
          _buildSettingsItem(Icons.help_outline, 'Help & Support', const Color(0xFF4C3EE3), false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                );
              }),
          _buildDivider(),
          _buildSettingsItem(Icons.privacy_tip_outlined, 'Account Privacy', const Color(0xFF4C3EE3), false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountPrivacyScreen()),
                );
              }),
          _buildDivider(),
          _buildSettingsItem(Icons.share, 'Invite your Friends', const Color(0xFF4C3EE3), false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InviteFriendsScreen()),
                );
              }),
          _buildDivider(),
          _buildSettingsItem(Icons.logout, 'Log Out', const Color(0xFFD80B57), true, onTap: _logout),
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
          color: hideArrow ? const Color(0xFFFDEDF4) : const Color(0xFFEADBFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: hideArrow ? const Color(0xFFD80B57) : AppTheme.textDark,
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

// ─── Chart painter ────────────────────────────────────────────────────────────

class _CurvedChartPainter extends CustomPainter {
  final List<double> dataPoints;

  _CurvedChartPainter(this.dataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4C3EE3), Color(0xFF7ADCF6)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 1;

    final path = Path();
    List<Offset> points = [];
    for (int i = 0; i < dataPoints.length; i++) {
      double x = size.width * (i / (dataPoints.length - 1));
      // scale y so data points fill height but have padding
      double y = size.height - ((dataPoints[i] / maxVal) * size.height * 0.8) - (size.height * 0.1);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
        _addBezierCurve(path, points[i], points[i+1]);
    }

    canvas.drawPath(path, paint);

    final dotPaintCyan = Paint()
      ..color = const Color(0xFF7ADCF6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(points.last, 4, dotPaintCyan);
  }

  void _addBezierCurve(Path path, Offset start, Offset end) {
    final cx1 = start.dx + (end.dx - start.dx) / 2;
    final cy1 = start.dy;
    final cx2 = cx1;
    final cy2 = end.dy;
    path.cubicTo(cx1, cy1, cx2, cy2, end.dx, end.dy);
  }

  @override
  bool shouldRepaint(covariant _CurvedChartPainter oldDelegate) {
    return true;
  }
}
