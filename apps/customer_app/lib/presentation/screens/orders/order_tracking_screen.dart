import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/order_provider.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(singleOrderStreamProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        actions: [
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estimated Time Header Banner
                if (!isCancelled && order.status != OrderStatus.delivered)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: AppColors.primary, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Delivery: ${order.estimatedDeliveryMinutes} Mins',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const Text('Dispatched via dedicated hyperlocal courier', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Size Exchange Requested Banner
                if (isExchange)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
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

                const SizedBox(height: 24),

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
