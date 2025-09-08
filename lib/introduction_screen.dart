import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'signin_screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInScreen()), // Changed to SignInScreen
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Widget _buildPage({
    required String title,
    required String description,
    required String imagePath,
    required String buttonText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 80), // Space from top
          
          // Image placeholder (using Icon since assets might not exist)
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 253, 253, 253).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.business,
                  size: 150,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 12, 10, 101),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // CTA Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: const Color.fromARGB(255, 66, 63, 248),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _nextPage,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Top title
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Text(
                'Elevate Your Business',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 12, 10, 101)
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // PageView content
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildPage(
                  title: 'Grow With Us',
                  description: 'Grow your business with our all new app, you can have all the features you want right at your fingertips',
                  imagePath: 'assets/images/1.png',
                  buttonText: "Let's Go",
                ),
                _buildPage(
                  title: 'Shape Your Product',
                  description: 'Shape your product the way you want, you can have all the customizations you want, just the way you like it',
                  imagePath: 'assets/images/2.png',
                  buttonText: "Why to wait!",
                ),
                _buildPage(
                  title: 'Earn Customers Love',
                  description: 'Earn your customers love by providing them the best experience, and keep them coming back for more',
                  imagePath: 'assets/images/3.png',
                  buttonText: "Let's Start",
                ),
              ],
            ),

            // Bottom navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: _finish,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Page indicator
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: 3,
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                          dotColor: Color.fromARGB(255, 138, 169, 255), // Blue inactive
                          activeDotColor: Color.fromARGB(255, 35, 19, 255), // Red active
                        ),
                      ),

                      // Next/Done button
                      _currentPage == 2
                          ? TextButton(
                              onPressed: _finish,
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: _nextPage,
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF666666),
                                size: 18,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}