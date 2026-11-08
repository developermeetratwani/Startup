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
              const SizedBox(height: 48),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 24),
              Text('Retailer Portal', style: AppTextStyles.displayMedium),
              const SizedBox(height: 6),
              Text(
                'Manage your store, orders & inventory across Kubernagar & Gandhinagar',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 36),

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
