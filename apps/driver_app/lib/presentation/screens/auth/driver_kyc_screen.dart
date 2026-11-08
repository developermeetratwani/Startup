import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../providers/driver_providers.dart';

class DriverKycScreen extends ConsumerStatefulWidget {
  const DriverKycScreen({super.key});

  @override
  ConsumerState<DriverKycScreen> createState() => _DriverKycScreenState();
}

class _DriverKycScreenState extends ConsumerState<DriverKycScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dlController;
  late final TextEditingController _aadhaarController;
  late final TextEditingController _vehicleController;
  late final TextEditingController _electricityController;
  bool _policeClearanceAgreed = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(driverProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _phoneController = TextEditingController(text: profile.phone);
    _dlController = TextEditingController(text: 'GJ01-20210045678');
    _aadhaarController = TextEditingController(text: profile.aadhaarNumber == 'XXXX-XXXX-8912' ? '' : profile.aadhaarNumber);
    _vehicleController = TextEditingController(text: '${profile.vehicleModel} (${profile.vehicleRegNo})');
    _electricityController = TextEditingController(text: profile.electricityBillProvider);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dlController.dispose();
    _aadhaarController.dispose();
    _vehicleController.dispose();
    _electricityController.dispose();
    super.dispose();
  }

  void _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_policeClearanceAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please acknowledge the Anti-Theft Police Clearance Declaration.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final current = ref.read(driverProfileProvider);
    ref.read(driverProfileProvider.notifier).state = current.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      aadhaarNumber: _aadhaarController.text.trim().isNotEmpty ? _aadhaarController.text.trim() : '4821-9923-8912',
      electricityBillProvider: _electricityController.text.trim().isNotEmpty ? _electricityController.text.trim() : 'Torrent Power Ahmedabad',
      isVerified: true,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Anti-Theft KYC Verified! Delivery & Duty tabs unlocked.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mandatory Driver KYC'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              // Quick simulate toggle for dev testing
              final current = ref.read(driverProfileProvider);
              ref.read(driverProfileProvider.notifier).state = current.copyWith(isVerified: true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⚡ Instant Verification Simulator: Unlocked!')),
              );
            },
            child: const Text('Fast Pass', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Security Alert Lock Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Duty Locked (KYC Required)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'To safeguard luxury customer apparel and cash on delivery collections, you must verify your identity before accessing orders.',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Required Documents & Verification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Every delivery partner must complete all 5 requirements below.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // 1. Aadhaar Card
                _KycInputCard(
                  title: '1. Aadhaar Identity Card',
                  subtitle: 'Government ID verification (prevents fraudulent signup)',
                  icon: Icons.fingerprint_rounded,
                  child: AppTextField(
                    label: 'Aadhaar Number (12 Digits)',
                    hint: 'e.g. 5421 8892 1204',
                    controller: _aadhaarController,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().length < 8) ? 'Enter valid Aadhaar number' : null,
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Driving License
                _KycInputCard(
                  title: '2. Driving License (DL)',
                  subtitle: 'Must be active for two-wheeler transport in Gujarat',
                  icon: Icons.badge_rounded,
                  child: AppTextField(
                    label: 'License Number',
                    hint: 'e.g. GJ01-20210045678',
                    controller: _dlController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Driving license is required' : null,
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Vehicle Registration
                _KycInputCard(
                  title: '3. Vehicle Registration (RC)',
                  subtitle: 'Registered delivery vehicle in Ahmedabad / Gandhinagar',
                  icon: Icons.two_wheeler_rounded,
                  child: AppTextField(
                    label: 'Vehicle Model & Plate Number',
                    hint: 'e.g. Honda Activa 6G (GJ-01-AB-1234)',
                    controller: _vehicleController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vehicle details required' : null,
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Local Address Proof
                _KycInputCard(
                  title: '4. Residential Address Proof',
                  subtitle: 'Recent electricity / municipal bill in Ahmedabad region',
                  icon: Icons.home_rounded,
                  child: AppTextField(
                    label: 'Electricity Provider / Consumer #',
                    hint: 'e.g. Torrent Power Ahmedabad (#1089201)',
                    controller: _electricityController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Local address proof required' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Anti-Theft Police Clearance Declaration
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _policeClearanceAgreed,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _policeClearanceAgreed = val ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'I legally certify that I have zero criminal convictions or parcel theft records. I understand that stealing orders or absconding with cash triggers instant police FIR filing under IPC sections.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                AppButton(
                  label: 'Submit & Activate Duty',
                  isLoading: _isSubmitting,
                  onPressed: _submitVerification,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KycInputCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _KycInputCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06171717),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'REQUIRED',
                  style: TextStyle(color: AppColors.warning, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
