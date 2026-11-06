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
  String _paymentMethod = 'cod';
  bool _isPlacingOrder = false;

  void _onMethodChanged(String method) {
    setState(() => _paymentMethod = method);
    final enumMethod = switch (method) {
      'payOnDelivery' => PaymentMethod.payOnDelivery,
      'online' => PaymentMethod.payOnline,
      'directPay' => PaymentMethod.directPay,
      _ => PaymentMethod.cod,
    };
    ref.read(selectedPaymentMethodProvider.notifier).state = enumMethod;
  }

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
            // Hyperlocal Delivery Promise
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.primary.withOpacity(0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: AppColors.primary, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guaranteed 35-45 Mins Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Dispatched from local partner store directly to your location', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Delivery Address Card
            Text('Delivering to', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selectedAddress?.label ?? 'Delivery Address', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 2),
                        Text(
                          selectedAddress?.fullAddress ?? 'B-42, Krishna Park Colony, Kubernagar Main Bazar, Ahmedabad',
                          style: AppTextStyles.bodySmall,
                        ),
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

            // Payment Options
            Text('Payment Method', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),

            // 1. Cash on Delivery (COD)
            _PaymentCard(
              title: 'Cash on Delivery (COD)',
              subtitle: 'Pay cash to driver upon delivery • ₹21 handling surcharge',
              icon: Icons.money_rounded,
              color: AppColors.success,
              value: 'cod',
              groupValue: _paymentMethod,
              onChanged: _onMethodChanged,
            ),
            const SizedBox(height: 10),

            // 2. Pay on Delivery (UPI / QR)
            _PaymentCard(
              title: 'Pay on Delivery (UPI / QR to Driver)',
              subtitle: 'Scan driver QR via PhonePe, GPay, Paytm on doorstep',
              icon: Icons.qr_code_scanner_rounded,
              color: AppColors.primary,
              value: 'payOnDelivery',
              groupValue: _paymentMethod,
              onChanged: _onMethodChanged,
            ),
            const SizedBox(height: 10),

            // 3. Online Payment (Razorpay / Instant)
            _PaymentCard(
              title: 'Online Payment (Razorpay / Cards)',
              subtitle: 'Cards, Netbanking & Wallets • Instant order confirmation',
              icon: Icons.credit_card_rounded,
              color: AppColors.accent,
              value: 'online',
              groupValue: _paymentMethod,
              onChanged: _onMethodChanged,
            ),
            const SizedBox(height: 10),

            // 4. Direct Store Pay
            _PaymentCard(
              title: 'Direct Store Pay',
              subtitle: 'Instant direct settlement to retail store counter',
              icon: Icons.account_balance_rounded,
              color: AppColors.warning,
              value: 'directPay',
              groupValue: _paymentMethod,
              onChanged: _onMethodChanged,
            ),

            const SizedBox(height: 24),

            // Bill Breakdown
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detailed Bill Breakdown', style: AppTextStyles.titleMedium),
                  const Divider(height: 16),
                  _PriceRow(title: 'Item Total (${cartSummary.itemCount} items)', value: cartSummary.subtotalDisplay),
                  const SizedBox(height: 8),
                  _PriceRow(
                    title: 'Packaging & Handling (1%)',
                    value: cartSummary.packagingDisplay,
                    subtitle: 'Eco-friendly fashion packaging',
                  ),
                  const SizedBox(height: 8),
                  _PriceRow(title: 'Delivery Charges', value: cartSummary.deliveryDisplay),
                  if (_paymentMethod == 'cod') ...[
                    const SizedBox(height: 8),
                    _PriceRow(
                      title: 'Cash on Delivery Handling Fee',
                      value: '₹21',
                      color: AppColors.primary,
                    ),
                  ],
                  const Divider(height: 20),
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
            label: _getButtonLabel(cartSummary.grandTotalDisplay),
            isLoading: _isPlacingOrder,
            onPressed: () async {
              setState(() => _isPlacingOrder = true);

              final effectiveUserId = user?.uid ?? 'cust-ahmedabad-01';
              final effectiveStoreId = cartSummary.activeStoreId ?? 'store-kubernagar-1';
              final effectiveAddressId = selectedAddress?.id ?? 'addr-ahmedabad-01';

              final orderRepo = ref.read(orderRepositoryProvider);
              final (orderId, failure) = await orderRepo.createOrder(
                customerId: effectiveUserId,
                storeId: effectiveStoreId,
                deliveryAddressId: effectiveAddressId,
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
              await ref.read(cartRepositoryProvider).clearCart(effectiveUserId);

              if (mounted) {
                AppSnackbar.show(context, message: 'Order placed successfully! Assigned to driver partner.', type: SnackbarType.success);
                context.go('/orders/track/${orderId ?? 'ord-kubernagar-8920'}');
              }
            },
          ),
        ),
      ),
    );
  }

  String _getButtonLabel(String grandTotalDisplay) {
    return switch (_paymentMethod) {
      'cod' => 'Place Order (Pay $grandTotalDisplay on Delivery)',
      'payOnDelivery' => 'Confirm Order (Pay $grandTotalDisplay via QR)',
      'directPay' => 'Pay $grandTotalDisplay to Store',
      _ => 'Pay $grandTotalDisplay Online',
    };
  }
}

class _PaymentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _PaymentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: AppColors.primary,
              onChanged: (val) => onChanged(val!),
            ),
            const SizedBox(width: 4),
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLarge),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? color;

  const _PriceRow({
    required this.title,
    required this.value,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.bodyMedium),
            if (subtitle != null)
              Text(subtitle!, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(color: color ?? AppColors.textPrimary),
        ),
      ],
    );
  }
}
