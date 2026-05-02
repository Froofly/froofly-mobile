import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class MembershipFaqScreen extends StatelessWidget {
  const MembershipFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF9F9F9);

    final faqs = [
      {"question": "What is Froofly Plus / Pro?", "answer": "Froofly Plus and Pro are premium plans that help you earn more rewards and save more money on your everyday spending."},
      {"question": "Why should I upgrade to a paid plan?", "answer": "With a paid plan, you earn higher cashback, access exclusive deals, and get faster rewards — helping you save more than what you pay."},
      {"question": "How much can I actually save with Plus or Pro?", "answer": "- Plus users can save ₹150–₹300/month\n- Pro users can save ₹400–₹800/month\n\nSavings depend on how often you use the app."},
      {"question": "Will I recover my subscription cost?", "answer": "Yes. Most users recover their plan cost within 3-5 Claims, depending on spending."},
      {"question": "What is the difference between Free, Plus, and Pro?", "answer": "- Free: Basic rewards and limited access\n- Plus: Higher rewards + premium deals\n- Pro: Maximum rewards + VIP offers + unlimited access"},
      {"question": "What does “extra coins” or “multiplier” mean?", "answer": "It means you earn more rewards on every bill compared to free users.\n\nExample:\n- Free user → ₹20 reward\n- Pro user → ₹40 reward"},
      {"question": "What is the joining bonus?", "answer": "When you subscribe:\n- Plus → Get ₹100 coins\n- Pro → Get ₹250 coins\n\nThis gives you instant value."},
      {"question": "Can I cancel my subscription anytime?", "answer": "Yes, you can cancel anytime. Your benefits will continue until the end of your billing cycle."},
      {"question": "What happens if I don’t use the app much?", "answer": "You may not fully utilize the benefits. The plans are best suited for users who frequently visit shops and use offers."},
      {"question": "Are there any hidden charges?", "answer": "No. Froofly plans are transparent. You only pay the subscription fee — no hidden costs."},
      {"question": "Will my rewards expire?", "answer": "Some rewards or coins may have an expiry period. You’ll be notified before they expire."},
      {"question": "How do I upgrade or downgrade my plan?", "answer": "- You can upgrade or change your plan anytime from the Profile → Membership section."},
      {"question": "Do I get priority support in Pro plan?", "answer": "Yes. Pro users get faster response and priority assistance from our support team."},
      {"question": "Is Froofly safe for payments and subscriptions?", "answer": "Yes. We use secure payment gateways to ensure your transactions are safe and protected."}
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A3D62)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Froofly Membership',
          style: GoogleFonts.poppins(
            color: const Color(0xFF0A3D62),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16).copyWith(bottom: 40),
        children: [
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.poppins(
              color: AppTheme.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => _buildFaqCard(faq['question']!, faq['answer']!)).toList(),
        ],
      ),
    );
  }

  Widget _buildFaqCard(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: const Color(0xFF0A3D62),
          iconColor: const Color(0xFF0A3D62),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              fontSize: 14,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
