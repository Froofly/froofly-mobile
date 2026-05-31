import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class DealCard extends StatefulWidget {
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
  final VoidCallback? onUnlockPressed;
  final bool isNetworkImage;
  final bool isExternalLink;
  final String? linkUrl;
  final bool isUnlocked;
  final String distance; // Dynamic location/direction parameter

  const DealCard({
    super.key,
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
    required this.distance,
    this.onUnlockPressed,
    this.isNetworkImage = false,
    this.isExternalLink = false,
    this.linkUrl,
    this.isUnlocked = false,
  });

  @override
  State<DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<DealCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.classicNavy.withValues(alpha: 0.12),
            offset: const Offset(0, 12),
            blurRadius: 30,
          ),
          BoxShadow(
            color: AppTheme.classicNavy.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 4,
          )
        ],
        border: Border.all(
          color: AppTheme.classicNavy.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== TOP SIDE VIEW (62% HEIGHT) ====================
            Expanded(
              flex: 62,
              child: Stack(
                children: [
                  // Full-cover Image with premium styling
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFF2F4F7),
                      child: widget.isNetworkImage
                          ? Image.network(
                              widget.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                            )
                          : Image.asset(
                              widget.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                            ),
                    ),
                  ),

                  // Soft dark elegant overlay gradient for visual contrast
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // TOP LEFT: Offer Type badge removed as per request

                  // TOP RIGHT: Direction / Distance
                  Positioned(
                    top: 16,
                    right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.near_me_outlined,
                                color: AppTheme.champaignGold,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.distance,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // BOTTOM LEFT: Expire in Days
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.timeLeft.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Subtle gold highlight divider line
            Container(
              height: 2,
              color: AppTheme.champaignGold.withValues(alpha: 0.4),
            ),

            // ==================== BOTTOM DETAILS VIEW (38% HEIGHT) ====================
            Expanded(
              flex: 38,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Row 1: Merchant & Subtitle details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.brandName.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: AppTheme.classicNavy,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.subtitle,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textGrey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Row 2: Interactive Deal / Discount highlights (Ticket Banner Design)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.classicNavy.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.classicNavy.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.confirmation_number,
                            color: widget.isUnlocked ? const Color(0xFF2E9C68) : AppTheme.champaignGold,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.discountText.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.classicNavy,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.discountDesc,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textDark.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Row 3: Action Buttons (Redesigned dynamic action states)
                    InkWell(
                      onTap: widget.isExternalLink
                          ? () async {
                              final url = widget.linkUrl ?? '';
                              final uri = Uri.tryParse(url);
                              final messenger = ScaffoldMessenger.of(context);
                              if (uri != null && await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Could not open target link')),
                                );
                              }
                            }
                          : (widget.isUnlocked ? null : widget.onUnlockPressed),
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: widget.isExternalLink
                              ? AppTheme.classicNavy
                              : (widget.isUnlocked
                                  ? const Color(0xFF2E9C68)
                                  : AppTheme.champaignGold),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (!widget.isUnlocked)
                              BoxShadow(
                                color: (widget.isExternalLink
                                        ? AppTheme.classicNavy
                                        : AppTheme.champaignGold)
                                    .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                          ],
                        ),
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isExternalLink
                                    ? Icons.open_in_new_rounded
                                    : (widget.isUnlocked
                                        ? Icons.check_circle_rounded
                                        : Icons.lock_open_rounded),
                                color: widget.isExternalLink || widget.isUnlocked
                                    ? Colors.white
                                    : AppTheme.classicNavy,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isExternalLink
                                    ? 'CLICK HERE'
                                    : (widget.isUnlocked ? 'UNLOCKED' : 'UNLOCK DEAL'),
                                style: GoogleFonts.poppins(
                                  color: widget.isExternalLink || widget.isUnlocked
                                      ? Colors.white
                                      : AppTheme.classicNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Row 4 (Claim Statistics pill) removed as per request
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFE2E4E7),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: AppTheme.classicNavy,
        ),
      ),
    );
  }
}
