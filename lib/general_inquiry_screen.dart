import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class GeneralInquiryScreen extends StatelessWidget {
  const GeneralInquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF9F9F9);
    final textDark = AppTheme.textDark;

    final List<Map<String, String>> faqs = [
      {
        "question": "What is Froofly?",
        "answer":
            "Froofly is a rewards platform where you earn cashback or coins by visiting nearby shops and uploading proof of your purchase. It helps you save money on everyday spending."
      },
      {
        "question": "How does Froofly work?",
        "answer":
            "• Discover nearby offers\n• Visit the store\n• Upload your bill or proof\n• Get rewards after verification"
      },
      {
        "question": "Is Froofly free to use?",
        "answer":
            "Yes, Froofly is completely free for users. You can explore offers, earn rewards, and redeem them without any subscription."
      },
      {
        "question": "How do I earn rewards?",
        "answer":
            "You earn rewards by:\n• Visiting partner stores\n• Uploading valid bills\n• Completing missions or referrals"
      },
      {
        "question": "How long does it take to get rewards?",
        "answer":
            "Rewards are usually verified and credited within a few minutes to a few hours. In some cases, it may take up to 24 hours."
      },
      {
        "question": "What type of proof do I need to upload?",
        "answer":
            "You can upload:\n• A valid bill/receipt\n• Or Payment Screenshots\nMake sure the details are clear and visible."
      },
      {
        "question": "Can I use my rewards anytime?",
        "answer":
            "Yes, you can use your coins or cashback to unlock discounts or redeem offers, based on availability and terms."
      },
      {
        "question": "Why was my reward rejected?",
        "answer":
            "Your reward may be rejected if:\n• The bill is unclear or invalid\n• Duplicate or reused proof is uploaded\n• Store or offer conditions are not met"
      },
      {
        "question": "How does Froofly prevent fraud?",
        "answer":
            "We use verification systems including bill validation, location checks, and activity tracking to ensure rewards are given only for genuine visits."
      },
      {
        "question": "How can I contact support?",
        "answer":
            "You can reach us through:\n• In-app support\n• Email (support@froofly.com)\nWe’re here to help you anytime."
      },
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
          'General Inquiry',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16).copyWith(bottom: 40),
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
