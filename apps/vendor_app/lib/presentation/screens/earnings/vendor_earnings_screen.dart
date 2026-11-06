import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/vendor_providers.dart';

class VendorEarningsScreen extends ConsumerWidget {
  const VendorEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(vendorEarningsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings & Settlements')),
      body: earningsAsync.when(
        data: (earnings) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Net Payout Card
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
                      const Text(
                        'TOTAL NET PAYOUT',
                        style: TextStyle(color: Color(0xFFADB5BD), fontSize: 12, letterSpacing: 1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        earnings.netEarningsDisplay,
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatMini(label: 'Total Orders', value: '${earnings.completedOrders} completed'),
                          _StatMini(label: 'Settlement cycle', value: 'Weekly (T+2)'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Transparent Financial Breakdown
                Text('Transparent Financial Breakdown', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      _BreakdownRow(
                        title: 'Gross Customer Sales',
                        amount: earnings.totalSalesDisplay,
                        isPositive: true,
                      ),
                      const Divider(),
                      _BreakdownRow(
                        title: 'Platform Commission (10%)',
                        amount: '- ${earnings.commissionDisplay}',
                        color: AppColors.error,
                      ),
                      const Divider(),
                      _BreakdownRow(
                        title: 'Net Retailer Earnings',
                        amount: earnings.netEarningsDisplay,
                        color: AppColors.success,
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Retailer Referral & Store Coins Program
                Text('Retailer Referral & Store Coins', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE94560).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: const Color(0xFFE94560).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Color(0xFFE94560), size: 28),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${earnings.storeCoins} Store Coins',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const Text('1 Coin = ₹1 redemption value against commissions', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Share your unique store referral link with local customers in Kubernagar, Gandhinagar & Vapi. Earn Store Coins on qualifying purchases!',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(earnings.referralCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                            Row(
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  label: const Text('Copy'),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: earnings.referralCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Referral code copied!')),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.share_rounded, size: 16),
                                  label: const Text('Share Link'),
                                  onPressed: () {
                                    final link = 'https://hyperlocalfashion.in/store/store-kubernagar-1?ref=${earnings.referralCode}';
                                    Clipboard.setData(ClipboardData(text: link));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Store affiliate link copied:\n$link')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
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

class _StatMini extends StatelessWidget {
  final String label;
  final String value;

  const _StatMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFADB5BD), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String title;
  final String amount;
  final Color? color;
  final bool isBold;
  final bool isPositive;

  const _BreakdownRow({
    required this.title,
    required this.amount,
    this.color,
    this.isBold = false,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
              fontSize: isBold ? 15 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
