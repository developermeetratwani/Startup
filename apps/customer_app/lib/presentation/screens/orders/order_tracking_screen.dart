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
            {'title': 'Out for Delivery', 'subtitle': 'Driver on the way to you', 'status': OrderStatus.pickedUp},
            {'title': 'Delivered', 'subtitle': 'Package delivered to doorstep', 'status': OrderStatus.delivered},
          ];

          final int currentStepIndex = _getStepIndex(order.status);
          final bool isCancelled = order.status == OrderStatus.cancelled;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Status Summary Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order.id.substring(0, 8)}', style: AppTextStyles.titleMedium),
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
                      const SizedBox(height: 8),
                      Text(
                        'Total: ₹${(order.pricing.grandTotal / 100).toStringAsFixed(0)} • ${order.paymentMethod == PaymentMethod.cod ? 'Cash on Delivery' : 'Online Paid'}',
                        style: AppTextStyles.bodyMedium,
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
                          'Reason: ${order.cancellationReason ?? 'Cancelled upon request'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text('Live Order Status', style: AppTextStyles.titleLarge),
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

                // Cancellation Option
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
