import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'introduction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if user has seen onboarding before
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(MyApp(
    seenOnboarding: seenOnboarding,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  final bool isLoggedIn;
  
  const MyApp({
    super.key, 
    required this.seenOnboarding,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F5FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 66, 63, 248),
          brightness: Brightness.light,
        ),
      ),
      // Always show onboarding first
      home: const OnboardingScreen(),
    );
  }
}