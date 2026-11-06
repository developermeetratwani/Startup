import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _paymentMethod = 'cod'; // 'cod' or 'online'
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final cartSummary = ref.watch(cartSummaryProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm & Pay'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Card
            Text('Delivering to', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.home_outlined, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selectedAddress?.label ?? 'Address', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 2),
                        Text(selectedAddress?.fullAddress ?? '', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/addresses'),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Methods
            Text('Payment Option', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),

            // Cash on Delivery
            AppCard(
              onTap: () => setState(() => _paymentMethod = 'cod'),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'cod',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.money_rounded, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cash on Delivery (COD)', style: AppTextStyles.labelLarge),
                        Text('Pay upon delivery to our partner', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Online Payment (Razorpay / UPI / Cards)
            AppCard(
              onTap: () => setState(() => _paymentMethod = 'online'),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'online',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.payment_rounded, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Online Payment (UPI / Cards)', style: AppTextStyles.labelLarge),
                        Text('Powered by Razorpay • Instant confirmation', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Order Breakdown
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Breakdown', style: AppTextStyles.titleMedium),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal (${cartSummary.itemCount} items)', style: AppTextStyles.bodyMedium),
                      Text(cartSummary.subtotalDisplay, style: AppTextStyles.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery Charges', style: AppTextStyles.bodyMedium),
                      Text(cartSummary.deliveryDisplay, style: AppTextStyles.labelLarge),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Grand Total', style: AppTextStyles.titleMedium),
                      Text(cartSummary.grandTotalDisplay, style: AppTextStyles.price),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: AppButton(
            label: _paymentMethod == 'cod' ? 'Place Order (Cash on Delivery)' : 'Pay ${cartSummary.grandTotalDisplay}',
            isLoading: _isPlacingOrder,
            onPressed: () async {
              if (user == null || selectedAddress == null || cartSummary.activeStoreId == null) {
                AppSnackbar.show(context, message: 'Invalid order state', type: SnackbarType.error);
                return;
              }

              setState(() => _isPlacingOrder = true);

              final orderRepo = ref.read(orderRepositoryProvider);
              final (orderId, failure) = await orderRepo.createOrder(
                customerId: user.uid,
                storeId: cartSummary.activeStoreId!,
                deliveryAddressId: selectedAddress.id,
                paymentMethod: _paymentMethod,
              );

              setState(() => _isPlacingOrder = false);

              if (failure != null) {
                if (mounted) {
                  AppSnackbar.show(context, message: failure.message, type: SnackbarType.error);
                }
                return;
              }

              // Clear cart after successful order
              await ref.read(cartRepositoryProvider).clearCart(user.uid);

              if (mounted) {
                AppSnackbar.show(context, message: 'Order placed successfully!', type: SnackbarType.success);
                context.go('/orders/track/${orderId ?? ''}');
              }
            },
          ),
        ),
      ),
    );
  }
}
