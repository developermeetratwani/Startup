import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/core.dart';
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
                MarsHero(eyebrow: 'MARS / Your boutique', title: store.name,
                  description: '${store.location.address.isNotEmpty ? store.location.address : store.location.city} · ${store.rating.toStringAsFixed(1)} stars · ${store.totalRatings} reviews',
                  accent: AppColors.purple, icon: Icons.storefront_outlined),
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
                  subtitle: const Text('09:30 AM - 10:00 PM (Monday - Sunday)'),
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
    final bannerCtrl = TextEditingController(text: store.bannerImageUrl ?? '');
    final cardCtrl = TextEditingController(text: store.logoImageUrl ?? '');

    Future<void> pickPhoto(ImageSource source, TextEditingController target, String folder) async {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (file == null) return;
      try {
        final bytes = await file.readAsBytes();
        const cloudinary = CloudinaryService();
        final (url, failure) = await cloudinary.uploadImageBytes(
          bytes: bytes,
          fileName: '${folder}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          folder: folder,
        );
        if (url != null) {
          target.text = url;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(backgroundColor: AppColors.success, content: Text('✅ Photo uploaded directly to Cloudinary!')),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: AppColors.error, content: Text('Upload failed: ${failure?.message}')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload error: $e')));
        }
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Store & Visiting Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Store Name', hintText: 'e.g. Shreeji Ethnic Studio'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Store Description / Bio'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Shop Banner Field + Camera / Gallery Buttons
              const Text('Shop Main Banner / Front Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined, size: 16),
                      label: const Text('Camera', style: TextStyle(fontSize: 12)),
                      onPressed: () => pickPhoto(ImageSource.camera, bannerCtrl, 'stores'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: const Text('Gallery', style: TextStyle(fontSize: 12)),
                      onPressed: () => pickPhoto(ImageSource.gallery, bannerCtrl, 'stores'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: bannerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Banner URL (Auto-filled on upload)',
                  hintText: 'https://res.cloudinary.com/...',
                  prefixIcon: Icon(Icons.add_photo_alternate_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Visiting Card / Logo Field + Camera / Gallery Buttons
              const Text('Visiting Card / Logo Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined, size: 16),
                      label: const Text('Camera', style: TextStyle(fontSize: 12)),
                      onPressed: () => pickPhoto(ImageSource.camera, cardCtrl, 'cards'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: const Text('Gallery', style: TextStyle(fontSize: 12)),
                      onPressed: () => pickPhoto(ImageSource.gallery, cardCtrl, 'cards'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: cardCtrl,
                decoration: const InputDecoration(
                  labelText: 'Visiting Card URL (Auto-filled on upload)',
                  hintText: 'https://res.cloudinary.com/...',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
            ],
          ),
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
                    bannerImageUrl: bannerCtrl.text.trim(),
                    logoImageUrl: cardCtrl.text.trim(),
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Store photos & profile updated!')),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
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
            Text('Monday – Sunday: 09:30 AM – 10:00 PM'),
            SizedBox(height: 8),
            Text('Orders received outside hours will be queued for the next morning.'),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context, WidgetRef ref, dynamic store) {
    final addressCtrl = TextEditingController(text: store.location.address);
    final cityCtrl = TextEditingController(text: store.location.city);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Store Location Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Store Address / Landmark'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'City / Region'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(vendorStoreRepoProvider).updateStoreProfile(
                    storeId: store.id,
                    name: store.name,
                    description: store.description,
                    address: addressCtrl.text.trim(),
                    city: cityCtrl.text.trim(),
                    bannerImageUrl: store.bannerImageUrl,
                    logoImageUrl: store.logoImageUrl,
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Store location updated!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPlatformTermsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Platform Terms & Settlement',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              const _TermItem(
                title: '10% Platform Commission',
                desc: 'Subtracted from the item subtotal automatically at settlement.',
              ),
              const SizedBox(height: 12),
              const _TermItem(
                title: 'Weekly Payout Settlement',
                desc: 'Paid directly to your linked UPI/Bank account every Monday with unique UTR tracking.',
              ),
              const SizedBox(height: 12),
              const _TermItem(
                title: '48h Local Size Exchange Guarantee',
                desc: 'Customers can exchange unworn garments within 48h for alternate sizes.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Understood'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReferralDialog(BuildContext context, dynamic store) {
    final link = 'https://marsfashion.in/store/${store.id}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Store Share & Referral'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share your digital storefront link with your neighborhood customers:'),
            const SizedBox(height: 12),
            SelectableText(
              link,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied to clipboard!')),
              );
            },
            child: const Text('Copy Link'),
          ),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
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

