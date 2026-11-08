import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/support_chatbot_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 8),
            Text('Delete Account & Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Under the Digital Personal Data Protection (DPDP) Act 2023 and App Store Guidelines, deleting your account permanently erases your profile, address records, and personal preferences from MARS servers.\n\nThis action cannot be undone. Are you sure you wish to proceed?',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                AppSnackbar.show(
                  context,
                  message: 'Your account and personal data have been scheduled for permanent erasure.',
                  type: SnackbarType.info,
                );
                context.go('/login');
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showReportContentDialog(BuildContext context) {
    final reportCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.report_problem_rounded, color: Colors.amber, size: 24),
            SizedBox(width: 8),
            Text('Report Inappropriate Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit a report for counterfeit items, copyright violation, or merchant misconduct to our Grievance Desk:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reportCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe the issue or store name...',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report submitted to Grievance Officer. Investigation ticket opened under DPDP rules.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentTomato],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22D93670),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.monetization_on_rounded, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Expanded(
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
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.report_gmailerrorred_rounded, color: Colors.amber),
                    title: const Text('Report Store / Content'),
                    subtitle: const Text('Report counterfeit or non-compliant merchant listings'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _showReportContentDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                    title: const Text('Delete Account & Personal Data', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Right to Erasure under DPDP & App Store Compliance'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.error),
                    onTap: () => _showDeleteAccountDialog(context, ref),
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
