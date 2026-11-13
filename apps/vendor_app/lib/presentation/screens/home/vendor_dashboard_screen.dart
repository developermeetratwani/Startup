import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/vendor_providers.dart';

class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(currentStoreProvider);
    final ordersAsync = ref.watch(vendorOrdersProvider);
    final earningsAsync = ref.watch(vendorEarningsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              storeAsync.valueOrNull?.name ?? 'Store Dashboard',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              storeAsync.valueOrNull?.location.city ?? 'Ahmedabad',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.pagePadding),
            child: storeAsync.when(
              data: (store) {
                if (store == null) return const SizedBox.shrink();
                return Row(
                  children: [
                    Text(
                      store.isOpen ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        color: store.isOpen ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Switch(
                      value: store.isOpen,
                      activeThumbColor: AppColors.success,
                      onChanged: (val) {
                        ref.read(vendorStoreStatusOverrideProvider.notifier).state = val;
                        ref.read(vendorStoreRepoProvider).updateStoreStatus(
                              storeId: store.id,
                              isOpen: val,
                            );
                      },
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentStoreProvider);
          ref.invalidate(vendorOrdersProvider);
          ref.invalidate(vendorEarningsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarsHero(
                eyebrow: 'MARS / Merchant studio',
                title: 'Your boutique.\nIn full bloom.',
                description: 'A new day to make a local impression. Your orders, collection and earnings, together.',
                accent: AppColors.purple,
                icon: Icons.storefront_outlined,
                actionLabel: 'Add to collection',
                onAction: () => context.push('/products/add'),
              ),
              const MarsSectionHeading(number: '01', title: 'The business edit', subtitle: 'Your store at a glance'),
              if (storeAsync.valueOrNull?.isOpen == false)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.error),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your store is currently Closed. Customers in Kubernagar/Gandhinagar cannot place orders right now.',
                          style: TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              earningsAsync.when(
                data: (earnings) => MarsMetricGrid(children: [
                  _MetricCard(title: 'Total sales', value: earnings.totalSalesDisplay,
                    icon: Icons.payments_outlined, color: AppColors.primary),
                  _MetricCard(title: 'Platform fee', subtitle: '10% fee', value: earnings.commissionDisplay,
                    icon: Icons.percent_rounded, color: AppColors.goldDark),
                  _MetricCard(title: 'Net payout', value: earnings.netEarningsDisplay,
                    icon: Icons.account_balance_wallet_outlined, color: AppColors.ratingGreen),
                ]),
                loading: () => const ShimmerProductCard(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSpacing.lg),

              earningsAsync.when(
                data: (earnings) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.monetization_on_rounded, color: AppColors.accent, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${earnings.storeCoins} Store Coins Available',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Referral Code: ${earnings.referralCode} • Share to earn coins',
                              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () => context.push('/earnings'),
                        child: const Text('View', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text('Quick Actions', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                      ),
                      icon: const Icon(Icons.add_business_rounded, color: AppColors.accent),
                      label: const Text('Add Product'),
                      onPressed: () => context.push('/products/add'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                      ),
                      icon: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                      label: const Text('All Orders'),
                      onPressed: () => context.push('/orders'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Incoming & Active Orders', style: AppTextStyles.titleLarge),
                  TextButton(
                    onPressed: () => context.push('/orders'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ordersAsync.when(
                data: (orders) {
                  final activeOrders = orders.where((o) => o.isActive).toList();
                  if (activeOrders.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 40),
                            SizedBox(height: 8),
                            Text('No pending orders right now', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('New orders will appear here in real-time', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeOrders.take(3).length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final order = activeOrders[i];
                      return _DashboardOrderTile(order: order);
                    },
                  );
                },
                loading: () => const ShimmerProductCard(),
                error: (e, _) => Text('Error loading orders: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return MarsMetric(label: title, value: value, detail: subtitle,
      icon: icon, accent: color);
  }
}

class _DashboardOrderTile extends ConsumerWidget {
  final OrderEntity order;

  const _DashboardOrderTile({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNew = order.status == OrderStatus.pending;
    final customerName = order.deliveryAddressSnapshot['recipientName'] ?? 'Customer';

    return AppCard(
      onTap: () => context.push('/orders'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isNew ? AppColors.accent : AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status.name,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Total: ₹${(order.pricing.grandTotal / 100).toStringAsFixed(0)}'),
          Text('Customer: $customerName', style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          if (isNew)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () {
                      ref.read(vendorOrderRepoProvider).acceptOrder(order.id);
                    },
                    child: const Text('Accept Order', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    onPressed: () {
                      ref.read(vendorOrderRepoProvider).rejectOrder(order.id, 'Out of stock in store');
                    },
                    child: const Text('Reject'),
                  ),
                ),
              ],
            )
          else if (order.status == OrderStatus.confirmed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  ref.read(vendorOrderRepoProvider).markReadyForPickup(order.id);
                },
                child: const Text('Mark Ready for Pickup', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
