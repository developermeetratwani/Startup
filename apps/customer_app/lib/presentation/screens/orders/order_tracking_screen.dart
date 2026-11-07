import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/order_provider.dart';
import '../../widgets/live_rider_tracking_sheet.dart';
import '../../widgets/driver_chat_dialog.dart';
import '../../widgets/support_chatbot_sheet.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(singleOrderStreamProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Order Tracking'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.smart_toy_rounded, size: 16, color: AppColors.accent),
            label: const Text('Help AI', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
            onPressed: () => SupportChatbotSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          final statusSteps = [
            {'title': 'Order Placed', 'subtitle': 'Order received by marketplace', 'status': OrderStatus.pending},
            {'title': 'Order Confirmed', 'subtitle': 'Store accepted your order', 'status': OrderStatus.confirmed},
            {'title': 'Preparing Item', 'subtitle': 'Store is packing your clothing', 'status': OrderStatus.preparing},
            {'title': 'Ready for Pickup', 'subtitle': 'Handover to delivery partner', 'status': OrderStatus.readyForPickup},
            {'title': 'Out for Delivery', 'subtitle': 'Driver on the way to your address', 'status': OrderStatus.pickedUp},
            {'title': 'Delivered', 'subtitle': 'Package delivered to doorstep', 'status': OrderStatus.delivered},
          ];

          final int currentStepIndex = _getStepIndex(order.status);
          final bool isCancelled = order.status == OrderStatus.cancelled;
          final bool isExchange = order.status == OrderStatus.exchangeRequested || order.status == OrderStatus.exchanged;

          // Coordinates for Store, Rider, and Customer
          const storeLocation = LatLng(23.0768, 72.6346); // Kubernagar Store
          const riderLocation = LatLng(23.0782, 72.6360); // Roaming Rider
          const customerLocation = LatLng(23.0795, 72.6380); // Customer Dropoff

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estimated Time Header Banner (Zomato-style)
                if (!isCancelled && order.status != OrderStatus.delivered) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE23744), Color(0xFFFF616D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE23744).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.status == OrderStatus.pickedUp
                                    ? 'On the Way • Arriving in ~${order.estimatedDeliveryMinutes} Mins'
                                    : 'Preparing & Packing • ~${order.estimatedDeliveryMinutes} Mins',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              Text(
                                order.status == OrderStatus.pickedUp
                                    ? 'Driver Suresh Solanki picked up parcel from store'
                                    : 'Clothing boutique preparing your order for handover',
                                style: const TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => LiveRiderTrackingSheet.show(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.map_rounded, size: 14, color: Color(0xFFE23744)),
                                SizedBox(width: 4),
                                Text('Radar', style: TextStyle(color: Color(0xFFE23744), fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dynamic Traffic & Delay Status Banner (Zomato-style Green/Orange/Red)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Moderate Traffic on Kubernagar / S.G. Highway (+4 mins delay calculated)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7A4F01)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('SLIGHT DELAY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ),
                      ],
                    ),
                  ),
                ],

                // Size Exchange Requested Banner
                if (isExchange)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.change_circle_rounded, color: AppColors.warning, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Size Exchange Active: ${order.requestedExchangeSize ?? 'Requested'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                'Reason: ${order.exchangeReason ?? 'Size adjustment'}. Rider is en route with your replacement size.',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── ZOMATO-STYLE INTERACTIVE LIVE OPENSTREETMAP ─────────────
                if (!isCancelled) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: const MapOptions(
                              initialCenter: LatLng(23.0782, 72.6360),
                              initialZoom: 15.0,
                            ),
                            children: [
                              // 100% Free OpenStreetMap Raster Tiles
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'in.xyzstartup.app',
                              ),
                              // Route Polyline
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: const [storeLocation, riderLocation, customerLocation],
                                    color: const Color(0xFF6C5CE7),
                                    strokeWidth: 3.5,
                                  ),
                                ],
                              ),
                              // Markers
                              MarkerLayer(
                                markers: [
                                  // Store Pin
                                  Marker(
                                    point: storeLocation,
                                    width: 44,
                                    height: 44,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade700,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                      ),
                                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                                    ),
                                  ),
                                  // Live Moving Courier Scooter
                                  Marker(
                                    point: riderLocation,
                                    width: 50,
                                    height: 50,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE23744),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                        boxShadow: const [BoxShadow(color: Color(0x66E23744), blurRadius: 8, spreadRadius: 2)],
                                      ),
                                      child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 22),
                                    ),
                                  ),
                                  // Customer Doorstep
                                  Marker(
                                    point: customerLocation,
                                    width: 44,
                                    height: 44,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade600,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                      ),
                                      child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Live Tracking Badge
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: const Row(
                                children: [
                                  CircleAvatar(radius: 3, backgroundColor: Colors.green),
                                  SizedBox(width: 5),
                                  Text('LIVE RIDER GPS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── DELIVERY PARTNER PROFILE & DIRECT CHAT CARD ───────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFE23744).withValues(alpha: 0.12),
                              child: const Icon(Icons.person_rounded, color: Color(0xFFE23744), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Text('Suresh Solanki', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      SizedBox(width: 6),
                                      Icon(Icons.verified_user_rounded, color: Colors.blue, size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text('Honda Activa 6G • GJ-01-AB-1234', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                                      const SizedBox(width: 2),
                                      Text('4.9 ★ (1,240 deliveries)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Direct Chat Button
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                label: const Text('Chat with Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () => DriverChatDialog.show(
                                  context,
                                  orderId: order.id,
                                  driverName: 'Suresh Solanki',
                                  driverPhone: '+91 98980 12345',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Direct Call Button
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                icon: const Icon(Icons.phone_rounded, size: 16),
                                label: const Text('Call Partner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () async {
                                  final uri = Uri.parse('tel:+919898012345');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Rider Phone: +91 98980 12345')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],

                // Order Status Summary Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}', style: AppTextStyles.titleMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCancelled
                                  ? AppColors.error.withOpacity(0.15)
                                  : AppColors.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.status.name.toUpperCase(),
                              style: TextStyle(
                                color: isCancelled ? AppColors.error : AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Text(
                        'Total: ₹${(order.pricing.grandTotal / 100).toStringAsFixed(0)} • ${_formatPaymentMethod(order.paymentMethod)}',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Packaging (1%): ₹${(order.pricing.packagingCharge / 100).toStringAsFixed(0)} • COD Fee: ₹${(order.pricing.codCharge / 100).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Destination: ${order.deliveryAddressSnapshot['line1'] ?? ''}, ${order.deliveryAddressSnapshot['city'] ?? ''}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (isCancelled)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Cancelled',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reason: ${order.cancellationReason ?? 'Cancelled upon customer request'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text('Live Delivery Timeline', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),

                  // Status timeline
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: statusSteps.length,
                    itemBuilder: (context, index) {
                      final step = statusSteps[index];
                      final isPassed = index <= currentStepIndex;
                      final isCurrent = index == currentStepIndex;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isPassed ? AppColors.accent : AppColors.divider,
                                ),
                                child: Icon(
                                  isPassed ? Icons.check : Icons.circle,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              if (index < statusSteps.length - 1)
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: isPassed ? AppColors.accent : AppColors.divider,
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['title'] as String,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: isPassed ? AppColors.textPrimary : AppColors.textHint,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  step['subtitle'] as String,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isPassed ? AppColors.textSecondary : AppColors.textHint,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // Size Exchange Button (if delivered)
                if (order.status == OrderStatus.delivered && !isExchange)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Size didn\'t fit well?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('Request a size exchange within 48 hours for immediate replacement.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Request Size Exchange',
                          variant: AppButtonVariant.primary,
                          onPressed: () => context.push('/orders/${order.id}/exchange'),
                        ),
                      ],
                    ),
                  ),

                // Cancellation Option (if pending)
                if (order.status == OrderStatus.pending)
                  AppButton(
                    label: 'Cancel Order',
                    variant: AppButtonVariant.outline,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Cancel Order?'),
                          content: const Text('Are you sure you want to cancel this order?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel')),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final repo = ref.read(orderRepositoryProvider);
                        await repo.cancelOrder(orderId: order.id, reason: 'Customer cancelled from app');
                        if (context.mounted) {
                          AppSnackbar.show(context, message: 'Order cancelled', type: SnackbarType.info);
                        }
                      }
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _formatPaymentMethod(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cod => 'Cash on Delivery',
      PaymentMethod.payOnDelivery => 'Pay on Delivery (QR)',
      PaymentMethod.payOnline => 'Online Paid',
      PaymentMethod.directPay => 'Direct Store Pay',
    };
  }

  int _getStepIndex(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => 0,
      OrderStatus.confirmed => 1,
      OrderStatus.preparing => 2,
      OrderStatus.readyForPickup => 3,
      OrderStatus.pickedUp => 4,
      OrderStatus.delivered => 5,
      _ => 0,
    };
  }
}