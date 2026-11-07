import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'customer@hyperlocalfashion.in');
  final _passwordController = TextEditingController(text: 'Customer@123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login({String? email, String? password}) async {
    final targetEmail = email ?? _emailController.text.trim();
    final targetPass = password ?? _passwordController.text.trim();

    if (email == null && !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final (user, failure) = await authRepo.signInWithEmail(
        email: targetEmail,
        password: targetPass,
      );

      setState(() => _isLoading = false);

      if (failure != null) {
        if (mounted) {
          AppSnackbar.show(context, message: failure.message, type: SnackbarType.error);
        }
        return;
      }

      if (mounted) {
        AppSnackbar.show(context, message: 'Welcome back, ${user?.displayName ?? 'Customer'}!', type: SnackbarType.success);
        context.go('/home');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppSnackbar.show(context, message: 'Sign in error: $e', type: SnackbarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),
                // Header
                Text('Welcome back 👋', style: AppTextStyles.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Sign in to explore clothing stores across all Ahmedabad (Sindhu Bhavan, Bodakdev, Kubernagar & Gandhinagar)',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                // Email field
                AppTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Password field
                AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      AppSnackbar.show(context, message: 'Password reset link simulated to ${_emailController.text}');
                    },
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Login button
                AppButton(
                  label: 'Sign In',
                  onPressed: () => _login(),
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 12),

                // Quick Demo Sign In
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    icon: const Icon(Icons.bolt_rounded, color: AppColors.primary),
                    label: const Text('1-Tap Quick Demo Customer Login', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    onPressed: () => _login(
                      email: 'meet@hyperlocalfashion.in',
                      password: 'Customer@123',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
