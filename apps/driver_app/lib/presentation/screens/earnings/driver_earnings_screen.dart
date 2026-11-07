import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:core/core.dart';
import '../../providers/driver_providers.dart';

class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  void _showHubHandoverDialog(BuildContext context, WidgetRef ref, DriverCodSummary codSummary) {
    final amountCtrl = TextEditingController(text: (codSummary.pendingCashInHand / 100).toStringAsFixed(0));
    final emailCtrl = TextEditingController(text: 'developermeetratwani@gmail.com');
    String selectedHub = OrderSyncService.hubLocations.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.store_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Handover Cash at Hub (OTP)'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Physical cash handover with OTP verification by Hub Admin / Cashier:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                const Text('Select Hub Location:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedHub,
                  isExpanded: true,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: OrderSyncService.hubLocations
                      .map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontSize: 12))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedHub = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text('Quick Select Amount:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    ActionChip(
                      label: Text('Full (${codSummary.pendingCashDisplay})', style: const TextStyle(fontSize: 11)),
                      onPressed: () {
                        amountCtrl.text = (codSummary.pendingCashInHand / 100).toStringAsFixed(0);
                      },
                    ),
                    ActionChip(
                      label: const Text('₹1,000', style: TextStyle(fontSize: 11)),
                      onPressed: () => amountCtrl.text = '1000',
                    ),
                    ActionChip(
                      label: const Text('₹500', style: TextStyle(fontSize: 11)),
                      onPressed: () => amountCtrl.text = '500',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cash Amount to Handover (₹)',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Rider Email (for OTP Receipt)',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                    helperText: 'OTP will be sent to this email address',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
              label: const Text('Generate & Send OTP', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final amountRupees = int.tryParse(amountCtrl.text.trim()) ?? 0;
                final email = emailCtrl.text.trim();
                if (amountRupees <= 0 || email.isEmpty) return;

                final request = await OrderSyncService.initiateHubCashHandover(
                  driverId: 'driver-1',
                  driverName: 'Suresh Solanki',
                  driverEmail: email,
                  hubLocation: selectedHub,
                  amount: amountRupees * 100,
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 6),
                    content: Text(
                      '🔐 OTP (${request.otp}) generated & emailed to $email! Share this with Hub Cashier.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRemitCashDialog(BuildContext context, WidgetRef ref, DriverCodSummary codSummary) {
    final amountCtrl = TextEditingController(text: (codSummary.pendingCashInHand / 100).toStringAsFixed(0));
    final refCtrl = TextEditingController(text: 'UPI/${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}/XYZ-REMIT');
    String selectedMode = 'COMPANY_UPI';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.savings_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Deposit COD Cash (Direct UPI)'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Remit collected customer COD cash to XYZ Startup finance desk via UPI:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Cash In Hand:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(codSummary.pendingCashDisplay, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Company UPI Destination:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('xyzstartup@icici (XYZ Startup Logistics Settlement)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount to Remit (₹)',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: refCtrl,
                  decoration: const InputDecoration(
                    labelText: 'UPI Reference Number (UTR)',
                    prefixIcon: Icon(Icons.receipt_long),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              onPressed: () {
                final amountRupees = int.tryParse(amountCtrl.text.trim()) ?? 0;
                if (amountRupees <= 0) return;

                OrderSyncService.submitCashRemittance(
                  driverId: 'driver-1',
                  driverName: 'Suresh Solanki',
                  amount: amountRupees * 100,
                  paymentMode: selectedMode,
                  referenceNumber: refCtrl.text.trim(),
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text('✅ Remittance of ₹$amountRupees submitted! Awaiting Admin verification.'),
                  ),
                );
              },
              child: const Text('Submit UPI Remittance', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(driverEarningsProvider);
    final codSummary = ref.watch(driverCodSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rider Earnings & Cash Settlement')),
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
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TODAYS EARNINGS', style: TextStyle(color: AppColors.textHint, fontSize: 11, letterSpacing: 1)),
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

                const SizedBox(height: AppSpacing.lg),

                // COD Cash Collection & Remittance Section
                Text('COD Cash In Hand & Hub Settlement', style: AppTextStyles.titleMedium),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: const [
                      BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.accent, size: 28),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CASH IN HAND (TO REMIT)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                  Text(codSummary.pendingCashDisplay, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                ],
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textOnDark,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                icon: const Icon(Icons.store_rounded, size: 16),
                                label: const Text('Pay Cash at Hub (OTP)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                onPressed: () => _showHubHandoverDialog(context, ref, codSummary),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                icon: const Icon(Icons.qr_code_rounded, size: 16),
                                label: const Text('UPI', style: TextStyle(fontSize: 11)),
                                onPressed: () => _showRemitCashDialog(context, ref, codSummary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _codMiniStat('Total COD', codSummary.collectedDisplay)),
                          Expanded(child: _codMiniStat('COD Orders', '${codSummary.totalCodOrders}')),
                          Expanded(child: _codMiniStat('Prepaid UPI', '${codSummary.totalOnlinePaidOrders}')),
                          Expanded(child: _codMiniStat('Remitted', codSummary.remittedDisplay)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWarm,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_outlined, size: 14, color: AppColors.accent),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Hub Handover: Select your hub (Kubernagar, Gandhinagar, etc.), share your email OTP with Hub Admin, and your balance will be settled instantly.',
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Active Hub Cash Handover Requests & OTP Cards
                Text('Hub Cash Handovers & Verification OTPs', style: AppTextStyles.titleMedium),
                const SizedBox(height: 10),
                Column(
                  children: [
                    for (final h in OrderSyncService.currentHandovers)
                      _HubHandoverCard(handover: h),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Remittance History
                Text('Settled Remittance Receipts', style: AppTextStyles.titleMedium),
                const SizedBox(height: 10),
                AppCard(
                  child: Column(
                    children: [
                      for (final r in OrderSyncService.currentRemittances) ...[
                        _RemittanceTile(record: r),
                        const Divider(),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                Text('Recent Deliveries History', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),

                AppCard(
                  child: const Column(
                    children: [
                      _TripTile(
                        store: 'Shreeji Ethnic Studio (Kubernagar)',
                        customer: 'Kavya Sharma (COD ₹954)',
                        payout: '₹45',
                        time: '15 mins ago',
                      ),
                      Divider(),
                      _TripTile(
                        store: 'Vogue Mens Club (Kubernagar)',
                        customer: 'Hardik Soni (Prepaid UPI)',
                        payout: '₹55',
                        time: '1 hour ago',
                      ),
                      Divider(),
                      _TripTile(
                        store: 'Infocity Fashion Hub (Gandhinagar)',
                        customer: 'Rohan Shah (Prepaid UPI)',
                        payout: '₹65',
                        time: '3 hours ago',
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

  Widget _codMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _HubHandoverCard extends StatelessWidget {
  final DriverHubHandoverRequest handover;

  const _HubHandoverCard({required this.handover});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: handover.isVerified ? AppColors.success : AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  handover.hubLocation,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: handover.isVerified ? AppColors.success.withValues(alpha: 0.12) : AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  handover.isVerified ? 'SETTLED & VERIFIED ✅' : 'WAITING FOR OTP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: handover.isVerified ? AppColors.success : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount to Handover', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(handover.amountDisplay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              if (!handover.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('YOUR OTP CODE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text(
                            handover.otp,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: handover.otp));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('OTP copied to clipboard!')),
                          );
                        },
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Receipt No.', style: TextStyle(fontSize: 10, color: Colors.green)),
                    Text(handover.receiptNumber ?? '#SETTLED', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            handover.isVerified
                ? 'Cash received by Admin (${handover.adminId}) at ${handover.verifiedAt?.hour}:${handover.verifiedAt?.minute.toString().padLeft(2, '0')}.'
                : 'Give physical cash of ${handover.amountDisplay} to Admin. Admin will enter this OTP to clear balance.',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RemittanceTile extends StatelessWidget {
  final DriverRemittanceRecord record;

  const _RemittanceTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.referenceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
                const SizedBox(height: 2),
                Text('${record.paymentMode} • ${record.submittedAt.day}/${record.submittedAt.month} ${record.submittedAt.hour}:${record.submittedAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(record.amountDisplay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: record.isVerifiedByAdmin ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  record.isVerifiedByAdmin ? 'VERIFIED BY ADMIN' : 'AWAITING ADMIN',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: record.isVerifiedByAdmin ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
        ],
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
        Text(title, style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
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
