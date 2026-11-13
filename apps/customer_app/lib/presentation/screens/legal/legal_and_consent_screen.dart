import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:core/core.dart';

class LegalAndConsentScreen extends StatefulWidget {
  const LegalAndConsentScreen({super.key});

  @override
  State<LegalAndConsentScreen> createState() => _LegalAndConsentScreenState();
}

class _LegalAndConsentScreenState extends State<LegalAndConsentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserConsentState _consentState = const UserConsentState();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await LegalConsentService.loadConsentState();
    if (mounted) {
      setState(() {
        _consentState = state;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConsent() async {
    setState(() => _isSaving = true);
    final saved = await LegalConsentService.saveConsentState(_consentState);
    if (mounted) {
      setState(() {
        _consentState = saved;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('✅ Consent preferences saved! Audit ID: ${saved.consentAuditHash?.substring(0, 22)}...'),
        ),
      );
    }
  }

  void _showErasureDialog() {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Request Data Erasure', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Under Section 12(3) of India\'s DPDP Act 2023, you have the statutory right to request permanent erasure of your account and personal data.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason for deletion (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await LegalConsentService.submitDataErasureRequest(
                userEmail: 'current.user@marsfashion.in',
                userName: 'Valued Customer',
                reason: reasonCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: res.$1 ? AppColors.success : AppColors.error,
                    duration: const Duration(seconds: 5),
                    content: Text(res.$2),
                  ),
                );
              }
            },
            child: const Text('Submit Statutory Deletion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy, Consent & Statutory Compliance'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.tune_rounded, size: 18), text: 'My Preferences'),
            Tab(icon: Icon(Icons.gavel_rounded, size: 18), text: '25 Statutory Protections'),
            Tab(icon: Icon(Icons.description_rounded, size: 18), text: 'Policies & Terms'),
            Tab(icon: Icon(Icons.support_agent_rounded, size: 18), text: 'Grievance Officer'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPreferencesTab(),
                _build25StatutoryTab(),
                _buildPoliciesTab(),
                _buildGrievanceOfficerTab(),
              ],
            ),
    );
  }

  // ── Tab 1: Granular Consent Preferences ───────────────────────────────────
  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statutory Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Digital Personal Data Protection Act, 2023 Compliant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(height: 2),
                      Text('Under Indian law, your consent must be free, specific, and unbundled. You can toggle optional permissions below anytime.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text('Granular Privacy Toggles', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),

          AppCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Doorstep GPS Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Used exclusively while app is active to calculate dynamic delivery ETA & direct delivery rider to your door in Ahmedabad.', style: TextStyle(fontSize: 12)),
                  value: _consentState.doorstepLocationAllowed,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _consentState = _consentState.copyWith(doorstepLocationAllowed: val);
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Order Tracking & OTP Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Receive push alerts for order preparation, driver dispatch, OTP handovers, and delivery status updates.', style: TextStyle(fontSize: 12)),
                  value: _consentState.pushAlertsAllowed,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _consentState = _consentState.copyWith(pushAlertsAllowed: val);
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Camera for 48-Hour Size Exchange Proof', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Optional: allows capturing photo proof of apparel fit issues for free instant size exchange pickup.', style: TextStyle(fontSize: 12)),
                  value: _consentState.cameraProofAllowed,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _consentState = _consentState.copyWith(cameraProofAllowed: val);
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Anonymized Diagnostics & Crash Telemetry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Anonymous performance telemetry to diagnose app crashes. Zero personally identifiable data collected.', style: TextStyle(fontSize: 12)),
                  value: _consentState.telemetryAllowed,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _consentState = _consentState.copyWith(telemetryAllowed: val);
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_rounded, color: Colors.white),
              label: const Text('Save Privacy Preferences', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: _isSaving ? null : _saveConsent,
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          // Right to Erasure / Delete Account
          Text('Statutory Rights', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          AppCard(
            color: Colors.red.shade50,
            child: Row(
              children: [
                const Icon(Icons.privacy_tip_outlined, color: AppColors.error, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Right to Erasure ("Right to be Forgotten")', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error)),
                      const Text('Permanently delete your profile, saved addresses, and personal data from our cloud servers.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Request Account Deletion', style: TextStyle(fontSize: 12)),
                        onPressed: _showErasureDialog,
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
  }

  // ── Tab 2: The 25 Statutory Protections ───────────────────────────────────
  Widget _build25StatutoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: LegalConsentService.statutoryRequirements.length,
      itemBuilder: (context, index) {
        final item = LegalConsentService.statutoryRequirements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: item.isMandatoryForCoreService ? AppColors.primary : AppColors.accent,
                      child: Text('${item.number}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(item.governingLaw, style: TextStyle(fontSize: 10, color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.isMandatoryForCoreService ? Colors.blue.shade50 : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.isMandatoryForCoreService ? 'Core Service' : 'Optional User Choice',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: item.isMandatoryForCoreService ? Colors.blue.shade900 : Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.purposeExplanation, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Tab 3: Detailed Policies ──────────────────────────────────────────────
  Widget _buildPoliciesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _policySection(
            title: '1. Privacy Policy & Data Fiduciary Disclosure',
            content: 'SwiftDrop acts as a Data Fiduciary under Section 2(i) of the Digital Personal Data Protection Act, 2023. We collect names, phone numbers, delivery coordinates, and order histories exclusively for order fulfillment, fraud prevention, and tax compliance. Data is processed locally within India (Google Cloud Asia-South1 Mumbai data center) and never sold to third-party ad networks.',
          ),
          _policySection(
            title: '2. Cookie & Local Storage Policy',
            content: 'Our web and mobile applications utilize SharedPreferences and local browser storage to maintain secure authentication session tokens, cached cart items, and cluster preferences (Ahmedabad & Gandhinagar). These cookies are strictly technical and essential for service continuity. No third-party tracking cookies or behavioral advertising pixels are embedded.',
          ),
          _policySection(
            title: '3. 48-Hour Free Size Exchange & Return Policy',
            content: 'Under Rule 5(3) of Consumer Protection (E-Commerce) Rules 2020, clothing purchases can be exchanged for a different size within 48 hours of delivery. Customers may initiate an exchange via the Orders tab, capture photo proof of the label, and our delivery partner will pick up the item and deliver the requested replacement at zero additional delivery charge.',
          ),
          _policySection(
            title: '4. Platform Fee & Commission Transparency',
            content: 'SwiftDrop charges a standard 10% platform facilitation fee to onboarded clothing merchants in Kubernagar, Gandhinagar, and across Ahmedabad. Delivery fees are calculated dynamically based on distance (~65 minutes for cross-city deliveries like Kubernagar to Sindhu Bhavan Road, ~19.2 km). All fees and applicable GST (5% / 12% on apparel) are displayed transparently prior to checkout.',
          ),
          _policySection(
            title: '5. Data Retention & Statutory Disposal',
            content: 'In accordance with Section 36 of the Central Goods and Services Tax (CGST) Act, 2017, all digital tax invoices and transaction records are preserved for 72 months (6 statutory financial years). Inactive non-transactional logs, device telemetry, and location traces are permanently purged every 90 calendar days.',
          ),
          _policySection(
            title: '6. Jurisdiction & Dispute Resolution',
            content: 'These Terms of Service are governed by the laws of India. Any controversy, dispute, or statutory claim arising out of marketplace transactions shall be subject to the exclusive jurisdiction of the competent civil courts located in Ahmedabad, Gujarat, India.',
          ),
        ],
      ),
    );
  }

  Widget _policySection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  // ── Tab 4: Grievance Officer & Redressal Desk ─────────────────────────────
  Widget _buildGrievanceOfficerTab() {
    final officer = LegalConsentService.grievanceOfficer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: Colors.blue, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statutory Redressal Mechanism', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
                      SizedBox(height: 4),
                      Text('Mandatory point of contact under Rule 3(2) of the Information Technology (Intermediary Guidelines) Rules, 2021 & Section 8(9) of DPDP Act, 2023.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text('Designated Grievance & Nodal Officer', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),

          AppCard(
            child: Column(
              children: [
                _contactRow(Icons.person_outline, 'Grievance Officer Name', officer.name),
                const Divider(),
                _contactRow(Icons.badge_outlined, 'Designation', officer.designation),
                const Divider(),
                _contactRow(Icons.email_outlined, 'Official Redressal Email', officer.email),
                const Divider(),
                _contactRow(Icons.alternate_email_rounded, 'Direct Technical Contact', 'developermeetratwani@gmail.com'),
                const Divider(),
                _contactRow(Icons.phone_outlined, 'Helpline', officer.phone),
                const Divider(),
                _contactRow(Icons.business_outlined, 'Physical Office Address', officer.address),
                const Divider(),
                _contactRow(Icons.timelapse_rounded, 'Statutory Acknowledgment', officer.acknowledgmentSla),
                const Divider(),
                _contactRow(Icons.timer_off_rounded, 'Final Redressal Timeline', officer.resolutionSla),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade900),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'If your grievance is not resolved within 30 days, you retain the statutory right to escalate your appeal directly to the Data Protection Board of India (DPBI).',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
