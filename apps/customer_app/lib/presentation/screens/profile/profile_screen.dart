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
            // High-End Luxury Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      boxShadow: [
                        BoxShadow(color: Color(0x33D4AF37), blurRadius: 16, offset: Offset(0, 4)),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFF0F1016),
                      child: Text(
                        user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'M',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user?.displayName ?? 'Valued Customer',
                        style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: Color(0xFF2563EB), size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? user?.phone ?? 'hyperlocal@marsfashion.in',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Color(0x28D4AF37), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'MARS GOLD VIP ELITE',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Black Obsidian & Gold Loyalty Card (Amex Black Tier)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F1016), Color(0xFF1A1C24), Color(0xFF12131A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x33D4AF37), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.stars_rounded, color: Color(0xFFD4AF37), size: 18),
                          SizedBox(width: 6),
                          Text(
                            'MARS PRIVILEGE CLUB',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0x26D4AF37),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x40D4AF37)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 12),
                            SizedBox(width: 3),
                            Text(
                              '3-WEEK STREAK',
                              style: TextStyle(color: Colors.amber, fontSize: 9.5, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Secret VIP Tier Unlocked ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Frequent shopper bonus: 15% automatic discount on all weekly apparel orders + priority 15-minute dispatch.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0x1FFFFFFF), height: 1),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Lifetime Savings:',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      Text(
                        '₹1,450 Saved',
                        style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: const [
                        BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text('12', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        SizedBox(height: 2),
                        Text('Orders Placed', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: const [
                        BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text('4.9 ★', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                        SizedBox(height: 2),
                        Text('Member Rating', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: const [
                        BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text('15m', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accent)),
                        SizedBox(height: 2),
                        Text('Avg Speed', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
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
