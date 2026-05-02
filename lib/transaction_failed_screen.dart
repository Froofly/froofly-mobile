import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionFailedScreen extends StatefulWidget {
  const TransactionFailedScreen({super.key});

  @override
  State<TransactionFailedScreen> createState() =>
      _TransactionFailedScreenState();
}

class _TransactionFailedScreenState extends State<TransactionFailedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  int _secondsLeft = 5;
  Timer? _timer;
  Timer? _progressTimer;
  double _progress = 1.0; // 1.0 → 0.0 over 5 seconds

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();

    // Countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        if (mounted) Navigator.of(context).pop();
      }
    });

    // Progress bar timer (updates every 50ms for smooth animation)
    _progressTimer =
        Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() {
        _progress -= 0.05 / 5; // 5 seconds total
        if (_progress < 0) _progress = 0;
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Stack(
        children: [
          // Blurred background overlay
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),

          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 8,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          size: 64,
                          color: Color(0xFFE53935),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Transaction Not Completed',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3436),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'We could not verify a successful payment in your screenshot.\n\nPlease upload a screenshot that shows:\n"Transaction Successful", "Paid to" or "Payment Completed".',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFE53935),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Closing in $_secondsLeft second${_secondsLeft == 1 ? '' : 's'}...',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Dismiss button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Try Again',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
