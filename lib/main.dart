import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_service.dart';
import 'introduction_screen.dart';
import 'signin_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if user has seen onboarding before
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  
  // Check authentication state
  final isLoggedIn = AuthService.isSignedIn();

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
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    // If user is logged in, go to home
    if (isLoggedIn) {
      return const HomeScreen();
    }
    
    // If user hasn't seen onboarding, show it
    if (!seenOnboarding) {
      return const OnboardingScreen();
    }
    
    // Otherwise show sign in
    return const SignInScreen();
  }
}