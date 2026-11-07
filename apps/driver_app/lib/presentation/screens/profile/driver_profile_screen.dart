import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/driver_providers.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(driverProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rider Profile & KYC')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: [
            // Driver Avatar Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${profile.vehicleType} • ${profile.cluster}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(profile.phone, style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 1. Vehicle Information
            ListTile(
              leading: const Icon(Icons.two_wheeler_rounded, color: AppColors.primary),
              title: const Text('Vehicle Information'),
              subtitle: Text('${profile.vehicleModel} • ${profile.vehicleRegNo}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showVehicleDialog(context, ref, profile),
            ),
            const Divider(),

            // 2. KYC & Identity Verification (Aadhaar & Electricity Bill)
            ListTile(
              leading: const Icon(Icons.badge_rounded, color: AppColors.accent),
              title: const Text('Aadhaar KYC & Anti-Theft Verification'),
              subtitle: Text('Aadhaar: ${profile.aadhaarNumber} • ${profile.isVerified ? "Verified ✅" : "Pending"}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showKycDialog(context, ref, profile),
            ),
            const Divider(),

            // 3. Active Delivery Clusters
            ListTile(
              leading: const Icon(Icons.location_city_rounded, color: AppColors.warning),
              title: const Text('Active Delivery Clusters'),
              subtitle: Text(profile.cluster),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showClusterDialog(context, ref, profile),
            ),
            const Divider(),

            // 4. Rider Support & Help
            ListTile(
              leading: const Icon(Icons.support_agent_rounded, color: AppColors.info),
              title: const Text('Rider Support & Emergency Helpline'),
              subtitle: const Text('24x7 Dedicated delivery assistance'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showSupportDialog(context),
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

  void _showVehicleDialog(BuildContext context, WidgetRef ref, DriverProfileState profile) {
    final modelCtrl = TextEditingController(text: profile.vehicleModel);
    final regCtrl = TextEditingController(text: profile.vehicleRegNo);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vehicle Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=300'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelCtrl,
              decoration: const InputDecoration(labelText: 'Vehicle Model (e.g. Activa 6G / Splendor)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: regCtrl,
              decoration: const InputDecoration(labelText: 'Registration Number (e.g. GJ-01-AB-1234)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(driverProfileProvider.notifier).state = profile.copyWith(
                vehicleModel: modelCtrl.text.trim(),
                vehicleRegNo: regCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vehicle information updated!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showKycDialog(BuildContext context, WidgetRef ref, DriverProfileState profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Identity & Anti-Theft Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To prevent theft and protect customer deliveries, every rider undergoes mandatory Aadhaar & address verification.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            _DocRow(title: 'Aadhaar Card', value: profile.aadhaarNumber, status: 'Verified ✅'),
            const SizedBox(height: 8),
            _DocRow(title: 'Electricity Bill', value: profile.electricityBillProvider, status: 'Verified ✅'),
            const SizedBox(height: 8),
            const _DocRow(title: 'Driving License', value: 'GJ01-20210045678', status: 'Active ✅'),
            const SizedBox(height: 8),
            const _DocRow(title: 'Police Clearance', value: 'Anti-Theft Check', status: 'Clean Record ✅'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showClusterDialog(BuildContext context, WidgetRef ref, DriverProfileState profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Delivery Cluster'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Kubernagar & East Ahmedabad'),
              subtitle: const Text('12 km delivery radius • Clothing retail corridor'),
              onTap: () {
                ref.read(driverProfileProvider.notifier).state = profile.copyWith(cluster: 'Kubernagar & East Ahmedabad');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Gandhinagar Capital Region'),
              subtitle: const Text('15 km delivery radius • Handlooms & Khadi'),
              onTap: () {
                ref.read(driverProfileProvider.notifier).state = profile.copyWith(cluster: 'Gandhinagar Capital Region');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Sindhu Bhavan & Bodakdev (West Ahmedabad)'),
              subtitle: const Text('20 km cross-city radius • SBR, SG Highway & Prahlad Nagar'),
              onTap: () {
                ref.read(driverProfileProvider.notifier).state = profile.copyWith(cluster: 'Sindhu Bhavan & Bodakdev (West Ahmedabad)');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('24x7 Delivery Partner Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partner Helpline: +91 79 2281 9000'),
            SizedBox(height: 6),
            Text('Email: rider-help@hyperlocalfashion.in'),
            SizedBox(height: 12),
            Text('Live roadside assistance and insurance claims support is active during all online duty hours.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  final String title;
  final String value;
  final String status;

  const _DocRow({required this.title, required this.value, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Text(status, style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
