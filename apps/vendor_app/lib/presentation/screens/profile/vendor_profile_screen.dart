import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

                // 1. Edit Store Info
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                  title: const Text('Edit Store Information'),
                  subtitle: const Text('Update store name, description and bio'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showEditStoreDialog(context, ref, store),
                ),
                const Divider(),

                // 2. Location & Cluster
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.accent),
                  title: const Text('Location & Multi-Region Cluster'),
                  subtitle: Text('${store.location.address}, ${store.location.city} (${store.location.pincode})'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showLocationDialog(context, ref, store),
                ),
                const Divider(),

                // 3. Operating Hours
                ListTile(
                  leading: const Icon(Icons.access_time_rounded, color: AppColors.textPrimary),
                  title: const Text('Operating Hours'),
                  subtitle: const Text('09:30 AM – 10:00 PM (Monday – Sunday)'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showOperatingHoursDialog(context),
                ),
                const Divider(),

                // 4. Platform Terms
                ListTile(
                  leading: const Icon(Icons.receipt_long_rounded, color: AppColors.warning),
                  title: const Text('Platform Terms & Commissions'),
                  subtitle: const Text('10% Flat commission • 1% Packaging • 48h size exchange'),
                  trailing: const Icon(Icons.info_outline, size: 18),
                  onTap: () => _showPlatformTermsSheet(context),
                ),
                const Divider(),

                // 5. Store Referral & Affiliate Link
                ListTile(
                  leading: const Icon(Icons.share_rounded, color: AppColors.success),
                  title: const Text('Store Referral & Affiliate Link'),
                  subtitle: const Text('Share your store link with local customers for bonus Store Coins'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showReferralDialog(context, store),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Store profile updated!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context, WidgetRef ref, dynamic store) {
    final addrCtrl = TextEditingController(text: store.location.address);
    final pinCtrl = TextEditingController(text: store.location.pincode);
    String selectedCity = store.location.city.isNotEmpty ? store.location.city : 'Ahmedabad';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Location & Region Cluster'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: ['Ahmedabad', 'Gandhinagar', 'Vapi'].contains(selectedCity) ? selectedCity : 'Ahmedabad',
                decoration: const InputDecoration(labelText: 'Market Cluster City'),
                items: const [
                  DropdownMenuItem(value: 'Ahmedabad', child: Text('Kubernagar & East Ahmedabad')),
                  DropdownMenuItem(value: 'Gandhinagar', child: Text('Gandhinagar Capital Region')),
                  DropdownMenuItem(value: 'Vapi', child: Text('Vapi Industrial & Silk Corridor')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedCity = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(labelText: 'Street / Market Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinCtrl,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(vendorStoreRepoProvider).updateStoreProfile(
                      storeId: store.id,
                      name: store.name,
                      description: store.description,
                      address: addrCtrl.text.trim(),
                      city: selectedCity,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location & Region updated successfully!')),
                );
              },
              child: const Text('Save Location'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOperatingHoursDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Operating Hours'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stores that stay open consistently receive 3x more order dispatches from nearby shoppers.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Opening Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('09:30 AM', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Closing Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('10:00 PM', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Working Days:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Monday to Sunday', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }

  void _showPlatformTermsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Platform Terms & Commission Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 14),
            const _TermItem(
              title: '10% Platform Commission',
              desc: 'Only charged on successfully delivered orders. No hidden onboarding or monthly listing fees.',
            ),
            const SizedBox(height: 12),
            const _TermItem(
              title: '1% Eco Packaging & Handling',
              desc: 'Collected on each quantity to support sustainable retail clothing bags and protective covers.',
            ),
            const SizedBox(height: 12),
            const _TermItem(
              title: '₹21 Cash on Delivery Handling',
              desc: 'Covers cash collection, safe transport, and T+2 settlement to your verified merchant bank account.',
            ),
            const SizedBox(height: 12),
            const _TermItem(
              title: '48-Hour Local Size Exchange',
              desc: 'Shoppers can exchange sizes within 48 hours. A driver handles the replacement directly from your shelf.',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('I Understand & Agree'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReferralDialog(BuildContext context, dynamic store) {
    final link = 'https://hyperlocalfashion.in/store/${store.id}?ref=KUBER50';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Store Affiliate & Referral Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share your store link with customers in your neighborhood. When they place orders, you earn bonus Store Coins to offset commission fees.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                link,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Link'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Affiliate link copied to clipboard!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  final String title;
  final String desc;

  const _TermItem({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
