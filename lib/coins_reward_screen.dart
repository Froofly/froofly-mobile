import 'dart:math';
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

class _CoinsRewardScreenState extends State<CoinsRewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _coinShowerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  final List<Point> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _coinShowerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scaleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _coinShowerController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Initialize particles
    for (int i = 0; i < 40; i++) {
      _particles.add(Point(
        _random.nextDouble(),
        _random.nextDouble(),
        _random.nextDouble() * 2 * pi,
        _random.nextDouble() * 5 + 2,
      ));
    }

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _coinShowerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Premium Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF9F9F9), Color(0xFFF9F9F9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Particle Shower (Coin Rain)
          AnimatedBuilder(
            animation: _coinShowerController,
            builder: (context, child) {
              return CustomPaint(
                painter: CoinRainPainter(
                  particles: _particles,
                  progress: _coinShowerController.value,
                  isJackpot: widget.isJackpot,
                ),
                size: Size.infinite,
              );
            },
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                if (widget.isJackpot)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.redAccent]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'JACKPOT REWARD!',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),

                // Central Animated Coin / Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Radiant Glow
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 220 * _glowAnimation.value,
                                height: 220 * _glowAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      (widget.isJackpot
                                              ? Colors.orange
                                              : AppTheme.primaryPurple)
                                          .withOpacity(0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.isJackpot
                                          ? Colors.orange
                                          : AppTheme.primaryPurple)
                                      .withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isJackpot
                                  ? Icons.auto_awesome
                                  : Icons.monetization_on,
                              size: 100,
                              color: widget.isJackpot
                                  ? Colors.orange
                                  : AppTheme.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        widget.isJackpot ? 'Massive Win!' : 'Success!',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'ve earned a reward',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Animated Coin Count
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: widget.coins.toDouble()),
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeOutExpo,
                  builder: (context, value, child) {
                    return Text(
                      '+${value.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: widget.isJackpot
                            ? Colors.redAccent
                            : AppTheme.primaryPurple,
                        letterSpacing: -2,
                      ),
                    );
                  },
                ),
                Text(
                  'COINS',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isJackpot
                        ? Colors.redAccent.withOpacity(0.6)
                        : AppTheme.primaryPurple.withOpacity(0.6),
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 40),

                // Receipt-style Meta Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppTheme.primaryPurple.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildMetaRow('Bill Amount', '₹${widget.amount}'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        _buildMetaRow('Transaction ID',
                            widget.transactionId.toUpperCase()),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Container(
                    height: 64,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'AWESOME!',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            fontSize: 13,
            color: AppTheme.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class Point {
  double x;
  double y;
  double angle;
  double speed;
  Point(this.x, this.y, this.angle, this.speed);
}

class CoinRainPainter extends CustomPainter {
  final List<Point> particles;
  final double progress;
  final bool isJackpot;

  CoinRainPainter({
    required this.particles,
    required this.progress,
    required this.isJackpot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isJackpot ? Colors.orange : AppTheme.primaryPurple)
          .withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (var p in particles) {
      final double xPos = p.x * size.width;
      final double yPos = ((p.y + progress) % 1.0) * size.height;
      
      // Draw a small "coin" circle
      canvas.drawCircle(Offset(xPos, yPos), p.speed, paint);
      
      // Draw a tiny star for jackpot
      if (isJackpot) {
        final starPaint = Paint()..color = Colors.orange.withOpacity(0.2);
        canvas.drawCircle(Offset(xPos + 10, yPos - 10), 2, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CoinRainPainter oldDelegate) => true;
}
