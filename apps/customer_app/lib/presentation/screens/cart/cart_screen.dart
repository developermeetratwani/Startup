import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartSummary = ref.watch(cartSummaryProvider);
    final user = ref.watch(currentUserProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);
    final cartRepo = ref.watch(cartRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your shopping bag'),
        actions: [
          if (cartSummary.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await cartRepo.clearCart(user?.uid ?? isolatedGuestSessionId);
                }
              },
            ),
        ],
      ),
      body: cartSummary.items.isEmpty
          ? MarsEmptyState(icon: Icons.shopping_bag_outlined,
              title: 'Room for something lovely.',
              description: 'Your bag is waiting for its first local find. Discover the boutiques around you.',
              actionLabel: 'Explore the neighbourhood', onAction: () => context.go('/home'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery address selector banner
                  AppCard(
                    onTap: () => context.push('/addresses'),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.accent, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedAddress != null ? 'Deliver to ${selectedAddress.label}' : 'Select Delivery Address',
                                style: AppTextStyles.labelLarge,
                              ),
                              Text(
                                selectedAddress != null
                                    ? selectedAddress.fullAddress
                                    : 'Tap to choose or add address',
                                style: AppTextStyles.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_right),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cart Items
                  Text('Order Items (${cartSummary.itemCount})', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 10),
                  ...cartSummary.items.map((item) => _CartItemTile(item: item, userId: user?.uid ?? isolatedGuestSessionId)),

                  const SizedBox(height: 20),

                  // Delivery Tip to Rider (Luxury service touch)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.volunteer_activism_rounded, color: AppColors.accent, size: 18),
                            SizedBox(width: 8),
                            Text('Say thanks with a Tip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('100% of tips go directly to your boutique delivery partner.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final tip in ['₹20', '₹30', '₹50', 'Custom'])
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: tip == '₹30' ? AppColors.accent.withValues(alpha: 0.1) : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: tip == '₹30' ? AppColors.accent : Colors.transparent, width: 1.2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      tip,
                                      style: TextStyle(
                                        color: tip == '₹30' ? AppColors.accent : AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // High-End Bill Summary Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bill Summary', style: AppTextStyles.titleMedium),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('⚡ 15-20 MINS', style: TextStyle(color: Color(0xFF15803D), fontSize: 10, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _BillRow(title: 'Item Total', value: cartSummary.subtotalDisplay),
                        const SizedBox(height: 8),
                        _BillRow(title: 'Packaging & Handling (1%)', value: cartSummary.packagingDisplay),
                        const SizedBox(height: 8),
                        _BillRow(
                          title: 'Hyperlocal Delivery Fee',
                          value: cartSummary.deliveryDisplay,
                          isHighlight: cartSummary.deliveryCharge == 0,
                        ),
                        if (cartSummary.deliveryCharge == 0) ...[
                          const SizedBox(height: 2),
                          const Text(
                            'Free delivery applied (Gold / Promo benefit)',
                            style: TextStyle(fontSize: 10.5, color: AppColors.success, fontWeight: FontWeight.bold),
                          ),
                        ],
                        const Divider(height: 20),
                        _BillRow(
                          title: 'To Pay',
                          value: cartSummary.grandTotalDisplay,
                          isBold: true,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF7F3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEAEAEE)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: Color(0xFF15803D), size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Guaranteed 48h Free Size Exchange at doorstep or in boutique.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: cartSummary.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text(cartSummary.grandTotalDisplay, style: AppTextStyles.price),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: AppButton(
                        label: 'Proceed to Checkout',
                        onPressed: () {
                          if (selectedAddress == null) {
                            AppSnackbar.show(context, message: 'Please select a delivery address first', type: SnackbarType.warning);
                            context.push('/addresses');
                            return;
                          }
                          context.push('/checkout');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItemEntity item;
  final String userId;

  const _CartItemTile({required this.item, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartRepo = ref.watch(cartRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ProductImage(
              imageUrl: item.imageUrl,
              width: 70,
              height: 70,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('Size: ${item.size} • Color: ${item.color}', style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item.lineTotalDisplay, style: AppTextStyles.priceSmall),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () {
                    cartRepo.updateQuantity(
                      customerId: userId,
                      itemId: item.id,
                      quantity: item.quantity - 1,
                    );
                  },
                ),
                Text('${item.quantity}', style: AppTextStyles.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () {
                    cartRepo.updateQuantity(
                      customerId: userId,
                      itemId: item.id,
                      quantity: item.quantity + 1,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;
  final bool isHighlight;

  const _BillRow({
    required this.title,
    required this.value,
    this.isBold = false,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: isBold
                ? AppTextStyles.titleMedium
                : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: isBold
              ? AppTextStyles.titleLarge.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isHighlight ? AppColors.success : AppColors.textPrimary,
                ),
        ),
      ],
    );
  }
}
