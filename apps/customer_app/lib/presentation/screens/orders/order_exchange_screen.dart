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
        reason: _selectedReason,
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
        AppSnackbar.show(
          context,
          message: 'Exchange requested! Replacement size $_selectedSize dispatched.',
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
                color: AppColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.published_with_changes_rounded, color: AppColors.accent, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hyperlocal Size Exchange Guarantee',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Exchange within 48 hours. A nearby driver partner will pick up your current item and deliver your requested size in one trip.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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
              hint: 'e.g. Please send the loose fit cut or call before delivery',
              controller: _notesController,
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Pricing notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reverse Pickup & Exchange Fee', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('₹49 (Pay on Exchange)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),

            const SizedBox(height: 32),

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
