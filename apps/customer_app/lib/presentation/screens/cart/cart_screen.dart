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
        title: const Text('Shopping Cart'),
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
                if (confirm == true && user != null) {
                  await cartRepo.clearCart(user.uid);
                }
              },
            ),
        ],
      ),
      body: cartSummary.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Explore local clothing stores and add items to your cart',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Browse Stores',
                    fullWidth: false,
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
            )
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
                  ...cartSummary.items.map((item) => _CartItemTile(item: item, userId: user?.uid ?? '')),

                  const SizedBox(height: 20),

                  // Price Breakdown
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bill Summary', style: AppTextStyles.titleMedium),
                        const Divider(height: 20),
                        _BillRow(title: 'Item Total', value: cartSummary.subtotalDisplay),
                        const SizedBox(height: 8),
                        _BillRow(
                          title: 'Delivery Partner Fee',
                          value: cartSummary.deliveryDisplay,
                          isHighlight: cartSummary.deliveryCharge == 0,
                        ),
                        if (cartSummary.deliveryCharge == 0) ...[
                          const SizedBox(height: 2),
                          const Text(
                            'Free delivery applied for orders over ₹999',
                            style: TextStyle(fontSize: 10, color: AppColors.success),
                          ),
                        ],
                        const Divider(height: 20),
                        _BillRow(
                          title: 'To Pay',
                          value: cartSummary.grandTotalDisplay,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomSheet: cartSummary.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
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
                  Text(item.productName, style: AppTextStyles.labelLarge, maxLines: 1),
                  const SizedBox(height: 2),
                  Text('Size: ${item.size} • Color: ${item.color}', style: AppTextStyles.bodySmall),
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
        Text(
          title,
          style: isBold
              ? AppTextStyles.titleMedium
              : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
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
