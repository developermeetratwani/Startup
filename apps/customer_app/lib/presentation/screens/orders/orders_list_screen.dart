import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/order_provider.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 72, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No orders placed yet', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Your active and completed orders will appear here', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Start Shopping',
                    fullWidth: false,
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderTile(order: order);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading orders: $err')),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderEntity order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final displayId = order.id.length > 8 ? order.id.substring(0, 8) : order.id;

    return AppCard(
      onTap: () => context.push('/orders/track/${order.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #$displayId', style: AppTextStyles.labelLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status.name.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ₹${(order.pricing.grandTotal / 100).toStringAsFixed(0)} • ${_formatPaymentMethod(order.paymentMethod)}',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Placed on ${_formatDate(order.placedAt)}',
            style: AppTextStyles.bodySmall,
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.isActive ? 'Active Delivery' : (order.status == OrderStatus.exchangeRequested ? 'Exchange Pending' : 'Completed'),
                style: TextStyle(
                  fontSize: 12,
                  color: order.isActive ? AppColors.accent : (order.status == OrderStatus.exchangeRequested ? AppColors.warning : AppColors.textSecondary),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Row(
                children: [
                  Text('Track & Exchange', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPaymentMethod(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cod => 'COD (₹21 fee)',
      PaymentMethod.payOnDelivery => 'Pay on Delivery',
      PaymentMethod.payOnline => 'Online Paid',
      PaymentMethod.directPay => 'Direct Store Pay',
    };
  }

  Color _statusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
      OrderStatus.exchangeRequested || OrderStatus.exchanged => AppColors.warning,
      _ => AppColors.accent,
    };
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
