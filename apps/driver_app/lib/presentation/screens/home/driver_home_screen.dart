import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
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
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              Text('Delivery Fee: ₹${(delivery.deliveryFee / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
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
          const Divider(height: 24),

          // Pickup Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PICKUP FROM STORE', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Shreeji Ethnic & Bridal Studio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Main Bazaar, Kubernagar, Ahmedabad', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DELIVER TO CUSTOMER', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Kavya Sharma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Block C-4, Krishna Complex, Kubernagar', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

  Widget _buildActionButton(BuildContext context, WidgetRef ref, DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.assigned:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                onPressed: () {
                  ref.read(driverDeliveryRepoProvider).updateDeliveryStatus(
                        delivery.id,
                        DeliveryStatus.accepted,
                        delivery.orderId,
                      );
                },
                child: const Text('Accept Delivery (₹45)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: () {},
                child: const Text('Decline'),
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
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            icon: const Icon(Icons.inventory_rounded, color: Colors.white),
            label: const Text('Parcel Picked Up & In Hand', style: TextStyle(color: Colors.white)),
            onPressed: () {
              ref.read(driverDeliveryRepoProvider).updateDeliveryStatus(
                    delivery.id,
                    DeliveryStatus.pickedUp,
                    delivery.orderId,
                  );
            },
          ),
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
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            icon: const Icon(Icons.verified_rounded, color: Colors.white),
            label: const Text('Confirm Handover & Deliver (Collect ₹)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              ref.read(driverDeliveryRepoProvider).updateDeliveryStatus(
                    delivery.id,
                    DeliveryStatus.delivered,
                    delivery.orderId,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delivery Completed! ₹45 credited to your balance.')),
              );
            },
          ),
        );

      case DeliveryStatus.delivered:
        return const Center(child: Text('Trip Completed 🎉', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)));
    }
  }
}
