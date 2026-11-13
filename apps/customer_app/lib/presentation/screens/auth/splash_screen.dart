import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.go('/home');
        return;
      }
    } catch (e) {
      debugPrint('Auth check skipped (preview mode): $e');
    }

    // Default to /home for immediate browsing experience
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: MediaQuery.disableAnimationsOf(context) ? const AlwaysStoppedAnimation(1) : _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentTomato],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33D93670),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'MARS',
                style: TextStyle(
                  color: AppColors.linen,
                  fontSize: 46,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 10,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fashion from your neighbourhood',
                style: TextStyle(
                  color: AppColors.linen.withValues(alpha: 0.7),
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
