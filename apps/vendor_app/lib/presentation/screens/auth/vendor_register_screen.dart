import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedCity = 'Ahmedabad';
  String _selectedMarket = 'Kubernagar';
  bool _isLoading = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/pending-approval');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Onboarding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Retailer Onboarding Application', style: AppTextStyles.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Join our hyperlocal fashion network and start receiving orders from nearby buyers',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 24),

              AppTextField(
                label: 'Clothing Store / Brand Name',
                hint: 'e.g. Radhe Saree Sansar',
                controller: _storeNameController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                label: 'Owner Full Name',
                hint: 'e.g. Rajesh Kumar',
                controller: _ownerNameController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                label: 'Mobile Phone (+91)',
                hint: '9876543210',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.length < 10 ? 'Valid 10-digit number required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Market Cluster selection
              DropdownButtonFormField<String>(
                value: _selectedMarket,
                decoration: InputDecoration(
                  labelText: 'Target Market Cluster',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Kubernagar', child: Text('Kubernagar Market, Ahmedabad East')),
                  DropdownMenuItem(value: 'Gandhinagar', child: Text('Gandhinagar (Sector 1-30 & Infocity)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMarket = val;
                      _selectedCity = val == 'Kubernagar' ? 'Ahmedabad' : 'Gandhinagar';
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                label: 'Shop Address / Landmark',
                hint: 'Shop 4, Main Bazaar, near Post Office',
                controller: _addressController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.xl),

              AppButton(
                label: 'Submit Application for Review',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
