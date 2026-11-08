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

  // Gold Membership Add-on (₹199/month)
  bool _addGoldMembership = false;

  // Scheduled Delivery Slot
  String _deliveryMode = 'instant'; // 'instant' or 'scheduled'
  String _selectedSlot = 'Today, 2:00 PM - 3:00 PM';

  final List<String> _scheduledSlots = [
    'Today, 2:00 PM - 3:00 PM',
    'Today, 4:00 PM - 5:00 PM',
    'Today, 6:00 PM - 7:00 PM',
    'Today, 8:00 PM - 9:00 PM',
    'Tomorrow, 10:00 AM - 11:00 AM',
    'Tomorrow, 2:00 PM - 3:00 PM',
  ];

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

    // Calculate effective grand total factoring Gold membership
    final effectiveDeliveryCharge = _addGoldMembership ? 0 : cartSummary.deliveryCharge;
    final goldFee = _addGoldMembership ? 19900 : 0; // 199 rupees in paise
    final effectiveGrandTotal = cartSummary.subtotal +
        effectiveDeliveryCharge +
        cartSummary.packagingCharge +
        cartSummary.codCharge +
        goldFee;
    final grandTotalDisplay = '₹${(effectiveGrandTotal / 100).toStringAsFixed(0)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm & Pay'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Delivery Estimation Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: distanceKm > 8 ? Colors.indigo.shade50 : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: distanceKm > 8 ? Colors.indigo.shade300 : AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _deliveryMode == 'scheduled' ? Icons.schedule_rounded : (distanceKm > 8 ? Icons.explore_rounded : Icons.bolt_rounded),
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
                            Flexible(
                              child: Text(
                                _deliveryMode == 'scheduled'
                                    ? 'Scheduled for $_selectedSlot'
                                    : 'Estimated ~$etaMinutes Mins Delivery',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: distanceKm > 8 ? Colors.indigo.shade900 : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _deliveryMode == 'scheduled' ? Colors.amber.shade100 : Colors.indigo.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _deliveryMode == 'scheduled' ? 'SCHEDULED' : 'WHOLE AHMEDABAD',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: _deliveryMode == 'scheduled' ? Colors.amber.shade900 : Colors.indigo.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _deliveryMode == 'scheduled'
                              ? 'Rider will be dispatched 20 mins prior for on-time precision arrival at your door.'
                              : (distanceKm > 8
                                  ? 'Cross-city route to ${location.areaName} (~${distanceKm.toStringAsFixed(1)} km). Time adjusts dynamically for traffic.'
                                  : 'Hyperlocal fashion delivery to ${location.areaName} (~${distanceKm.toStringAsFixed(1)} km from store).'),
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

            const SizedBox(height: 18),

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

            const SizedBox(height: 18),

            // ── DELIVERY MODE & SCHEDULING SELECTOR ──────────────────────────
            Text('Delivery Preference', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _deliveryMode = 'instant'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        color: _deliveryMode == 'instant' ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _deliveryMode == 'instant' ? AppColors.primary : AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.bolt_rounded, color: _deliveryMode == 'instant' ? Colors.amber : AppColors.primary, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            'Instant Hyperlocal',
                            style: TextStyle(
                              color: _deliveryMode == 'instant' ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '~15-25 Mins',
                            style: TextStyle(
                              color: _deliveryMode == 'instant' ? Colors.white70 : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _deliveryMode = 'scheduled'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        color: _deliveryMode == 'scheduled' ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _deliveryMode == 'scheduled' ? AppColors.primary : AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.schedule_rounded, color: _deliveryMode == 'scheduled' ? Colors.amber : AppColors.primary, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            'Schedule for Later',
                            style: TextStyle(
                              color: _deliveryMode == 'scheduled' ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Choose time slot',
                            style: TextStyle(
                              color: _deliveryMode == 'scheduled' ? Colors.white70 : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_deliveryMode == 'scheduled') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Your Preferred Time Slot:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _scheduledSlots.map((slot) {
                        final isSelected = _selectedSlot == slot;
                        return ChoiceChip(
                          label: Text(slot, style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          )),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceVariant,
                          onSelected: (val) {
                            if (val) setState(() => _selectedSlot = slot);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            // ── MARS GOLD MEMBERSHIP ADD-ON (₹199/month) ─────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _addGoldMembership ? const Color(0xFFD97706) : const Color(0xFFFDE68A),
                  width: _addGoldMembership ? 2 : 1,
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'MARS Gold Membership',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF92400E)),
                            ),
                            SizedBox(width: 6),
                            Text('₹199/mo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFB45309))),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '⚡ Free delivery on this order • Priority dispatch during peak traffic • VIP support',
                          style: TextStyle(fontSize: 10, color: Color(0xFF78350F), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: _addGoldMembership,
                    activeColor: const Color(0xFFD97706),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _addGoldMembership = val ?? false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                  _PriceRow(
                    title: 'Delivery Charges',
                    value: _addGoldMembership ? 'FREE (Gold Benefit)' : cartSummary.deliveryDisplay,
                    color: _addGoldMembership ? AppColors.success : null,
                  ),
                  if (_addGoldMembership) ...[
                    const SizedBox(height: 8),
                    _PriceRow(
                      title: '👑 MARS Gold Membership (1 Month)',
                      value: '₹199',
                      color: const Color(0xFFD97706),
                    ),
                  ],
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
                      Text(grandTotalDisplay, style: AppTextStyles.price),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
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
                label: _getButtonLabel(grandTotalDisplay),
                isLoading: _isPlacingOrder,
                onPressed: () async {
                  setState(() => _isPlacingOrder = true);

                  final effectiveUserId = user?.uid ?? 'cust-ahmedabad-01';
                  final effectiveStoreId = cartSummary.activeStoreId ?? 'store-kubernagar-1';
                  final effectiveAddressId = selectedAddress?.id ?? 'addr-ahmedabad-01';

                  String? razorpayPaymentId;
                  String? razorpayOrderId;

                  if (_paymentMethod == 'online') {
                    const razorpay = RazorpayService();
                    final paymentResult = await razorpay.openCheckout(
                      amountInPaise: effectiveGrandTotal,
                      orderId: 'ord_${DateTime.now().millisecondsSinceEpoch}',
                      customerName: user?.displayName ?? 'Valued Customer',
                      customerPhone: user?.phone ?? '9898012345',
                      customerEmail: user?.email ?? 'customer@marsfashion.in',
                      storeName: 'MARS Fashion Boutique',
                      description: 'Hyperlocal Fashion Order (${cartSummary.itemCount} items)',
                    );

                    if (paymentResult == null) {
                      setState(() => _isPlacingOrder = false);
                      if (mounted) {
                        AppSnackbar.show(context, message: 'Payment cancelled', type: SnackbarType.warning);
                      }
                      return;
                    }

                    razorpayPaymentId = paymentResult.paymentId;
                    razorpayOrderId = paymentResult.orderId;
                  }

                  final orderRepo = ref.read(orderRepositoryProvider);
                  final (orderId, failure) = await orderRepo.createOrder(
                    customerId: effectiveUserId,
                    storeId: effectiveStoreId,
                    deliveryAddressId: effectiveAddressId,
                    paymentMethod: _paymentMethod,
                    razorpayPaymentId: razorpayPaymentId,
                    razorpayOrderId: razorpayOrderId,
                  );

                  // Record loyalty streak
                  await LoyaltyStreakService.recordOrderForUser(effectiveUserId);

                  // Send animated HTML email receipt via SMTP
                  final customerEmail = user?.email ?? 'developermeetratwani@gmail.com';
                  const smtp = SmtpAuthService();
                  await smtp.sendOrderConfirmationEmail(
                    recipientEmail: customerEmail,
                    customerName: user?.displayName ?? 'Valued Customer',
                    orderId: orderId ?? 'ord-kubernagar-8920',
                    storeName: 'MARS Fashion Boutique',
                    grandTotalPaise: effectiveGrandTotal,
                    etaMinutes: _deliveryMode == 'scheduled' ? 0 : etaMinutes,
                    appName: 'MARS',
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
                    final msg = _deliveryMode == 'scheduled'
                        ? 'Order scheduled for $_selectedSlot! Animated invoice sent to $customerEmail.'
                        : 'Order placed! Assigned to driver partner. Animated invoice sent to $customerEmail.';
                    AppSnackbar.show(context, message: msg, type: SnackbarType.success);
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(color: color ?? AppColors.textPrimary),
        ),
      ],
    );
  }
}
