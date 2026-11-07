import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/driver_providers.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(driverDutyProvider);
    final activeDelivery = ref.watch(activeDeliveryProvider);
    final earningsAsync = ref.watch(driverEarningsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery Partner', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            Text(
              isOnline ? 'Online • Ready for orders' : 'Offline • On Break',
              style: TextStyle(
                color: isOnline ? AppColors.success : AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.pagePadding),
            child: Transform.scale(
              scale: 0.9,
              child: Switch(
                value: isOnline,
                activeColor: AppColors.success,
                onChanged: (val) {
                  ref.read(driverDutyProvider.notifier).state = val;
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duty Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: isOnline ? AppColors.success : AppColors.error),
              ),
              child: Row(
                children: [
                  Icon(
                    isOnline ? Icons.two_wheeler_rounded : Icons.bed_rounded,
                    color: isOnline ? AppColors.success : AppColors.error,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'Ready for Deliveries' : 'You are Currently Offline',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          isOnline
                              ? 'Operating in Kubernagar & Gandhinagar'
                              : 'Go online to receive nearby store delivery requests',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Today's Earnings Snapshot
            earningsAsync.when(
              data: (e) => Row(
                children: [
                  Expanded(
                    child: _MiniCard(
                      title: "Today's Pay",
                      value: e.todayEarningsDisplay,
                      icon: Icons.currency_rupee_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniCard(
                      title: 'Trips Completed',
                      value: '${e.todayDeliveries}',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniCard(
                      title: 'Rating',
                      value: '${e.rating} ★',
                      icon: Icons.star_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Active / Assigned Delivery Card
            Text('Current Assignment', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),

            if (!isOnline)
              _buildOfflineState()
            else if (activeDelivery == null)
              _buildWaitingRadar()
            else
              _ActiveDeliveryCard(delivery: activeDelivery),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.power_settings_new_rounded, size: 48, color: AppColors.textHint),
            SizedBox(height: 12),
            Text('Turn online switch ON', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Delivery requests will appear when you are available', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingRadar() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const Center(
        child: Column(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            ),
            SizedBox(height: 16),
            Text('Searching for nearby store orders...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(height: 4),
            Text('Scanning Kubernagar & Gandhinagar clothing hubs', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActiveDeliveryCard extends ConsumerWidget {
  final DeliveryEntity delivery;

  const _ActiveDeliveryCard({required this.delivery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = delivery.status;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Delivery Fee: ₹${(delivery.deliveryFee / 100).toStringAsFixed(0)}',
                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.name.toUpperCase(),
                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Payment Type Indicator (COD vs Online Prepaid)
          _buildPaymentBanner(delivery.orderId),

          const Divider(height: 24),

          // Pickup Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PICKUP FROM STORE', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('Shreeji Ethnic & Bridal Studio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text('Main Bazaar, Kubernagar, Ahmedabad', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _launchGoogleMaps(
                        context: context,
                        lat: delivery.pickupLat,
                        lng: delivery.pickupLng,
                        label: 'Shreeji Ethnic & Bridal Studio, Kubernagar',
                      ),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_rounded, size: 16, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text('Google Maps Navigation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: SizedBox(
              height: 20,
              child: VerticalDivider(color: AppColors.divider, thickness: 1.5),
            ),
          ),

          // Drop Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DELIVER TO CUSTOMER', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('Kavya Sharma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text('Block C-4, Krishna Complex, Kubernagar', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _launchGoogleMaps(
                        context: context,
                        lat: delivery.dropLat,
                        lng: delivery.dropLng,
                        label: 'Kavya Sharma, Block C-4, Krishna Complex, Kubernagar',
                      ),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.near_me_rounded, size: 16, color: AppColors.accent),
                            SizedBox(width: 6),
                            Text('Google Maps Navigation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action Workflow Stepper Button
          _buildActionButton(context, ref, status),
        ],
      ),
    );
  }

  Future<void> _launchGoogleMaps({
    required BuildContext context,
    required double lat,
    required double lng,
    required String label,
  }) async {
    // Universal 100% free Google Maps navigation deep link
    final urlString = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=${Uri.encodeComponent(label)}';
    final uri = Uri.parse(urlString);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Opening Google Maps navigation to $label...'),
          ),
        );
      }
    }
  }

  Widget _buildPaymentBanner(String orderId) {
    final order = OrderSyncService.currentOrders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => OrderEntity(
        id: orderId,
        customerId: '',
        storeId: '',
        vendorId: '',
        deliveryAddressId: '',
        deliveryAddressSnapshot: const {},
        status: OrderStatus.readyForPickup,
        paymentMethod: PaymentMethod.cod,
        paymentStatus: PaymentStatus.pending,
        pricing: const OrderPricing(
          productTotal: 89900,
          deliveryCharge: 2500,
          grandTotal: 95399,
          platformCommission: 8990,
          vendorEarning: 80910,
          driverEarning: 4500,
        ),
        placedAt: DateTime.now(),
      ),
    );

    final isCod = order.paymentMethod == PaymentMethod.cod;
    final amountText = '₹${(order.pricing.grandTotal / 100).toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCod ? Colors.amber.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isCod ? Colors.amber.shade600 : Colors.green.shade600),
      ),
      child: Row(
        children: [
          Icon(
            isCod ? Icons.payments_rounded : Icons.check_circle_rounded,
            color: isCod ? Colors.amber.shade900 : Colors.green.shade900,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCod ? 'CASH ON DELIVERY (COD)' : 'PREPAID ORDER (ONLINE UPI)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isCod ? Colors.amber.shade900 : Colors.green.shade900,
                  ),
                ),
                Text(
                  isCod
                      ? 'Collect $amountText cash from customer upon handover'
                      : 'Customer paid online. DO NOT collect any cash.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isCod ? Colors.amber.shade900 : Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.assigned:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                label: const Text('Accept Delivery (₹45)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final success = ref.read(driverDeliveryRepoProvider).acceptDelivery(
                        orderId: delivery.orderId,
                        driverId: 'driver-1',
                        driverName: 'Suresh Solanki',
                      );
                  if (!success) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Order Already Claimed'),
                          ],
                        ),
                        content: const Text(
                          'Another driver in your cluster has already accepted this order. Multi-driver concurrency lock prevents multiple drivers dispatched to the same store.',
                        ),
                        actions: [
                          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                        ],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.success,
                        content: Text('✅ Delivery Accepted & Locked to You! Drive to store for pickup.'),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Decline'),
                onPressed: () {
                  ref.read(driverDeliveryRepoProvider).declineDelivery(
                        orderId: delivery.orderId,
                        driverId: 'driver-1',
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Delivery request declined. Searching for next request...'),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case DeliveryStatus.accepted:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(Icons.navigation_rounded, color: Colors.white),
            label: const Text('Arrived at Clothing Store', style: TextStyle(color: Colors.white)),
            onPressed: () {
              ref.read(driverDeliveryRepoProvider).updateDeliveryStatus(
                    delivery.id,
                    DeliveryStatus.atPickup,
                    delivery.orderId,
                  );
            },
          ),
        );

      case DeliveryStatus.atPickup:
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: const Row(
                children: [
                  Icon(Icons.pin_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Show Pickup OTP to Boutique Vendor:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text('OTP: 4821', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF7A4F01))),
                        Text('Vendor verifies this 4-digit code to release the correct garment.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                icon: const Icon(Icons.inventory_rounded, color: Colors.white),
                label: const Text('OTP Verified • Parcel Picked Up & In Hand', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  ref.read(driverDeliveryRepoProvider).updateDeliveryStatus(
                        delivery.id,
                        DeliveryStatus.pickedUp,
                        delivery.orderId,
                      );
                },
              ),
            ),
          ],
        );

      case DeliveryStatus.pickedUp:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(Icons.navigation_rounded, color: Colors.white),
            label: const Text('Arrived at Customer Address', style: TextStyle(color: Colors.white)),
            onPressed: () {
              ref.read(driverDeliveryRepoProvider).updateDeliveryStatus(
                    delivery.id,
                    DeliveryStatus.atDelivery,
                    delivery.orderId,
                  );
            },
          ),
        );

      case DeliveryStatus.atDelivery:
        final order = OrderSyncService.currentOrders.firstWhere(
          (o) => o.id == delivery.orderId,
          orElse: () => OrderEntity(
            id: delivery.orderId,
            customerId: '',
            storeId: '',
            vendorId: '',
            deliveryAddressId: '',
            deliveryAddressSnapshot: const {},
            status: OrderStatus.pickedUp,
            paymentMethod: PaymentMethod.cod,
            paymentStatus: PaymentStatus.pending,
            pricing: const OrderPricing(
              productTotal: 89900,
              deliveryCharge: 2500,
              grandTotal: 95399,
              platformCommission: 8990,
              vendorEarning: 80910,
              driverEarning: 4500,
            ),
            placedAt: DateTime.now(),
          ),
        );
        final isCod = order.paymentMethod == PaymentMethod.cod;
        final amountText = '₹${(order.pricing.grandTotal / 100).toStringAsFixed(0)}';

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCod ? Colors.amber.shade800 : AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(isCod ? Icons.payments_rounded : Icons.verified_rounded, color: Colors.white),
            label: Text(
              isCod ? 'Collect $amountText Cash & Complete Delivery' : 'Confirm Handover & Deliver (Prepaid)',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              ref.read(driverDeliveryRepoProvider).updateDeliveryStatus(
                    delivery.id,
                    DeliveryStatus.delivered,
                    delivery.orderId,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text(
                    isCod
                        ? '✅ Delivery Completed! $amountText cash collected. Submit remittance under Earnings.'
                        : '✅ Prepaid Delivery Completed! ₹45 credited to your earnings.',
                  ),
                ),
              );
            },
          ),
        );

      case DeliveryStatus.delivered:
        return Column(
          children: [
            const Center(child: Text('Trip Completed 🎉', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                ref.read(driverDeliveryRepoProvider).declineDelivery(
                      orderId: delivery.orderId,
                      driverId: 'driver-1',
                    );
              },
              child: const Text('Ready for Next Order'),
            ),
          ],
        );
    }
  }
}
