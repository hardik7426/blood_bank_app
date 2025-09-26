import 'package:flutter/material.dart';
import 'package:blood_bank_app/screens/splash/splash_screen.dart';
import 'package:blood_bank_app/screens/splash/splash_screen1.dart';
import 'package:blood_bank_app/screens/splash/splash_screen2.dart';
import 'package:blood_bank_app/screens/auth/login_page.dart';

class SplashScreenManager extends StatefulWidget {
  const SplashScreenManager({super.key});

  @override
  State<SplashScreenManager> createState() => _SplashScreenManagerState();
}

class _SplashScreenManagerState extends State<SplashScreenManager> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: const [
              SplashScreen(),
              SplashScreen1(),
              SplashScreen2(),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Back arrow
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                    onPressed: _currentPageIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeIn,
                            );
                          }
                        : null,
                  ),
                  // Forward arrow
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                    onPressed: () {
                      if (_currentPageIndex < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeIn,
                        );
                      } else {
                        _navigateToLogin(); // Go to login after last splash screen
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}