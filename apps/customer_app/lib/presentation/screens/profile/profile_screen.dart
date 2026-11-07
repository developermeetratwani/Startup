import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/support_chatbot_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authRepo = ref.watch(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: [
            // User Avatar & Name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.displayName ?? 'Valued Customer', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(user?.email ?? user?.phone ?? '', style: AppTextStyles.bodySmall),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Store Coins / Referral Rewards Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE94560), Color(0xFFFF6B8A)],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Store Referral Program',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Support your local Kubernagar & Gandhinagar retailers to earn Store Coins',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Navigation tiles
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                    title: const Text('My Orders'),
                    subtitle: const Text('Track and view order history'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => context.push('/orders'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                    title: const Text('Saved Addresses'),
                    subtitle: const Text('Manage delivery addresses'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => context.push('/addresses'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.smart_toy_rounded, color: AppColors.accent),
                    title: const Row(
                      children: [
                        Text('HelpBot AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        CircleAvatar(radius: 3, backgroundColor: Colors.green),
                      ],
                    ),
                    subtitle: const Text('24/7 AI chat for sizing, 48h exchange, COD & orders'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => SupportChatbotSheet.show(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security_rounded, color: AppColors.primary),
                    title: const Text('Privacy, Consent & App Permissions'),
                    subtitle: const Text('DPDP Act 2023, 25 Statutory Protections & Grievance Desk'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => context.push('/legal'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout
            AppButton(
              label: 'Sign Out',
              variant: AppButtonVariant.outline,
              onPressed: () async {
                await authRepo.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
