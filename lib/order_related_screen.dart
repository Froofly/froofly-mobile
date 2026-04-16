import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class OrderRelatedScreen extends StatelessWidget {
  const OrderRelatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFCF6FB);
    final textDark = AppTheme.textDark;

    final List<Map<String, String>> faqs = [
      {
        "question": "How do I claim an offer?",
        "answer": "Open the app → select a nearby offer → click \"Claim\"."
      },
      {
        "question": "Where do I find the Claim?",
        "answer": "Go to Profile → Click on \"Orders\"."
      },
      {
        "question": "Do I need to claim the offer before visiting the store?",
        "answer":
            "Yes, it's recommended to tap \"Claim\" before making the payment to ensure the offer is tracked properly."
      },
      {
        "question": "Can I claim multiple offers in a day?",
        "answer":
            "Yes, but it depends on:\n• Daily claim limits\n• Offer-specific conditions\n\nSome offers may have restrictions."
      },
      {
        "question": "What happens after I upload the bill?",
        "answer":
            "Your submission goes through a verification process. Once approved, your reward or coins will be added to your wallet."
      },
      {
        "question": "How do I know if my claim is approved?",
        "answer":
            "You will receive:\n• In-app notification\n• Pop Screen with coins count\n• Wallet update"
      },
      {
        "question": "Why is my claim still pending?",
        "answer":
            "Claims may take time due to:\n• High traffic\n• Manual verification\n• Image clarity check\n\nUsually resolved within a few hours (max 24 hours)."
      },
      {
        "question": "Why was my claim rejected?",
        "answer":
            "Common reasons:\n• Blurry or unclear bill\n• Duplicate upload\n• Offer conditions not met\n• Wrong store or location"
      },
      {
        "question": "Can I reuse the same bill for multiple claims?",
        "answer":
            "No. Each bill can be used only once. Duplicate claims will be rejected."
      },
      {
        "question": "Is there a minimum bill amount to claim rewards?",
        "answer": "No, there is no minimum bill amount required."
      },
      {
        "question": "How many times can I claim the same offer?",
        "answer":
            "It depends on the offer:\n• Some are one-time only\n• Some can be used multiple times with limits"
      },
      {
        "question": "What if the shop denies the offer?",
        "answer":
            "Show the offer in the app. If the issue continues, report it via support and we'll resolve it."
      },
      {
        "question": "Can I cancel a claim after submission?",
        "answer":
            "No, once submitted, claims cannot be edited or cancelled."
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4C3EE3)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Related',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
            .copyWith(bottom: 40),
        itemCount: faqs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return _buildFaqCard(faq['question']!, faq['answer']!);
        },
      ),
    );
  }

  Widget _buildFaqCard(String question, String answer) {
    return Container(
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
          collapsedIconColor: const Color(0xFF4C3EE3),
          iconColor: const Color(0xFF4C3EE3),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
