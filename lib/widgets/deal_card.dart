import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class DealCard extends StatelessWidget {
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
    this.onUnlockPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.ivoryWhite,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 10),
            blurRadius: 25,
          )
        ],
        border: Border.all(color: AppTheme.classicNavy.withOpacity(0.2), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Image Area
            Expanded(
              flex: 65,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                  // "Ad" Badge
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Ad',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // VERIFIED Badge
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF88A08A), Color(0xFF536A55)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          )
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'VERIFIED',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.magenta.withOpacity(0.7),
                    AppTheme.magenta,
                    AppTheme.magenta.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Bottom Information Area
            Expanded(
              flex: 35,
              child: Container(
                color: AppTheme.ivoryWhite,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Row 1 & 2: Title, Brand and Unlock Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ticket Icon + Offer Title
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_num_outlined, color: AppTheme.classicNavy, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      discountText.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.classicNavy,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Coffee Icon + Brand Name
                              Row(
                                children: [
                                  const Icon(Icons.local_cafe_outlined, color: AppTheme.classicNavy, size: 24),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      brandName.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.classicNavy,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 22,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // UNLOCK Button
                        InkWell(
                          onTap: onUnlockPressed,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.ivoryWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.classicNavy, width: 1.5),
                            ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'UNLOCK',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.classicNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'with ',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.classicNavy,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Icon(Icons.lock_outline, color: AppTheme.classicNavy, size: 14),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Row 3: Expiry and Distance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: AppTheme.classicNavy, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Expires: $timeLeft',
                              style: GoogleFonts.poppins(
                                color: AppTheme.classicNavy,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '0.8 mi',
                              style: GoogleFonts.poppins(
                                color: AppTheme.classicNavy,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.location_on_outlined, color: AppTheme.classicNavy, size: 18),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Row 4: Claimed Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: AppTheme.magenta, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          claimed.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: AppTheme.classicNavy,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
