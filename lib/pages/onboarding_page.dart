import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamawesomesozeith/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation controllers
  late AnimationController _buttonAnimationController;
  late AnimationController _backgroundAnimationController;
  late AnimationController _contentAnimationController;

  // Animations
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _imageAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Welcome to Team Awesome',
      'subtitle': 'Track us effortlessly!',
      'image': 'assets/vectors/cricket.png', // PNG path
      'gradient': const LinearGradient(
        colors: [Color(0xFF4ECDC4), Color(0xFF26A69A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Track Epic Performances',
      'subtitle':
          'Monitor runs wickets and more of your favorite Team Awesomies!',
      'image': 'assets/vectors/cricket.png', // PNG path
      'gradient': const LinearGradient(
        colors: [Color(0xFFFF9A8B), Color(0xFFFF6B6B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Stay Super Informed',
      'subtitle': 'Get the latest stats and updates in real time!',
      'image': 'assets/vectors/cricket.png', // PNG path
      'gradient': const LinearGradient(
        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  @override
  void initState() {
    super.initState();

    // Button animation controller
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
          parent: _buttonAnimationController, curve: Curves.easeInOut),
    );

    // Background animation controller
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _backgroundAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _backgroundAnimationController,
    );

    // Content animation controller
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _imageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start content animation
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimationController.dispose();
    _backgroundAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentAnimationController.reset();
    _contentAnimationController.forward();
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  Widget _buildBackgroundEffect(BuildContext context, LinearGradient gradient) {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(gradient: gradient),
            ),
            // Cricket ball pattern floating in background
            Positioned(
              left: -60 + 40 * math.sin(_backgroundAnimation.value),
              top: 100 + 30 * math.cos(_backgroundAnimation.value),
              child: Opacity(
                opacity: 0.1,
                child: Transform.rotate(
                  angle: _backgroundAnimation.value * 0.2,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Cricket stumps pattern
            Positioned(
              right: -40 + 30 * math.cos(_backgroundAnimation.value * 0.8),
              bottom: 150 + 20 * math.sin(_backgroundAnimation.value * 0.8),
              child: Opacity(
                opacity: 0.08,
                child: Container(
                  width: 120,
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 10,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _buildBackgroundEffect(
              context,
              _onboardingData[_currentPage]['gradient'],
            ),
          ),

          // Main Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              final data = _onboardingData[index];
              return SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cricket PNG with Animation
                    FadeTransition(
                      opacity: _imageAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_imageAnimation),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: const EdgeInsets.all(20),
                          // Use Image.asset instead of SvgPicture.asset
                          child: Image.asset(
                            data['image'],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title with Animation
                    FadeTransition(
                      opacity: _titleAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_titleAnimation),
                        child: Text(
                          data['title'],
                          style: GoogleFonts.montserrat(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Subtitle with Animation
                    FadeTransition(
                      opacity: _subtitleAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_subtitleAnimation),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            data['subtitle'],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom Navigation Bar with Cricket Theme
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: CurvedTopClipper(),
              child: Container(
                height: 130,
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.only(
                  top: 40,
                  bottom: 20,
                  left: 24,
                  right: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip Button
                    GestureDetector(
                      onTapDown: (_) => _buttonAnimationController.forward(),
                      onTapUp: (_) => _buttonAnimationController.reverse(),
                      onTapCancel: () => _buttonAnimationController.reverse(),
                      onTap: _finishOnboarding,
                      child: ScaleTransition(
                        scale: _buttonScaleAnimation,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Cricket Ball Indicators
                    Row(
                      children: List.generate(
                        _onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 10,
                          width: _currentPage == index ? 24 : 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _currentPage == index
                                ? _onboardingData[_currentPage]['gradient']
                                    .colors[1]
                                : Colors.grey[300],
                            border: _currentPage == index
                                ? Border.all(
                                    color: _onboardingData[_currentPage]
                                            ['gradient']
                                        .colors[0]
                                        .withOpacity(0.5),
                                    width: 2,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),

                    // Next/Get Started Button
                    GestureDetector(
                      onTapDown: (_) => _buttonAnimationController.forward(),
                      onTapUp: (_) => _buttonAnimationController.reverse(),
                      onTapCancel: () => _buttonAnimationController.reverse(),
                      onTap: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: ScaleTransition(
                        scale: _buttonScaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: _onboardingData[_currentPage]['gradient'],
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: _onboardingData[_currentPage]['gradient']
                                    .colors[1]
                                    .withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                _currentPage == _onboardingData.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_currentPage < _onboardingData.length - 1)
                                const SizedBox(width: 8),
                              if (_currentPage < _onboardingData.length - 1)
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for curved top of bottom navigation bar
class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      30,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
