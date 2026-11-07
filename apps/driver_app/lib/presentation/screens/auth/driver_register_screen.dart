import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _isLoading = true);

    try {
      final driverId = 'driver-';
      await FirebaseFirestore.instance.collection('driverProfiles').doc(driverId).set({
        'userId': driverId,
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'vehicleNumber': _vehicleController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
        'approvalStatus': 'pending',
        'isOnline': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rider application submitted! Admin will verify.')),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rider Onboarding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Join as Hyperlocal Delivery Partner', style: AppTextStyles.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Earn steady income delivering fashion orders with flexible online hours',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            AppTextField(
              label: 'Full Legal Name',
              hint: 'e.g. Suresh Solanki',
              controller: _nameController,
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Mobile Number (+91)',
              hint: '9898012345',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Vehicle Model & Number',
              hint: 'e.g. Honda Activa (GJ-01-AB-1234)',
              controller: _vehicleController,
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Driving License Number',
              hint: 'e.g. GJ0120200012345',
              controller: _licenseController,
            ),
            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: 'Submit Onboarding Application',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
