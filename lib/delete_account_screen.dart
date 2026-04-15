import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'sign_in_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String? _selectedReason;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;

  final List<String> _reasons = [
    "I don't want to use Froofly anymore",
    "I'm using a different account",
    "You are sending me too many notifications",
    "This app is not working properly",
    "Other"
  ];

  Future<void> _deleteAccount() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for leaving.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in or invalid session.');
      }

      final response = await http.delete(
        Uri.parse('https://froofly-backend.onrender.com/auth/account/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reason': _selectedReason,
          'feedback': _feedbackController.text.trim(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Clear all local preferences
        await prefs.clear();
        
        if (!mounted) return;
        
        // Discard all current routes and navigate back to Sign In
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        throw Exception('Failed to delete account from server.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFCF6FB);
    final textDark = AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4C3EE3)),
          onPressed: () {
            if (!_isLoading) Navigator.pop(context);
          },
        ),
        title: Text(
          'Delete Account',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD80B57)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'We\'re sorry to see you go.',
                    style: GoogleFonts.poppins(
                      color: textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please tell us why you are leaving so we can improve our app.',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
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
                      children: _reasons.map((reason) {
                        final isLast = _reasons.last == reason;
                        return Column(
                          children: [
                            RadioListTile<String>(
                              title: Text(
                                reason,
                                style: GoogleFonts.poppins(
                                  color: textDark,
                                  fontSize: 13,
                                ),
                              ),
                              activeColor: const Color(0xFF4C3EE3),
                              value: reason,
                              groupValue: _selectedReason,
                              onChanged: (value) {
                                setState(() {
                                  _selectedReason = value;
                                });
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            if (!isLast)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Share your feedback (Optional)',
                    style: GoogleFonts.poppins(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        hintStyle: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: GoogleFonts.poppins(color: textDark, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDEDF4),
                      foregroundColor: const Color(0xFFD80B57), // Red styling indicating dangerous action
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Delete my account',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }
}
