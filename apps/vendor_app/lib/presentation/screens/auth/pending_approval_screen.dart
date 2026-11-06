import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 44),
              ),
              const SizedBox(height: 24),
              Text('Application Under Review', style: AppTextStyles.displayMedium),
              const SizedBox(height: 12),
              const Text(
                'Thank you for registering your clothing store! Our admin team reviews store details and verifies business locations within 24 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 36),
              AppButton(
                label: 'Check Status / Open Portal',
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Return to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
