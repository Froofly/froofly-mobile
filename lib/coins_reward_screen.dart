import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class CoinsRewardScreen extends StatefulWidget {
  final int coins;
  final double amount;
  final String transactionId;
  final bool isJackpot;

  const CoinsRewardScreen({
    super.key,
    required this.coins,
    required this.amount,
    required this.transactionId,
    this.isJackpot = false,
  });

  @override
  State<CoinsRewardScreen> createState() => _CoinsRewardScreenState();
}

class _CoinsRewardScreenState extends State<CoinsRewardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF6FB),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFCF6FB), Color(0xFFF3E8FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              if (widget.isJackpot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
                    ],
                  ),
                  child: Text(
                    '🌟 JACKPOT !!! 🌟',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Animated Coin Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightLavender,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isJackpot ? Icons.auto_awesome : Icons.monetization_on,
                      size: 100,
                      color: widget.isJackpot ? Colors.orange : AppTheme.primaryPurple,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.isJackpot ? 'Massive Win!' : 'Payment Verified!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'You earned',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Animated Coin Count
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: widget.coins.toDouble()),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Text(
                    '+${value.toInt()} Coins',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: widget.isJackpot ? Colors.redAccent : AppTheme.magenta,
                      letterSpacing: -1,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Metadata display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildMetaRow('Amount', '₹${widget.amount}'),
                    const Divider(height: 24),
                    _buildMetaRow('Transaction ID', widget.transactionId),
                  ],
                ),
              ),
              
              const Spacer(),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: AppTheme.primaryPurple.withOpacity(0.5),
                  ),
                  child: Text(
                    'Awesome!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
