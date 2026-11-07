import '../../providers/location_provider.dart';
import 'package:core/core.dart';
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
    final location = ref.watch(locationProvider);

    const etaService = DeliveryEtaService();
    final etaMinutes = etaService.estimateMinutes(
      storeLat: 23.0768,
      storeLng: 72.6346,
      customerLat: location.latitude,
      customerLng: location.longitude,
    );
    final distanceKm = etaService.distanceKm(
      lat1: 23.0768,
      lng1: 72.6346,
      lat2: location.latitude,
      lng2: location.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm & Pay'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Whole Ahmedabad Delivery Estimation Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: distanceKm > 8 ? Colors.indigo.shade50 : AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: distanceKm > 8 ? Colors.indigo.shade300 : AppColors.primary.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    distanceKm > 8 ? Icons.explore_rounded : Icons.bolt_rounded,
                    color: distanceKm > 8 ? Colors.indigo.shade800 : AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Estimated ~$etaMinutes Mins Delivery',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: distanceKm > 8 ? Colors.indigo.shade900 : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (distanceKm > 8)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'WHOLE AHMEDABAD',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          distanceKm > 8
                              ? 'Cross-city route from Kubernagar to ${location.areaName} (~${distanceKm.toStringAsFixed(1)} km). Time adjusts dynamically for cross-city traffic (not guaranteed 45 mins).'
                              : 'Hyperlocal delivery to ${location.areaName} (~${distanceKm.toStringAsFixed(1)} km from store • traffic dependent).',
                          style: TextStyle(
                            fontSize: 11,
                            color: distanceKm > 8 ? Colors.indigo.shade800 : AppColors.textSecondary,
                          ),
                        ),
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
              value: 'cod',
              groupValue: _paymentMethod,
              onChanged: _onMethodChanged,
            ),
            const SizedBox(height: 10),

            // 2. Pay on Delivery (UPI / QR)
            _PaymentCard(
              title: 'Pay on Delivery (UPI / QR to Driver)',
              subtitle: 'Scan driver QR via PhonePe, GPay, Paytm on doorstep',
              value: 'payOnDelivery',
              groupValue: _paymentMethod,
              onChanged: _onMethodChanged,
            ),
            const SizedBox(height: 10),

            // 3. Online Payment (Razorpay / Instant)
            _PaymentCard(
              title: 'Online Payment (Razorpay / Cards)',
              subtitle: 'Cards, Netbanking & Wallets • Instant order confirmation',
              value: 'online',
              groupValue: _paymentMethod,
              onChanged: _onMethodChanged,
            ),
            const SizedBox(height: 10),

            // 4. Direct Store Pay
            _PaymentCard(
              title: 'Direct Store Pay',
              subtitle: 'Instant direct settlement to retail store counter',
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
                      value: 'â‚¹21',
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => context.push('/legal'),
                  child: const Text.rich(
                    TextSpan(
                      text: 'By placing order you agree to our ',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'DPDP Privacy, 48h Size Exchange & Terms',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, decoration: TextDecoration.underline),
                        ),
                        TextSpan(text: ' • Grievance: Meet Ratwani'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              AppButton(
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
            ],
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
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _PaymentCard({
    required this.title,
    required this.subtitle,
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
            const SizedBox(width: 8),
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



