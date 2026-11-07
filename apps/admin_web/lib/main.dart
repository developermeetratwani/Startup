import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('AdminWeb Firebase init: $e');
  }

  runApp(const ProviderScope(child: AdminDashboardApp()));
}

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XYZ Startup — Central Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AdminHomeScreen(),
    );
  }
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    OrderSyncService.ordersStream.listen((_) {
      if (mounted) setState(() {});
    });
    OrderSyncService.remittancesStream.listen((_) {
      if (mounted) setState(() {});
    });
    OrderSyncService.handoversStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  final _tabs = [
    'Overview & Metrics',
    'Vendor Approvals',
    'Clothing Stores',
    'Order Monitoring',
    'Driver Fleet & KYC',
    'Size Exchanges',
    'Multi-Region Settings',
    'Commissions & Coins',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 260,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('XYZ STARTUP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Admin Console', style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                const Text('MAIN NAVIGATION', style: TextStyle(color: AppColors.textHint, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTab == index;
                      final icons = [
                        Icons.dashboard_rounded,
                        Icons.verified_user_rounded,
                        Icons.storefront_rounded,
                        Icons.shopping_bag_rounded,
                        Icons.two_wheeler_rounded,
                        Icons.change_circle_rounded,
                        Icons.map_rounded,
                        Icons.account_balance_wallet_rounded,
                      ];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor: AppColors.primaryLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          leading: Icon(icons[index], color: isSelected ? AppColors.accent : AppColors.textHint, size: 20),
                          title: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textHint,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onTap: () => setState(() => _selectedTab = index),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Color(0xFF2C2C2C)),
                const ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  title: Text('Admin Manager', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('admin@xyzstartup.in', style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  // Top App Bar
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tabs[_selectedTab],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.cloud_done_rounded, color: AppColors.success, size: 16),
                                  SizedBox(width: 8),
                                  Text('Firestore & Cloudinary Live Sync', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Dashboard Body Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: _buildBodyContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildApprovalsTab();
      case 2:
        return _buildStoresTab();
      case 3:
        return _buildOrdersTab();
      case 4:
        return _buildDriversTab();
      case 5:
        return _buildExchangeTab();
      case 6:
        return _buildMultiRegionTab();
      case 7:
        return _buildCommissionsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Expanded(child: _KPICard(title: 'Gross Merchandise Value (GMV)', value: '₹1,84,520', subtitle: 'This Month (+18.4%)', color: AppColors.accent)),
            SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Active Stores (Kubernagar / Sindhu Bhavan)', value: '38 Stores', subtitle: '94% Onboarded & Verified', color: AppColors.primary)),
            SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Platform Commission (10%)', value: '₹18,452', subtitle: 'Direct Net Margin', color: AppColors.purple)),
            SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Verified Riders Fleet', value: '42 Drivers', subtitle: 'Aadhaar & License KYC Verified', color: AppColors.tomato)),
          ],
        ),
      ],
    );
  }

  Widget _buildApprovalsTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Merchant KYC & Store Onboarding Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Store Name')),
                DataColumn(label: Text('Owner')),
                DataColumn(label: Text('Cluster / City')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('Navkar Menswear & Suits')),
                  const DataCell(Text('Prakash Jain')),
                  const DataCell(Text('Sindhu Bhavan Road (SBR)')),
                  const DataCell(Text('+91 98251 44556')),
                  const DataCell(Chip(label: Text('PENDING KYC'), backgroundColor: Color(0xFFFFF3CD))),
                  DataCell(Row(
                    children: [
                      ElevatedButton(onPressed: () {}, child: const Text('Approve')),
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: () {}, child: const Text('Reject')),
                    ],
                  )),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoresTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Live Store Catalogs across Kubernagar, Sindhu Bhavan Road, Bodakdev, and Gandhinagar are healthy and operational.'),
      ),
    );
  }

  Widget _buildOrdersTab() {
    final orders = OrderSyncService.currentOrders;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Live Orders & Concurrency Dispatch Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1E7DD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('DISPATCH LOCK: ACTIVE', style: TextStyle(color: Color(0xFF0F5132), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Store')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Payment Method')),
                  DataColumn(label: Text('Grand Total')),
                  DataColumn(label: Text('Assigned Rider')),
                  DataColumn(label: Text('Concurrency Lock')),
                  DataColumn(label: Text('Order Status')),
                ],
                rows: orders.map((o) {
                  final isCod = o.paymentMethod == PaymentMethod.cod;
                  final lockText = o.driverId != null
                      ? '🔒 Locked to ${o.driverId}'
                      : '🟢 Open in Pool';

                  return DataRow(cells: [
                    DataCell(Text(o.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(o.storeId)),
                    DataCell(Text(o.deliveryAddressSnapshot['recipientName'] ?? 'Customer')),
                    DataCell(Row(
                      children: [
                        Icon(isCod ? Icons.payments_rounded : Icons.credit_card_rounded, size: 16, color: isCod ? Colors.amber.shade800 : Colors.green.shade800),
                        const SizedBox(width: 4),
                        Text(isCod ? 'Cash on Delivery' : 'Prepaid (Online)'),
                      ],
                    )),
                    DataCell(Text('₹${(o.pricing.grandTotal / 100).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(o.driverId ?? 'Unassigned')),
                    DataCell(Chip(
                      label: Text(lockText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: o.driverId != null ? const Color(0xFFE2E3E5) : const Color(0xFFD1E7DD),
                    )),
                    DataCell(Chip(
                      label: Text(o.status.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: o.status == OrderStatus.delivered ? const Color(0xFFD1E7DD) : const Color(0xFFFFF3CD),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriversTab() {
    final sureshCod = OrderSyncService.getDriverCodSummary('driver-1', 'Suresh Solanki');
    final remittances = OrderSyncService.currentRemittances;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Orchestration & Multi-Driver Concurrency Guard Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_person_rounded, color: AppColors.primary, size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Multi-Driver Mutual Exclusion Orchestrator Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                    SizedBox(height: 2),
                    Text(
                      'When a driver accepts an assignment, atomic lock binds the delivery. Other fleet riders cannot claim or accept it, guaranteeing zero duplicate drivers at pickup locations.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // COD Cash Reconciliation Snapshot
        Row(
          children: [
            Expanded(child: _KPICard(title: 'Fleet Cash In Hand (To Collect)', value: sureshCod.pendingCashDisplay, subtitle: 'Due from Drivers', color: AppColors.tomato)),
            const SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Total COD Orders Delivered', value: '${sureshCod.totalCodOrders} Trips', subtitle: sureshCod.collectedDisplay, color: AppColors.accent)),
            const SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Prepaid (UPI) Deliveries', value: '${sureshCod.totalOnlinePaidOrders} Trips', subtitle: 'Zero cash collected', color: AppColors.primary)),
            const SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Cash Remitted to Co.', value: sureshCod.remittedDisplay, subtitle: '${remittances.length} Remittance batches', color: AppColors.purple)),
          ],
        ),

        const SizedBox(height: 20),

        // Drivers Fleet & Cash Ledger Table
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rider Fleet, Cash Reconciliation & Concurrency Locks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Rider Name')),
                      DataColumn(label: Text('Vehicle & Reg')),
                      DataColumn(label: Text('Cluster')),
                      DataColumn(label: Text('COD Cash Collected')),
                      DataColumn(label: Text('Prepaid UPI Drops')),
                      DataColumn(label: Text('Pending Cash Remittance')),
                      DataColumn(label: Text('Active Concurrency Lock')),
                      DataColumn(label: Text('Duty Status')),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Row(
                          children: [
                            CircleAvatar(backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100')),
                            SizedBox(width: 8),
                            Text('Suresh Solanki', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )),
                        const DataCell(Text('Honda Activa\nGJ-01-AB-1234')),
                        const DataCell(Text('Kubernagar Cluster')),
                        DataCell(Text(sureshCod.collectedDisplay, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('${sureshCod.totalOnlinePaidOrders} Drops')),
                        DataCell(Text(sureshCod.pendingCashDisplay, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                        const DataCell(Chip(label: Text('🔒 ORD-8920 Locked', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFD1E7DD))),
                        const DataCell(Chip(label: Text('ONLINE'), backgroundColor: Color(0xFFD1E7DD))),
                      ]),
                      const DataRow(cells: [
                        DataCell(Row(
                          children: [
                            CircleAvatar(backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100')),
                            SizedBox(width: 8),
                            Text('Manish Vaghela', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )),
                        DataCell(Text('Hero Splendor\nGJ-18-CD-5678')),
                        DataCell(Text('Sindhu Bhavan & Bodakdev')),
                        DataCell(Text('₹2,400', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('4 Drops')),
                        DataCell(Text('₹0 (Settled)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                        DataCell(Chip(label: Text('🟢 Idle / Radar', style: TextStyle(fontSize: 10)), backgroundColor: Color(0xFFE2E3E5))),
                        DataCell(Chip(label: Text('ONLINE'), backgroundColor: Color(0xFFD1E7DD))),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Hub Counter Physical Cash Handover & OTP Settlement Desk
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.store_rounded, color: AppColors.accent, size: 24),
                        SizedBox(width: 8),
                        Text('Hub Counter Cash Handover & OTP Verification Desk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.purple),
                      ),
                      child: const Text('PHYSICAL CASH SETTLEMENT WITH OTP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'When a rider arrives at a hub (Kubernagar, Gandhinagar, etc.) to hand over cash, the rider generates an OTP sent to their email. Admin collects cash, inputs the rider OTP below, and verifies settlement.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Handover ID')),
                      DataColumn(label: Text('Hub Collection Location')),
                      DataColumn(label: Text('Rider Name & Email')),
                      DataColumn(label: Text('Cash Amount')),
                      DataColumn(label: Text('OTP Status')),
                      DataColumn(label: Text('Receipt / Verified At')),
                      DataColumn(label: Text('Admin Action')),
                    ],
                    rows: OrderSyncService.currentHandovers.map((h) {
                      return DataRow(cells: [
                        DataCell(Text(h.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(h.hubLocation)),
                        DataCell(Text('${h.driverName}\n${h.driverEmail}', style: const TextStyle(fontSize: 11))),
                        DataCell(Text(h.amountDisplay, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.tomato, fontSize: 15))),
                        DataCell(Chip(
                          label: Text(
                            h.isVerified ? 'VERIFIED ✅' : 'AWAITING OTP ENTRY',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: h.isVerified ? AppColors.success : AppColors.tomato),
                          ),
                          backgroundColor: h.isVerified ? AppColors.success.withValues(alpha: 0.12) : AppColors.tomato.withValues(alpha: 0.12),
                        )),
                        DataCell(Text(
                          h.isVerified
                              ? '${h.receiptNumber}\n${h.verifiedAt?.hour}:${h.verifiedAt?.minute.toString().padLeft(2, '0')}'
                              : 'Pending Verification',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        )),
                        DataCell(
                          h.isVerified
                              ? const Row(
                                  children: [
                                    Icon(Icons.check_circle, size: 14, color: AppColors.success),
                                    SizedBox(width: 4),
                                    Text('Cash Settled', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  icon: const Icon(Icons.pin_rounded, size: 14, color: Colors.white),
                                  label: const Text('Verify Rider OTP', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  onPressed: () => _showVerifyOtpDialog(context, h),
                                ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Cash Remittance Verifications
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cash Remittance Submissions & Admin Settlement Ledger', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Verify driver deposits received via Company UPI or physical hub collection.', style: TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Remittance ID')),
                      DataColumn(label: Text('Driver Name')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Mode')),
                      DataColumn(label: Text('Reference / UTR')),
                      DataColumn(label: Text('Submitted At')),
                      DataColumn(label: Text('Verification Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: remittances.map((r) {
                      return DataRow(cells: [
                        DataCell(Text(r.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(r.driverName)),
                        DataCell(Text(r.amountDisplay, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(r.paymentMode)),
                        DataCell(Text(r.referenceNumber, style: const TextStyle(fontFamily: 'monospace'))),
                        DataCell(Text('${r.submittedAt.day}/${r.submittedAt.month} ${r.submittedAt.hour}:${r.submittedAt.minute.toString().padLeft(2, '0')}')),
                        DataCell(Chip(
                          label: Text(
                            r.isVerifiedByAdmin ? 'VERIFIED ✅' : 'PENDING APPROVAL',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: r.isVerifiedByAdmin ? AppColors.success : AppColors.tomato),
                          ),
                          backgroundColor: r.isVerifiedByAdmin ? AppColors.success.withValues(alpha: 0.12) : AppColors.tomato.withValues(alpha: 0.12),
                        )),
                        DataCell(
                          r.isVerifiedByAdmin
                              ? const Text('Settled', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  onPressed: () {
                                    OrderSyncService.verifyRemittanceByAdmin(r.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Remittance ${r.id} verified and settled!')),
                                    );
                                  },
                                  child: const Text('Verify & Settle', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Size Exchange Portal & Reverse Logistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Customers can request size exchanges within 48 hours of delivery. Reverse pickup is auto-assigned to nearest cluster rider.', style: TextStyle(color: Color(0xFF6C757D))),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Exchange ID')),
                DataColumn(label: Text('Original Order')),
                DataColumn(label: Text('Item & From Size')),
                DataColumn(label: Text('Requested Size')),
                DataColumn(label: Text('Exchange Fee')),
                DataColumn(label: Text('Reverse Status')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('EXC-101')),
                  DataCell(Text('ORD-8920')),
                  DataCell(Text('Royal Velvet Kurti (Size M)')),
                  DataCell(Text('Size L')),
                  DataCell(Text('₹49 (Exchange Surcharge)')),
                  DataCell(Chip(label: Text('RIDER ASSIGNED'), backgroundColor: Color(0xFFD1E7DD))),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiRegionTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Multi-Region Geofencing & Delivery Radius Orchestrator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.location_on, color: AppColors.primary),
              title: Text('Cluster 1: Kubernagar & East Ahmedabad'),
              subtitle: Text('Max Delivery Radius: 12 km • Max Promised Time: 45 Minutes'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.location_on, color: AppColors.accent),
              title: Text('Cluster 2: Gandhinagar Capital Region'),
              subtitle: Text('Max Delivery Radius: 15 km • Max Promised Time: 50 Minutes'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.location_on, color: AppColors.success),
              title: Text('Cluster 3: Sindhu Bhavan Road & Bodakdev (West Ahmedabad)'),
              subtitle: Text('Cross-City Radius: 20+ km • Dynamic ETA (No 45-min lock) • Distance matrix automated'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionsTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commissions, Settlements & Store Coins Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.tune_rounded, color: AppColors.primary),
              title: Text('Platform Commission Rate'),
              subtitle: Text('Default: 10% on delivered order subtotal'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.monetization_on_rounded, color: AppColors.accent),
              title: Text('Store Coins Referral Ratio'),
              subtitle: Text('1 Coin earned per ₹100 of referral order value • Direct shareable affiliate referral link supported'),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerifyOtpDialog(BuildContext context, DriverHubHandoverRequest handover) {
    final otpCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Verify Rider COD Cash Handover'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hub: ${handover.hubLocation}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Rider: ${handover.driverName} (${handover.driverEmail})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Physical Cash to Collect:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(handover.amountDisplay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(letterSpacing: 8, fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Enter 6-Digit OTP Provided by Rider',
                  prefixIcon: const Icon(Icons.key_rounded),
                  border: const OutlineInputBorder(),
                  helperText: 'OTP sent to rider (${handover.driverEmail})',
                ),
              ),
              const SizedBox(height: 8),
              // Fast simulation / testing helper
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 14),
                    label: Text('Autofill Rider OTP: ${handover.otp} (Test Mode)', style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      otpCtrl.text = handover.otp;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
            label: const Text('Accept Cash & Verify OTP', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final res = await OrderSyncService.verifyHubCashHandoverWithOtp(
                handoverId: handover.id,
                enteredOtp: otpCtrl.text.trim(),
                adminId: 'ADMIN-KUBERNAGAR-01',
              );
              Navigator.pop(ctx);
              if (res.$1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: AppColors.primary, content: Text('✅ ${res.$2}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: AppColors.tomato, content: Text('❌ ${res.$2}')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _KPICard({required this.title, required this.value, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}
