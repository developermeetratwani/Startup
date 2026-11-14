import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class VendorLoginScreen extends StatefulWidget {
  const VendorLoginScreen({super.key});

  @override
  State<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends State<VendorLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const MarsHero(eyebrow: 'SwiftDrop / Vendor', title: 'Good things.\nStart local.',
                description: 'Your boutique deserves a bigger stage. Welcome to your SwiftDrop merchant studio.', accent: AppColors.purple, icon: Icons.storefront_outlined),
              const MarsSectionHeading(number: '01', title: 'Welcome back', subtitle: 'Sign in to your workspace'),
              AppTextField(
                label: 'Retailer Email / Phone',
                hint: 'e.g. shreeji@fashion.com',
                controller: _emailController,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.lg),

              AppButton(
                label: 'Sign In to Store',
                isLoading: _isLoading,
                onPressed: _login,
              ),
              const SizedBox(height: 20),

              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text("New clothing retailer? "),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      'Register Store',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
