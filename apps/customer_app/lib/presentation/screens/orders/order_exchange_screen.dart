import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/order_provider.dart';

class OrderExchangeScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderExchangeScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderExchangeScreen> createState() => _OrderExchangeScreenState();
}

class _OrderExchangeScreenState extends ConsumerState<OrderExchangeScreen> {
  String _selectedSize = 'L';
  String _selectedReason = 'Size runs too small / tight';
  String _exchangeMethod = 'rider'; // 'rider' or 'store'
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'];

  final List<String> _exchangeReasons = [
    'Size runs too small / tight',
    'Size runs too large / loose',
    'Fitting issue around waist/chest',
    'Prefer looser fit for comfort',
    'Wrong size tag delivered',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitExchange() async {
    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(orderRepositoryProvider);
      final failure = await repo.requestOrderExchange(
        orderId: widget.orderId,
        reason: '$_selectedReason [Method: ${_exchangeMethod == "rider" ? "Rider Pickup (₹99)" : "Direct Store Walk-in (Free)"}]',
        requestedSize: _selectedSize,
      );

      setState(() => _isSubmitting = false);

      if (failure != null) {
        if (mounted) {
          AppSnackbar.show(context, message: failure.message, type: SnackbarType.error);
        }
        return;
      }

      if (mounted) {
        final message = _exchangeMethod == 'rider'
            ? 'Exchange confirmed! A delivery partner is dispatched with size $_selectedSize (₹99 COD fee).'
            : 'Walk-in exchange token generated! Visit the boutique counter anytime within 48 hours for a free swap.';
        AppSnackbar.show(
          context,
          message: message,
          type: SnackbarType.success,
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        AppSnackbar.show(context, message: 'Exchange error: $e', type: SnackbarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Size Exchange Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Policy Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.published_with_changes_rounded, color: AppColors.accent, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hyperlocal Size Exchange Guarantee',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Exchange sizes within 48 hours. Choose between an immediate doorstep rider exchange or a free boutique walk-in.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Select Target Size
            Text('Select Required Replacement Size', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availableSizes.map((size) {
                final isSelected = _selectedSize == size;
                return ChoiceChip(
                  label: Text(size, style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  )),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceVariant,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSize = size);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── TWO-WAY EXCHANGE METHOD OPTIONS ──────────────────────────────
            Text('Select Exchange Method', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),

            // Option 1: Doorstep Rider Pickup & Exchange (₹99 Fee)
            _ExchangeMethodCard(
              title: 'Doorstep Rider Exchange (₹99)',
              subtitle: 'A delivery partner visits your doorstep with size $_selectedSize, inspects the tags, and swaps the garment on the spot.',
              feeBadge: '₹99 (Pay on Delivery)',
              icon: Icons.delivery_dining_rounded,
              isSelected: _exchangeMethod == 'rider',
              onTap: () => setState(() => _exchangeMethod = 'rider'),
            ),

            const SizedBox(height: 12),

            // Option 2: Direct Store Walk-in Exchange (100% Free)
            _ExchangeMethodCard(
              title: 'Direct Boutique Walk-in (100% FREE)',
              subtitle: 'Visit the local boutique counter directly, try out sizes in the trial room, and exchange immediately with zero fee.',
              feeBadge: 'FREE (₹0)',
              icon: Icons.storefront_rounded,
              isSelected: _exchangeMethod == 'store',
              onTap: () => setState(() => _exchangeMethod = 'store'),
            ),

            const SizedBox(height: 24),

            // Select Reason
            Text('Reason for Exchange', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: _exchangeReasons.map((reason) {
                  return RadioListTile<String>(
                    title: Text(reason, style: AppTextStyles.bodyMedium),
                    value: reason,
                    groupValue: _selectedReason,
                    onChanged: (val) => setState(() => _selectedReason = val!),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Notes / Feedback
            Text('Additional Instructions (Optional)', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Additional Instructions',
              hint: 'e.g. Please call before arriving or bring both M and L to try',
              controller: _notesController,
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Summary Notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Exchange Payable', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    _exchangeMethod == 'rider' ? '₹99' : 'FREE (₹0)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _exchangeMethod == 'rider' ? AppColors.primary : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            AppButton(
              label: 'Confirm Exchange Request for Size $_selectedSize',
              isLoading: _isSubmitting,
              onPressed: _submitExchange,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExchangeMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String feeBadge;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExchangeMethodCard({
    required this.title,
    required this.subtitle,
    required this.feeBadge,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0x14171717) : const Color(0x06000000),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.textPrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: feeBadge.contains('FREE') ? const Color(0xFFE8F5E9) : const Color(0xFFFEECEB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          feeBadge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: feeBadge.contains('FREE') ? const Color(0xFF16A34A) : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
