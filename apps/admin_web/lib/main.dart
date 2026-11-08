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

  // Start real-time cross-app order synchronization bus
  OrderSyncService.startBackgroundSync();

  runApp(const ProviderScope(child: AdminDashboardApp()));
}

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARS Admin — Central Admin Portal',
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

  Widget _buildSidebar({bool isDrawer = false}) {
    final content = Container(
      width: 270,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MARS FASHION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Admin Console', style: TextStyle(color: AppColors.textHint, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('MAIN NAVIGATION', style: TextStyle(color: AppColors.textHint, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
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
                  Icons.near_me_rounded,
                  Icons.change_circle_rounded,
                  Icons.map_rounded,
                  Icons.account_balance_wallet_rounded,
                ];

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    selected: isSelected,
                    selectedTileColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    leading: Icon(icons[index], color: isSelected ? AppColors.accent : AppColors.textHint, size: 18),
                    title: Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textHint,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedTab = index);
                      if (isDrawer) Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(color: Color(0xFF2C2C2C)),
          const ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accent,
              child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            title: Text('Admin Manager', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            subtitle: Text('admin@marsfashion.in', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
          ),
        ],
      ),
    );

    return isDrawer ? SafeArea(child: content) : content;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(_tabs[_selectedTab], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              backgroundColor: AppColors.primary,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  tooltip: 'Sync Status',
                  icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Real-time sync active across all applications.')),
                    );
                  },
                ),
              ],
            )
          : null,
      drawer: isMobile ? Drawer(child: _buildSidebar(isDrawer: true)) : null,
      body: isMobile
          ? Container(
              color: AppColors.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: _buildBodyContent(isMobile: true),
              ),
            )
          : Row(
              children: [
                _buildSidebar(isDrawer: false),
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: Column(
                      children: [
                        // Top App Bar
                        Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _tabs[_selectedTab],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.cloud_done_rounded, color: AppColors.success, size: 16),
                                        SizedBox(width: 6),
                                        Text('Firestore & Cloudinary Live Sync', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
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
                            padding: const EdgeInsets.all(24),
                            child: _buildBodyContent(isMobile: false),
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

  Widget _buildBodyContent({required bool isMobile}) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(isMobile);
      case 1:
        return _buildApprovalsTab(isMobile);
      case 2:
        return _buildStoresTab(isMobile);
      case 3:
        return _buildOrdersTab(isMobile);
      case 4:
        return _buildDriversTab(isMobile);
      case 5:
        return _buildExchangeTab(isMobile);
      case 6:
        return _buildMultiRegionTab(isMobile);
      case 7:
        return _buildCommissionsTab(isMobile);
      default:
        return _buildOverviewTab(isMobile);
    }
  }

  Widget _buildKPIGrid(List<_KPICardData> cards, {required bool isMobile}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int crossAxisCount = width < 450 ? 1 : (width < 800 ? 2 : 4);
        final double childAspectRatio = width < 450 ? 2.8 : (width < 800 ? 1.6 : 1.7);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: cards.length,
          itemBuilder: (ctx, i) => _KPICard(data: cards[i]),
        );
      },
    );
  }

  Widget _buildOverviewTab(bool isMobile) {
    final orders = OrderSyncService.currentOrders;

    final cards = [
      const _KPICardData(title: 'Gross Merchandise Value', value: '₹1,84,520', subtitle: 'This Month (+18.4%)', color: AppColors.accent),
      const _KPICardData(title: 'Active Stores', value: '38 Stores', subtitle: 'Kubernagar & SBR Cluster', color: AppColors.primary),
      const _KPICardData(title: 'Platform Commission (10%)', value: '₹18,452', subtitle: 'Direct Net Margin', color: AppColors.purple),
      const _KPICardData(title: 'Verified Riders Fleet', value: '42 Drivers', subtitle: 'KYC Verified Active', color: AppColors.tomato),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKPIGrid(cards, isMobile: isMobile),
        const SizedBox(height: 20),

        // Quick Navigation Actions
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick Action Shortcuts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => setState(() => _selectedTab = 1),
                      child: const Text('Review Vendor KYC (1 Pending)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => setState(() => _selectedTab = 3),
                      child: Text('Live Orders Pool (${orders.length} Active)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => setState(() => _selectedTab = 4),
                      child: const Text('Hub Cash Handover & OTP Desk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Live Order Snapshot
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Text('Real-Time Order Feed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('CROSS-APP SYNC: LIVE', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No active orders in pool currently.')),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('Order ID')),
                        DataColumn(label: Text('Store')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Payment')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Assigned Rider')),
                      ],
                      rows: orders.take(5).map((o) {
                        final isCod = o.paymentMethod == PaymentMethod.cod;
                        return DataRow(cells: [
                          DataCell(Text(o.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataCell(Text(o.storeId, style: const TextStyle(fontSize: 12))),
                          DataCell(Text('₹${(o.pricing.grandTotal / 100).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataCell(Text(isCod ? 'Cash on Delivery' : 'Prepaid (Online)', style: const TextStyle(fontSize: 12))),
                          DataCell(Chip(
                            label: Text(o.status.name.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                            backgroundColor: o.status == OrderStatus.delivered ? const Color(0xFFD1E7DD) : const Color(0xFFFFF3CD),
                            padding: EdgeInsets.zero,
                          )),
                          DataCell(Text(o.driverId ?? 'In Open Pool', style: TextStyle(fontSize: 12, color: o.driverId != null ? AppColors.textPrimary : AppColors.accent))),
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

  Widget _buildApprovalsTab(bool isMobile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                const Text('Merchant KYC & Store Onboarding Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('1 PENDING VERIFICATION', style: TextStyle(color: Color(0xFF856404), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
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
                    const DataCell(Text('Navkar Menswear & Suits', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataCell(Text('Prakash Jain')),
                    const DataCell(Text('Sindhu Bhavan Road (SBR)')),
                    const DataCell(Text('+91 98251 44556')),
                    const DataCell(Chip(label: Text('PENDING KYC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFFFF3CD))),
                    DataCell(Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navkar Menswear approved and onboarded to SBR cluster!')),
                            );
                          },
                          child: const Text('Approve', style: TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Onboarding request rejected.')),
                            );
                          },
                          child: const Text('Reject', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    )),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoresTab(bool isMobile) {
    final stores = [
      {'name': 'Navkar Menswear & Suits', 'cluster': 'Sindhu Bhavan Road (SBR)', 'items': '142 Items', 'status': 'ACTIVE', 'orders': '18 Today'},
      {'name': 'Rajwadi Ethnic & Bridal', 'cluster': 'Kubernagar Main Bazar', 'items': '380 Items', 'status': 'ACTIVE', 'orders': '34 Today'},
      {'name': 'Kubernagar Denim Hub', 'cluster': 'Kubernagar Cluster', 'items': '95 Items', 'status': 'ACTIVE', 'orders': '12 Today'},
      {'name': 'Metro Vogue Boutique', 'cluster': 'Gandhinagar Sector 11', 'items': '210 Items', 'status': 'ACTIVE', 'orders': '22 Today'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Text('Registered Clothing Retailers & Outlets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('4 ACTIVE STORES', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('All stores are synced with catalog images, real-time inventory, and 45-minute delivery radiuses.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 22,
                    columns: const [
                      DataColumn(label: Text('Store Name')),
                      DataColumn(label: Text('Cluster Location')),
                      DataColumn(label: Text('Inventory Size')),
                      DataColumn(label: Text('Dispatches')),
                      DataColumn(label: Text('Operational Status')),
                    ],
                    rows: stores.map((s) {
                      return DataRow(cells: [
                        DataCell(Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(s['cluster']!)),
                        DataCell(Text(s['items']!)),
                        DataCell(Text(s['orders']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent))),
                        DataCell(Chip(
                          label: Text(s['status']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
                          backgroundColor: AppColors.success.withValues(alpha: 0.12),
                          padding: EdgeInsets.zero,
                        )),
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

  Widget _buildOrdersTab(bool isMobile) {
    final orders = OrderSyncService.currentOrders;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                const Text('Live Orders & Concurrency Dispatch Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1E7DD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('DISPATCH LOCK: ACTIVE', style: TextStyle(color: Color(0xFF0F5132), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
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
                    DataCell(Text(isCod ? 'Cash on Delivery' : 'Prepaid (Online)')),
                    DataCell(Text('₹${(o.pricing.grandTotal / 100).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(o.driverId ?? 'Unassigned')),
                    DataCell(Chip(
                      label: Text(lockText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: o.driverId != null ? const Color(0xFFE2E3E5) : const Color(0xFFD1E7DD),
                      padding: EdgeInsets.zero,
                    )),
                    DataCell(Chip(
                      label: Text(o.status.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: o.status == OrderStatus.delivered ? const Color(0xFFD1E7DD) : const Color(0xFFFFF3CD),
                      padding: EdgeInsets.zero,
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

  Widget _buildDriversTab(bool isMobile) {
    final sureshCod = OrderSyncService.getDriverCodSummary('driver-1', 'Suresh Solanki');
    final remittances = OrderSyncService.currentRemittances;

    final cards = [
      _KPICardData(title: 'Fleet Cash In Hand', value: sureshCod.pendingCashDisplay, subtitle: 'Due from Drivers', color: AppColors.tomato),
      _KPICardData(title: 'COD Orders Delivered', value: '${sureshCod.totalCodOrders} Trips', subtitle: sureshCod.collectedDisplay, color: AppColors.accent),
      _KPICardData(title: 'Prepaid (UPI) Deliveries', value: '${sureshCod.totalOnlinePaidOrders} Trips', subtitle: 'Zero cash collected', color: AppColors.primary),
      _KPICardData(title: 'Cash Remitted to Co.', value: sureshCod.remittedDisplay, subtitle: '${remittances.length} Remittance batches', color: AppColors.purple),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Orchestration & Multi-Driver Concurrency Guard Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Multi-Driver Mutual Exclusion Orchestrator Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
              SizedBox(height: 4),
              Text(
                'When a driver accepts an assignment, atomic lock binds the delivery. Other fleet riders cannot claim or accept it, guaranteeing zero duplicate drivers at pickup locations.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // COD Cash Reconciliation Snapshot
        _buildKPIGrid(cards, isMobile: isMobile),

        const SizedBox(height: 16),

        // Hub Counter Physical Cash Handover & OTP Settlement Desk
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Text('Hub Counter Cash Handover & OTP Verification Desk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.purple),
                      ),
                      child: const Text('PHYSICAL CASH SETTLEMENT WITH OTP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'When a rider arrives at a hub (Kubernagar, Gandhinagar, etc.) to hand over cash, the rider generates an OTP sent to their email. Admin collects cash, inputs the rider OTP below, and verifies settlement.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 18,
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
                        DataCell(Text(h.amountDisplay, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.tomato, fontSize: 14))),
                        DataCell(Chip(
                          label: Text(
                            h.isVerified ? 'VERIFIED ✅' : 'AWAITING OTP ENTRY',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: h.isVerified ? AppColors.success : AppColors.tomato),
                          ),
                          backgroundColor: h.isVerified ? AppColors.success.withValues(alpha: 0.12) : AppColors.tomato.withValues(alpha: 0.12),
                          padding: EdgeInsets.zero,
                        )),
                        DataCell(Text(
                          h.isVerified
                              ? '${h.receiptNumber}\n${h.verifiedAt?.hour}:${h.verifiedAt?.minute.toString().padLeft(2, '0')}'
                              : 'Pending Verification',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        )),
                        DataCell(
                          h.isVerified
                              ? const Text('Cash Settled', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11))
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                  onPressed: () => _showVerifyOtpDialog(context, h),
                                  child: const Text('Verify Rider OTP', style: TextStyle(fontSize: 11, color: Colors.white)),
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

        const SizedBox(height: 16),

        // Cash Remittance Verifications
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cash Remittance Submissions & Admin Settlement Ledger', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Verify driver deposits received via Company UPI or physical hub collection.', style: TextStyle(fontSize: 11, color: Color(0xFF6C757D))),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 18,
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
                        DataCell(Text(r.referenceNumber, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DataCell(Text('${r.submittedAt.day}/${r.submittedAt.month} ${r.submittedAt.hour}:${r.submittedAt.minute.toString().padLeft(2, '0')}')),
                        DataCell(Chip(
                          label: Text(
                            r.isVerifiedByAdmin ? 'VERIFIED ✅' : 'PENDING APPROVAL',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: r.isVerifiedByAdmin ? AppColors.success : AppColors.tomato),
                          ),
                          backgroundColor: r.isVerifiedByAdmin ? AppColors.success.withValues(alpha: 0.12) : AppColors.tomato.withValues(alpha: 0.12),
                          padding: EdgeInsets.zero,
                        )),
                        DataCell(
                          r.isVerifiedByAdmin
                              ? const Text('Settled', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11))
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                  onPressed: () {
                                    OrderSyncService.verifyRemittanceByAdmin(r.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Remittance ${r.id} verified and settled!')),
                                    );
                                  },
                                  child: const Text('Verify & Settle', style: TextStyle(fontSize: 11, color: Colors.white)),
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

  Widget _buildExchangeTab(bool isMobile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Size Exchange Portal & Reverse Logistics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Customers can request size exchanges within 48 hours of delivery. Reverse pickup is auto-assigned to nearest cluster rider.', style: TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
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
                    DataCell(Text('EXC-101', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('ORD-8920')),
                    DataCell(Text('Royal Velvet Kurti (Size M)')),
                    DataCell(Text('Size L')),
                    DataCell(Text('₹49 (Exchange Surcharge)')),
                    DataCell(Chip(label: Text('RIDER ASSIGNED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFD1E7DD), padding: EdgeInsets.zero)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiRegionTab(bool isMobile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Multi-Region Geofencing & Delivery Radius Orchestrator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 14),
            ListTile(
              dense: true,
              title: Text('Cluster 1: Kubernagar & East Ahmedabad', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Max Delivery Radius: 12 km • Max Promised Time: 45 Minutes'),
            ),
            Divider(),
            ListTile(
              dense: true,
              title: Text('Cluster 2: Gandhinagar Capital Region', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Max Delivery Radius: 15 km • Max Promised Time: 50 Minutes'),
            ),
            Divider(),
            ListTile(
              dense: true,
              title: Text('Cluster 3: Sindhu Bhavan Road & Bodakdev (West Ahmedabad)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Cross-City Radius: 20+ km • Dynamic ETA (No 45-min lock) • Distance matrix automated'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionsTab(bool isMobile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commissions, Settlements & Store Coins Policy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 14),
            ListTile(
              dense: true,
              title: Text('Platform Commission Rate', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Default: 10% on delivered order subtotal'),
            ),
            Divider(),
            ListTile(
              dense: true,
              title: Text('Store Coins Referral Ratio', style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('Verify Rider COD Cash Handover'),
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
                  border: const OutlineInputBorder(),
                  helperText: 'OTP sent to rider (${handover.driverEmail})',
                ),
              ),
              const SizedBox(height: 8),
              // Fast simulation / testing helper
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      otpCtrl.text = handover.otp;
                    },
                    child: Text('Autofill Rider OTP: ${handover.otp} (Test Mode)', style: const TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final res = await OrderSyncService.verifyHubCashHandoverWithOtp(
                handoverId: handover.id,
                enteredOtp: otpCtrl.text.trim(),
                adminId: 'ADMIN-KUBERNAGAR-01',
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (res.$1) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(backgroundColor: AppColors.primary, content: Text('✅ ${res.$2}')),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(backgroundColor: AppColors.tomato, content: Text('❌ ${res.$2}')),
                );
              }
            },
            child: const Text('Accept Cash & Verify OTP'),
          ),
        ],
      ),
    );
  }
}

class _KPICardData {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _KPICardData({required this.title, required this.value, required this.subtitle, required this.color});
}

class _KPICard extends StatelessWidget {
  final _KPICardData data;

  const _KPICard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.cardBorder)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              data.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: data.color),
            ),
            const SizedBox(height: 2),
            Text(
              data.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
