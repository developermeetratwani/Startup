import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController(text: 'Ahmedabad');
  final _pincodeController = TextEditingController();
  String _label = 'Home';
  bool _isDefault = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Delivery Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address Type', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: ['Home', 'Work', 'Other'].map((type) {
                  final isSel = _label == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary),
                      onSelected: (_) => setState(() => _label = type),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'House / Flat / Block No.',
                hint: 'e.g. Flat 302, Royal Residency',
                controller: _line1Controller,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                label: 'Street / Landmark',
                hint: 'e.g. Near Kubernagar Railway Crossing',
                controller: _line2Controller,
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'City',
                      controller: _cityController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Pincode',
                      hint: '382340',
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.length < 6) ? 'Enter 6 digits' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              SwitchListTile(
                title: const Text('Set as default address'),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 24),

              AppButton(
                label: 'Save Address',
                isLoading: _isLoading,
                onPressed: () async {
                  if (!_formKey.currentState!.validate() || user == null) return;
                  setState(() => _isLoading = true);

                  final repo = ref.read(addressRepositoryProvider);
                  await repo.addAddress(
                    AddressEntity(
                      id: '',
                      userId: user.uid,
                      label: _label,
                      line1: _line1Controller.text.trim(),
                      line2: _line2Controller.text.trim(),
                      city: _cityController.text.trim(),
                      state: 'Gujarat',
                      pincode: _pincodeController.text.trim(),
                      latitude: 23.0768,
                      longitude: 72.6346,
                      isDefault: _isDefault,
                    ),
                  );

                  setState(() => _isLoading = false);
                  if (mounted) context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
