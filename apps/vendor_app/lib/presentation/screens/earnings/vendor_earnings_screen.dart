import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/vendor_providers.dart';

class SettlementBatch {
  final String batchId;
  final String amount;
  String utrRef;
  String date;
  bool isPaid;
  String? settledBy;

  SettlementBatch({
    required this.batchId,
    required this.amount,
    required this.utrRef,
    required this.date,
    required this.isPaid,
    this.settledBy,
  });
}

class VendorEarningsScreen extends ConsumerStatefulWidget {
  const VendorEarningsScreen({super.key});

  @override
  ConsumerState<VendorEarningsScreen> createState() => _VendorEarningsScreenState();
}

class _VendorEarningsScreenState extends ConsumerState<VendorEarningsScreen> {
  final List<SettlementBatch> _settlementBatches = [
    SettlementBatch(
      batchId: 'BATCH-2026-W44',
      amount: '₹14,580',
      utrRef: 'UPI/6312450912/XYZ-SETTLE',
      date: '03 Nov 2026, 02:15 PM',
      isPaid: true,
      settledBy: 'MARS Finance Desk',
    ),
    SettlementBatch(
      batchId: 'BATCH-2026-W43',
      amount: '₹19,200',
      utrRef: 'IMPS/AXIS991204/XYZ-SETTLE',
      date: '27 Oct 2026, 11:30 AM',
      isPaid: true,
      settledBy: 'MARS Finance Desk',
    ),
    SettlementBatch(
      batchId: 'CURRENT-CYCLE (Pending)',
      amount: '₹3,058',
      utrRef: 'Awaiting Company Disbursement',
      date: 'In Processing (T+2)',
      isPaid: false,
    ),
  ];

  void _recordCompanyPayout(SettlementBatch batch) {
    if (batch.isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            '⚠️ DUPLICATE PAYOUT BLOCKED: ${batch.batchId} was already paid by the company under ${batch.utrRef}. Multiple payouts are forbidden.',
          ),
        ),
      );
      return;
    }

    final autoUtr = 'UPI/${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}/XYZ-SETTLE';
    final utrController = TextEditingController(text: autoUtr);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Company Settlement Payout'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Disbursing vendor earnings for ${batch.batchId}:', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Payout Amount:'),
                        Text(batch.amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vendor UPI / Bank:'),
                        Text('shreeji-kuber@axisbank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: utrController,
                decoration: const InputDecoration(
                  labelText: 'Bank UTR / Transaction Reference',
                  prefixIcon: Icon(Icons.receipt_long_rounded),
                  helperText: 'Unique reference to prevent duplicate payout',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirm Paid by Company', style: TextStyle(color: Colors.white)),
            onPressed: () {
              final finalUtr = utrController.text.trim();
              if (finalUtr.isEmpty) return;

              setState(() {
                batch.isPaid = true;
                batch.utrRef = finalUtr;
                batch.date = 'Paid Just Now (Company Settled)';
                batch.settledBy = 'MARS SuperAdmin';
              });

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text(
                    '✅ Vendor earnings of ${batch.amount} marked as PAID! Locked under UTR: $finalUtr.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                MarsHero(eyebrow: 'Your net payout', title: earnings.netEarningsDisplay,
                  description: '${earnings.completedOrders} completed orders · Weekly settlement cycle (T+2)',
                  accent: AppColors.purple, icon: Icons.account_balance_wallet_outlined),
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

                // Company Settlement & Payout Ledger
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('Company Settlement & Payout Ledger', style: AppTextStyles.titleMedium),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('AUTO-RECONCILED', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < _settlementBatches.length; i++) ...[
                        if (i > 0) const Divider(),
                        _buildSettlementTile(_settlementBatches[i]),
                      ],
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user_outlined, color: Colors.blue, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Duplicate Protection Active: Every settlement batch is locked with a unique UTR. Once marked PAID by the company, multiple payouts for the same batch are prohibited.',
                                style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Retailer Referral & Store Coins
                Text('Retailer Referral & Store Coins', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: AppColors.accent, size: 28),
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
                        'Share your unique store referral link with customers across all Ahmedabad (Sindhu Bhavan, Bodakdev, Kubernagar & Gandhinagar). Earn Store Coins on qualifying purchases!',
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
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Text(earnings.referralCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                            Wrap(
                              spacing: 6,
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

  Widget _buildSettlementTile(SettlementBatch batch) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(batch.batchId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 6),
                    if (batch.isPaid)
                      const Icon(Icons.lock_rounded, size: 14, color: AppColors.success)
                    else
                      const Icon(Icons.hourglass_empty_rounded, size: 14, color: AppColors.warning),
                  ],
                ),
                const SizedBox(height: 2),
                Text(batch.utrRef, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace')),
                const SizedBox(height: 2),
                Text(batch.date, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(batch.amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              if (batch.isPaid)
                InkWell(
                  onTap: () => _recordCompanyPayout(batch),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 12, color: Colors.green.shade800),
                        const SizedBox(width: 4),
                        Text(
                          'PAID & LOCKED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _recordCompanyPayout(batch),
                  child: const Text('Pay Vendor', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
            ],
          ),
        ],
      ),
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
