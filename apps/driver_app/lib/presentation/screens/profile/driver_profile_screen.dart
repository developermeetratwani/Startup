import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rider Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: [
            // Avatar card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Suresh Solanki', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Two-Wheeler Partner • Kubernagar Cluster', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('+91 98980 12345', style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            ListTile(
              leading: const Icon(Icons.two_wheeler_rounded, color: AppColors.primary),
              title: const Text('Vehicle Information'),
              subtitle: const Text('Honda Activa 6G • GJ-01-AB-1234'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.badge_rounded, color: AppColors.accent),
              title: const Text('Driving License & Documents'),
              subtitle: const Text('Verified by Admin ✅'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.location_city_rounded, color: AppColors.warning),
              title: const Text('Active Delivery Clusters'),
              subtitle: const Text('Kubernagar (East Ahmedabad) & Gandhinagar'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.support_agent_rounded, color: AppColors.info),
              title: const Text('Rider Support & Help'),
              subtitle: const Text('24x7 Emergency delivery assistance'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                onPressed: () => context.go('/login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
