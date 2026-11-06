import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/address_provider.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(userAddressesProvider);
    final repo = ref.watch(addressRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_outlined, size: 72, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No addresses saved', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Add an address to get started with local deliveries', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Add New Address',
                    fullWidth: false,
                    onPressed: () => context.push('/addresses/add'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return AppCard(
                child: Row(
                  children: [
                    Icon(
                      addr.isDefault ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: addr.isDefault ? AppColors.primary : AppColors.textHint,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(addr.label, style: AppTextStyles.labelLarge),
                              if (addr.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'DEFAULT',
                                    style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(addr.fullAddress, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) async {
                        if (val == 'default') {
                          await repo.setDefaultAddress(addr.userId, addr.id);
                        } else if (val == 'delete') {
                          await repo.deleteAddress(addr.id);
                        }
                      },
                      itemBuilder: (ctx) => [
                        if (!addr.isDefault)
                          const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/addresses/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }
}
