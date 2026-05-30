import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'balance_manager.dart';

class OfferDetailScreen extends StatefulWidget {
  final Map<String, dynamic> offer;
  final Set<String> claimedOfferIds;

  const OfferDetailScreen({
    super.key,
    required this.offer,
    required this.claimedOfferIds,
  });

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen>
    with SingleTickerProviderStateMixin {
  late bool _isClaimed;
  String? _userId;
  bool _isUnlocking = false;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ─── Computed offer fields ────────────────────────────────────────────────
  late final Map<String, dynamic> _merchant;
  late final String _bannerUrl;
  late final String _merchantName;
  late final String _offerTitle;
  late final String _description;
  late final String _offerType;
  late final double? _minBillValue;
  late final double? _maxDiscount;
  late final List<dynamic> _conditions;
  late final DateTime? _validityEnd;
  late final int _coinsRequired;

  @override
  void initState() {
    super.initState();
    _isClaimed = widget.claimedOfferIds.contains(widget.offer['id']);
    _parseOffer();
    _loadUserId();
    _startCountdown();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _parseOffer() {
    final o = widget.offer;
    _merchant = (o['merchant'] as Map<String, dynamic>?) ?? {};

    // Banner: prefer offer images array, fallback to merchant shopLogo
    final List<dynamic> images = o['images'] ?? [];
    String banner = '';
    if (images.isNotEmpty && images[0].toString().startsWith('http')) {
      banner = images[0].toString();
    } else if (_merchant['shopLogo'] != null &&
        _merchant['shopLogo'].toString().startsWith('http')) {
      banner = _merchant['shopLogo'].toString();
    }
    _bannerUrl = banner;

    _merchantName = _merchant['businessName']?.toString() ?? o['title']?.toString() ?? 'Merchant';
    _offerTitle = o['title']?.toString() ?? 'Special Offer';
    _description = o['description']?.toString() ?? 'Exclusive deal available for Froofly members.';
    _offerType = o['offerType']?.toString() ?? 'EXCLUSIVE';
    _minBillValue = (o['minBillValue'] as num?)?.toDouble();
    _maxDiscount = (o['maxDiscount'] as num?)?.toDouble();
    _conditions = (o['conditions'] as List<dynamic>?) ?? [];
    _coinsRequired = (o['coinsRequired'] as int?) ?? 100;

    try {
      _validityEnd = o['validityEnd'] != null
          ? DateTime.parse(o['validityEnd'].toString())
          : null;
    } catch (_) {
      _validityEnd = null;
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _userId = prefs.getString('userId'));
    }
  }

  void _startCountdown() {
    if (_validityEnd == null) return;
    _remaining = _validityEnd.difference(DateTime.now());
    if (_remaining.isNegative) _remaining = Duration.zero;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final diff = _validityEnd.difference(DateTime.now());
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Unlock logic ─────────────────────────────────────────────────────────
  Future<void> _unlockOffer() async {
    if (_isClaimed || _isUnlocking) return;

    if (_userId == null) {
      _showSnack('Please log in to unlock offers!', isError: true);
      return;
    }

    final currentBal = BalanceManager.instance.balance.value;
    if (currentBal < _coinsRequired) {
      _showInsufficientCoinsDialog(currentBal);
      return;
    }

    final confirm = await _showConfirmDialog();
    if (confirm != true) return;

    setState(() => _isUnlocking = true);

    try {
      final response = await http.post(
        Uri.parse('https://froofly-backend.onrender.com/offer/claim/${widget.offer['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': _userId}),
      );

      if (!mounted) return;
      setState(() => _isUnlocking = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final int updatedBalance = data['currentBalance'] ?? (currentBal - _coinsRequired);

        await BalanceManager.instance.updateBalance(updatedBalance);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('currentBalance', updatedBalance);

        if (mounted) {
          setState(() => _isClaimed = true);
          _showCelebrationDialog();
        }
      } else {
        final err = json.decode(response.body);
        throw err['message'] ?? 'Claim failed';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUnlocking = false);
        _showSnack('Failed to unlock: $e', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF2E9C68),
    ));
  }

  void _showInsufficientCoinsDialog(int currentBal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Insufficient Coins',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.classicNavy)),
        content: Text(
          'You need $_coinsRequired coins to unlock this offer. You currently have $currentBal coins.\n\nEarn more by uploading payment screenshots on the Challenges tab!',
          style: GoogleFonts.poppins(color: AppTheme.textDark, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.poppins(color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Unlock Offer?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
        content: Text(
          'Unlock "$_offerTitle" for $_coinsRequired coins?',
          style: GoogleFonts.poppins(color: AppTheme.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Unlock', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCelebrationDialog() {
    final claimId = widget.offer['id']?.toString() ?? '';
    final couponCode = 'FRFL-${claimId.length >= 8 ? claimId.substring(claimId.length - 8).toUpperCase() : claimId.toUpperCase()}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFFE5F8ED), shape: BoxShape.circle),
                child: const Icon(Icons.celebration, color: Color(0xFF2E9C68), size: 52),
              ),
              const SizedBox(height: 20),
              Text('Congratulations!',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.textDark)),
              const SizedBox(height: 10),
              Text(
                'You\'ve unlocked "$_offerTitle"!\n\nYour coupon code is active and saved in\nProfile → Orders.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 16),
              // Coupon code chip
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: couponCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Coupon code copied!', style: GoogleFonts.poppins())),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.magenta.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(couponCode,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.magenta, letterSpacing: 1.2)),
                      const SizedBox(width: 10),
                      const Icon(Icons.copy, color: AppTheme.magenta, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E9C68),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Awesome!',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Countdown helpers ────────────────────────────────────────────────────
  String _pad(int n) => n.toString().padLeft(2, '0');

  Widget _buildCountdownUnit(int value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppTheme.classicNavy,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: AppTheme.classicNavy.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          alignment: Alignment.center,
          child: Text(
            _pad(value),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textGrey, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildCountdownSeparator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(':', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.classicNavy)),
    );
  }

  // ─── Offer type badge helpers ─────────────────────────────────────────────
  Color _offerTypeColor() {
    switch (_offerType) {
      case 'PERCENTAGE': return const Color(0xFF5A45A0);
      case 'FLAT_DISCOUNT': return const Color(0xFF0A7A4B);
      case 'BOGO': return const Color(0xFFD4380D);
      default: return AppTheme.magenta;
    }
  }

  String _offerTypeLabel() {
    switch (_offerType) {
      case 'PERCENTAGE': return '% OFF';
      case 'FLAT_DISCOUNT': return 'FLAT DISCOUNT';
      case 'BOGO': return 'BUY 1 GET 1';
      default: return 'EXCLUSIVE';
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;
    final isExpired = _remaining == Duration.zero && _validityEnd != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomScrollView(
        slivers: [
          // ── Hero Banner SliverAppBar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.classicNavy,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context, _isClaimed),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _bannerUrl.isNotEmpty
                      ? Image.network(
                          _bannerUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholderBanner(),
                        )
                      : _buildPlaceholderBanner(),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.classicNavy.withValues(alpha: 0.8),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Merchant name + offer type at bottom of banner
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _offerTypeColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _offerTypeLabel(),
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _merchantName,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offer Title
                  Text(
                    _offerTitle,
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, height: 1.3),
                  ),
                  const SizedBox(height: 16),

                  // ── Quick Info Chips ─────────────────────────────────────
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _infoChip(Icons.stars_rounded, '$_coinsRequired Coins', const Color(0xFFD4AF37)),
                      if (_maxDiscount != null && _offerType == 'PERCENTAGE')
                        _infoChip(Icons.percent_rounded, '${_maxDiscount.toStringAsFixed(0)}% Max Off', AppTheme.primaryPurple),
                      if (_maxDiscount != null && _offerType == 'FLAT_DISCOUNT')
                        _infoChip(Icons.currency_rupee_rounded, '₹${_maxDiscount.toStringAsFixed(0)} Off', const Color(0xFF0A7A4B)),
                      if (_minBillValue != null)
                        _infoChip(Icons.receipt_long_rounded, 'Min ₹${_minBillValue.toStringAsFixed(0)}', AppTheme.classicNavy),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Description ──────────────────────────────────────────
                  _sectionTitle('About this Offer'),
                  const SizedBox(height: 10),
                  Text(
                    _description,
                    style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textGrey, height: 1.7),
                  ),
                  const SizedBox(height: 28),

                  // ── Expiry Countdown ─────────────────────────────────────
                  _sectionTitle(isExpired ? 'Offer Expired' : 'Expires In'),
                  const SizedBox(height: 14),
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_off_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Text('This offer has expired',
                              style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  else if (_validityEnd == null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F8ED),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.all_inclusive_rounded, color: Color(0xFF2E9C68), size: 20),
                          const SizedBox(width: 10),
                          Text('No expiry date', style: GoogleFonts.poppins(color: const Color(0xFF2E9C68), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                        border: Border.all(color: AppTheme.classicNavy.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCountdownUnit(days, 'DAYS'),
                          _buildCountdownSeparator(),
                          _buildCountdownUnit(hours, 'HRS'),
                          _buildCountdownSeparator(),
                          _buildCountdownUnit(minutes, 'MINS'),
                          _buildCountdownSeparator(),
                          _buildCountdownUnit(seconds, 'SECS'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 28),

                  // ── Min Bill / Discount Details block ────────────────────
                  if (_minBillValue != null || _maxDiscount != null) ...[
                    _sectionTitle('Offer Details'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          if (_minBillValue != null)
                            _detailRow(
                              Icons.receipt_long_rounded,
                              'Minimum Bill Amount',
                              '₹${_minBillValue.toStringAsFixed(0)}',
                              isFirst: true,
                            ),
                          if (_maxDiscount != null)
                            _detailRow(
                              _offerType == 'PERCENTAGE'
                                  ? Icons.percent_rounded
                                  : Icons.currency_rupee_rounded,
                              _offerType == 'PERCENTAGE' ? 'Discount Percentage' : 'Flat Discount',
                              _offerType == 'PERCENTAGE'
                                  ? '${_maxDiscount.toStringAsFixed(0)}% off'
                                  : '₹${_maxDiscount.toStringAsFixed(0)} off',
                              isFirst: _minBillValue == null,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Rules & Terms ────────────────────────────────────────
                  _sectionTitle('Rules & Terms'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: _conditions.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _termRow('Valid on all days including weekends'),
                              _termRow('Present this coupon code at the counter before billing'),
                              _termRow('Cannot be combined with other offers'),
                              _termRow('Froofly reserves the right to modify or withdraw this offer'),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _conditions.map((c) => _termRow(c.toString())).toList(),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Sticky Unlock Button ──────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: _isClaimed
            ? _buildUnlockedButton()
            : _buildUnlockButton(isExpired),
      ),
    );
  }

  Widget _buildUnlockButton(bool isExpired) {
    if (isExpired) {
      return Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text('Offer Expired',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16)),
      );
    }

    return ScaleTransition(
      scale: _pulseAnimation,
      child: SizedBox(
        height: 58,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isUnlocking ? null : _unlockOffer,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.classicNavy,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.classicNavy.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 4,
            shadowColor: AppTheme.classicNavy.withValues(alpha: 0.4),
          ),
          child: _isUnlocking
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_open_rounded, size: 22),
                    const SizedBox(width: 10),
                    Text('Unlock for $_coinsRequired Coins',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.stars_rounded, size: 18, color: Color(0xFFFFD700)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildUnlockedButton() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF2E9C68),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text('Offer Unlocked — Check Orders',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
        ],
      ),
    );
  }

  // ─── Reusable widgets ─────────────────────────────────────────────────────
  Widget _buildPlaceholderBanner() {
    return Container(
      color: AppTheme.classicNavy,
      child: Center(
        child: Icon(Icons.local_offer_rounded, size: 80, color: Colors.white.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppTheme.magenta, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(text,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 0.3)),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {bool isFirst = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isFirst ? null : Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.classicNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.classicNavy),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          ),
          Text(value,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.classicNavy)),
        ],
      ),
    );
  }

  Widget _termRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: AppTheme.magenta, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey, height: 1.6)),
          ),
        ],
      ),
    );
  }
}
