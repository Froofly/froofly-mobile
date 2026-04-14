import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_in_screen.dart';
import 'main_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getString('userId') != null;
  
  runApp(KineticApp(isLoggedIn: isLoggedIn));
}

class KineticApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const KineticApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Froofly Rewards',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      // If logged in, go straight to MainScreen, else show SignInScreen
      home: isLoggedIn ? const MainScreen() : const SignInScreen(),
    );
  }
}
