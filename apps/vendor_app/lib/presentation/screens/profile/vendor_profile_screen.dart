import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/vendor_providers.dart';

class VendorProfileScreen extends ConsumerWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(currentStoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Store Profile & Settings')),
      body: storeAsync.when(
        data: (store) {
          if (store == null) return const Center(child: Text('Store not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Header Card
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
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(store.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(store.location.address.isNotEmpty ? store.location.address : store.location.city, style: AppTextStyles.bodySmall),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                                const SizedBox(width: 4),
                                Text('${store.rating.toStringAsFixed(1)} (${store.totalRatings} reviews)', style: AppTextStyles.labelSmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Settings Section
                Text('Store Configuration', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                  title: const Text('Edit Store Information'),
                  subtitle: const Text('Update store name, description and bio'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showEditStoreDialog(context, ref, store),
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.accent),
                  title: const Text('Location & Address'),
                  subtitle: Text('${store.location.address}, Pincode: ${store.location.pincode}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.access_time_rounded, color: AppColors.textPrimary),
                  title: const Text('Operating Hours'),
                  subtitle: const Text('10:00 AM – 09:30 PM (Mon – Sun)'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.percent_rounded, color: AppColors.warning),
                  title: const Text('Platform Terms'),
                  subtitle: const Text('10% Flat commission on delivered orders'),
                  trailing: const Icon(Icons.info_outline, size: 18),
                  onTap: () {},
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                    onPressed: () {
                      context.go('/login');
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showEditStoreDialog(BuildContext context, WidgetRef ref, dynamic store) {
    final nameCtrl = TextEditingController(text: store.name);
    final descCtrl = TextEditingController(text: store.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Store Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Store Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Store Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(vendorStoreRepoProvider).updateStoreProfile(
                    storeId: store.id,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    address: store.location.address,
                    city: store.location.city,
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
