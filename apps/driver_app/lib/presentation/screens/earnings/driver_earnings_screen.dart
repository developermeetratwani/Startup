import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/driver_providers.dart';

class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(driverEarningsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rider Earnings & Payouts')),
      body: earningsAsync.when(
        data: (earnings) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Earnings Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TODAYS EARNINGS', style: TextStyle(color: Color(0xFFADB5BD), fontSize: 11, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text(earnings.todayEarningsDisplay, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatItem(title: 'This Week', value: earnings.weeklyEarningsDisplay),
                          _StatItem(title: 'Deliveries Done', value: '${earnings.totalDeliveries} drops'),
                          _StatItem(title: 'Partner Rating', value: '${earnings.rating} ★'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                Text('Recent Deliveries History', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),

                AppCard(
                  child: Column(
                    children: [
                      _TripTile(
                        store: 'Shreeji Ethnic Studio (Kubernagar)',
                        customer: 'Kavya Sharma',
                        payout: '₹45',
                        time: '15 mins ago',
                      ),
                      const Divider(),
                      _TripTile(
                        store: 'Vogue Mens Club (Kubernagar)',
                        customer: 'Hardik Soni',
                        payout: '₹55',
                        time: '1 hour ago',
                      ),
                      const Divider(),
                      _TripTile(
                        store: 'Infocity Fashion Hub (Gandhinagar)',
                        customer: 'Rohan Shah',
                        payout: '₹65',
                        time: '3 hours ago',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Payout notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.account_balance_rounded, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Weekly payout credited directly to your registered UPI / Bank account every Tuesday.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFFADB5BD), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class _TripTile extends StatelessWidget {
  final String store;
  final String customer;
  final String payout;
  final String time;

  const _TripTile({required this.store, required this.customer, required this.payout, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Drop to: $customer • $time', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(payout, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 15)),
        ],
      ),
    );
  }
}
