import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/vendor_providers.dart';

class VendorOrdersScreen extends ConsumerStatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  ConsumerState<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends ConsumerState<VendorOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(vendorOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'New Orders'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Ready for Pickup'),
            Tab(text: 'Completed / Exchanges'),
          ],
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final newOrders = orders.where((o) => o.status == OrderStatus.pending).toList();
          final preparingOrders = orders.where((o) => o.status == OrderStatus.confirmed || o.status == OrderStatus.preparing).toList();
          final readyOrders = orders.where((o) => o.status == OrderStatus.readyForPickup || o.status == OrderStatus.pickedUp).toList();
          final completedOrders = orders.where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled || o.status == OrderStatus.exchangeRequested || o.status == OrderStatus.exchanged).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _OrderListView(orders: newOrders, emptyMsg: 'No new orders right now'),
              _OrderListView(orders: preparingOrders, emptyMsg: 'No orders being prepared'),
              _OrderListView(orders: readyOrders, emptyMsg: 'No orders awaiting driver pickup'),
              _OrderListView(orders: completedOrders, emptyMsg: 'No past orders yet'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading orders: $e')),
      ),
    );
  }
}

class _OrderListView extends ConsumerWidget {
  final List<OrderEntity> orders;
  final String emptyMsg;

  const _OrderListView({required this.orders, required this.emptyMsg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(emptyMsg, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        return _OrderCard(order: orders[i]);
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderEntity order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = switch (order.status) {
      OrderStatus.pending => AppColors.accent,
      OrderStatus.confirmed => AppColors.primary,
      OrderStatus.preparing => AppColors.warning,
      OrderStatus.readyForPickup => AppColors.info,
      OrderStatus.pickedUp => AppColors.info,
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
      OrderStatus.refunded => AppColors.error,
      OrderStatus.exchangeRequested || OrderStatus.exchanged => AppColors.warning,
    };

    final customerName = order.deliveryAddressSnapshot['recipientName'] ?? 'Customer';
    final address = order.deliveryAddressSnapshot['addressLine1'] ?? 'Local Street';
    final city = order.deliveryAddressSnapshot['city'] ?? 'Ahmedabad';

    final displayId = order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #$displayId', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status.name,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: $customerName', style: AppTextStyles.bodySmall),
                  Text('Destination: $address, $city', style: AppTextStyles.bodySmall),
                  Text('Payment: ${order.paymentMethod.name} (${order.paymentStatus.name})', style: const TextStyle(fontSize: 11, color: AppColors.accent)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total: ₹${(order.pricing.grandTotal / 100).toStringAsFixed(0)}', style: AppTextStyles.bodySmall),
                  Text('10% Comm: -₹${(order.pricing.platformCommission / 100).toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppColors.error)),
                  Text(
                    'Net: ₹${(order.pricing.vendorEarning / 100).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (order.status == OrderStatus.pending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () {
                      ref.read(vendorOrderRepoProvider).acceptOrder(order.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order accepted! Move to preparing.')),
                      );
                    },
                    child: const Text('Accept Order', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    onPressed: () => _showRejectDialog(context, ref, order.id),
                    child: const Text('Reject Order'),
                  ),
                ),
              ],
            )
          else if (order.status == OrderStatus.confirmed || order.status == OrderStatus.preparing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                icon: const Icon(Icons.inventory_rounded, color: Colors.white),
                label: const Text('Mark Ready for Driver Pickup', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  ref.read(vendorOrderRepoProvider).markReadyForPickup(order.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order marked ready! Driver dispatched.')),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, String orderId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please specify a reason for rejection (e.g., size out of stock):'),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Reason (e.g. Size M out of stock)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              final reason = controller.text.trim().isEmpty ? 'Out of stock' : controller.text.trim();
              ref.read(vendorOrderRepoProvider).rejectOrder(orderId, reason);
              Navigator.pop(ctx);
            },
            child: const Text('Confirm Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
