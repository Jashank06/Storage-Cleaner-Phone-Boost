import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../core/theme/app_theme.dart';
import 'home_screen.dart';

/// Onboarding screen with 3 swipeable slides and Lottie animations
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_ghp9oatf.json', // Cleaning
      title: 'Clean Junk Files',
      description: 'Remove cache, temp files, and free up valuable storage space instantly',
    ),
    _OnboardingPage(
      lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_T6ST7S.json', // Search/Scan
      title: 'Find Duplicates',
      description: 'Detect and remove duplicate photos to save storage without losing memories',
    ),
    _OnboardingPage(
      lottieUrl: 'https://assets10.lottiefiles.com/packages/lf20_kw2m8fvn.json', // Storage/Rocket
      title: 'Free Up Space',
      description: 'Manage large files and WhatsApp media to keep your phone running smooth',
    ),
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _navigateToHome,
                  child: Text(
                    'Skip',
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Get Started / Next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (_currentPage == _pages.length - 1) {
                      _navigateToHome();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 240,
            child: Lottie.network(
              page.lottieUrl,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.cleaning_services_rounded,
                  size: 100,
                  color: AppTheme.neonGreenPrimary.withOpacity(0.3),
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textGrey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index
            ? AppTheme.neonGreenPrimary
            : AppTheme.glassWhite,
      ),
    );
  }
}

class _OnboardingPage {
  final String lottieUrl;
  final String title;
  final String description;
  
  _OnboardingPage({
    required this.lottieUrl,
    required this.title,
    required this.description,
  });
}
