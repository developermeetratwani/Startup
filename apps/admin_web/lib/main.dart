import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
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

  final _tabs = [
    'Overview & Metrics',
    'Vendor Approvals',
    'Clothing Stores',
    'Order Monitoring',
    'Driver Fleet',
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
            color: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE94560),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('XYZ STARTUP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Admin Console', style: TextStyle(color: Color(0xFFADB5BD), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                const Text('MAIN NAVIGATION', style: TextStyle(color: Color(0xFF6C757D), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                ...List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  final icons = [
                    Icons.analytics_rounded,
                    Icons.how_to_reg_rounded,
                    Icons.store_mall_directory_rounded,
                    Icons.receipt_long_rounded,
                    Icons.two_wheeler_rounded,
                    Icons.account_balance_wallet_rounded,
                  ];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      tileColor: isSelected ? const Color(0xFFE94560) : Colors.transparent,
                      leading: Icon(icons[index], color: isSelected ? Colors.white : const Color(0xFFADB5BD), size: 20),
                      title: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFADB5BD),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () => setState(() => _selectedTab = index),
                    ),
                  );
                }),

                const Spacer(),
                const Divider(color: Color(0xFF2B2D42)),
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFFE94560), size: 16),
                    SizedBox(width: 6),
                    Text('Kubernagar & Gandhinagar', style: TextStyle(color: Color(0xFFADB5BD), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          // Main Content View
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFE9ECEF))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tabs[_selectedTab],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Chip(
                            avatar: const Icon(Icons.circle, color: Colors.green, size: 10),
                            label: const Text('Live Network Asia-South1'),
                            backgroundColor: Colors.green.withValues(alpha: 0.1),
                          ),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF1A1A2E),
                            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Body based on tab
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildCurrentTab(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildVendorApprovalsTab();
      case 2:
        return _buildStoresTab();
      case 3:
        return _buildOrdersTab();
      case 4:
        return _buildDriversTab();
      case 5:
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
          children: [
            Expanded(child: _KPICard(title: 'Gross Platform Sales', value: '₹4,82,500', subtitle: '+18% this week', color: AppColors.primary)),
            const SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Platform Commission (10%)', value: '₹48,250', subtitle: 'Configurable rate', color: AppColors.success)),
            const SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Active Clothing Stores', value: '18 Stores', subtitle: 'Kubernagar & Gandhinagar', color: AppColors.accent)),
            const SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Active Delivery Riders', value: '24 Riders', subtitle: '16 Online on duty', color: AppColors.info)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Live Marketplace Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Order ID')),
                          DataColumn(label: Text('Market Cluster')),
                          DataColumn(label: Text('Store Name')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: const [
                          DataRow(cells: [
                            DataCell(Text('#ORD-9021')),
                            DataCell(Text('Kubernagar')),
                            DataCell(Text('Shreeji Ethnic Studio')),
                            DataCell(Text('₹2,499')),
                            DataCell(Chip(label: Text('Preparing', style: TextStyle(fontSize: 11)), backgroundColor: Color(0xFFFFF3CD))),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('#ORD-9020')),
                            DataCell(Text('Gandhinagar (Sec 21)')),
                            DataCell(Text('Infocity Fashion Hub')),
                            DataCell(Text('₹1,199')),
                            DataCell(Chip(label: Text('Delivered', style: TextStyle(fontSize: 11)), backgroundColor: Color(0xFFD1E7DD))),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('#ORD-9019')),
                            DataCell(Text('Kubernagar')),
                            DataCell(Text('Vogue Mens Club')),
                            DataCell(Text('₹899')),
                            DataCell(Chip(label: Text('Out for Delivery', style: TextStyle(fontSize: 11)), backgroundColor: Color(0xFFCFE2FF))),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Market Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      _MarketProgress(market: 'Kubernagar (East Ahmedabad)', share: '62% of volume', percentage: 0.62),
                      const SizedBox(height: 14),
                      _MarketProgress(market: 'Gandhinagar (Sectors 1-30)', share: '38% of volume', percentage: 0.38),
                      const Divider(height: 32),
                      const Text('Referral Coins Engine', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('12,450 Store Coins issued to referring retailers across 14 campaigns.', style: TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVendorApprovalsTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pending Retailer Applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Verify retail store presence and approve to generate store credentials & referral code', style: TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
            const SizedBox(height: 20),
            DataTable(
              columns: const [
                DataColumn(label: Text('Store Name')),
                DataColumn(label: Text('Owner')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Market Cluster')),
                DataColumn(label: Text('Applied Date')),
                DataColumn(label: Text('Action')),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('Kalamandir Handlooms & Sarees')),
                  const DataCell(Text('Sanjay Somani')),
                  const DataCell(Text('+91 98250 11223')),
                  const DataCell(Text('Gandhinagar (Sec 16)')),
                  const DataCell(Text('Today, 01:15 PM')),
                  DataCell(Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store Approved! Custom claims & Store Coins generated.')));
                        },
                        child: const Text('Approve Store', style: TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                        onPressed: () {},
                        child: const Text('Reject', style: TextStyle(fontSize: 11)),
                      ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registered Clothing Retailers (18 Active)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Store Name')),
                DataColumn(label: Text('Cluster')),
                DataColumn(label: Text('Categories')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Rating')),
                DataColumn(label: Text('Store Coins Balance')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('Shreeji Ethnic & Bridal Studio')),
                  DataCell(Text('Kubernagar')),
                  DataCell(Text('Women, Ethnic')),
                  DataCell(Chip(label: Text('Active (Online)'), backgroundColor: Color(0xFFD1E7DD))),
                  DataCell(Text('4.8 ★ (142)')),
                  DataCell(Text('350 Coins')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Vogue Mens Club & Denim')),
                  DataCell(Text('Kubernagar')),
                  DataCell(Text('Men, Western')),
                  DataCell(Chip(label: Text('Active (Online)'), backgroundColor: Color(0xFFD1E7DD))),
                  DataCell(Text('4.6 ★ (98)')),
                  DataCell(Text('200 Coins')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Infocity Fashion Hub')),
                  DataCell(Text('Gandhinagar')),
                  DataCell(Text('Women, Men, Western')),
                  DataCell(Chip(label: Text('Active (Online)'), backgroundColor: Color(0xFFD1E7DD))),
                  DataCell(Text('4.9 ★ (215)')),
                  DataCell(Text('520 Coins')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Marketplace Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Store')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Payment')),
                DataColumn(label: Text('Status')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('ORD-8921')),
                  DataCell(Text('Shreeji Ethnic Studio')),
                  DataCell(Text('Kavya Sharma')),
                  DataCell(Text('₹924')),
                  DataCell(Text('COD')),
                  DataCell(Text('Preparing')),
                ]),
                DataRow(cells: [
                  DataCell(Text('ORD-8919')),
                  DataCell(Text('Shreeji Ethnic Studio')),
                  DataCell(Text('Priya Patel')),
                  DataCell(Text('₹2,499')),
                  DataCell(Text('Razorpay Online (Paid)')),
                  DataCell(Text('Confirmed')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriversTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Fleet & Live Rider Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Driver Name')),
                DataColumn(label: Text('Vehicle')),
                DataColumn(label: Text('Assigned Cluster')),
                DataColumn(label: Text('Duty Status')),
                DataColumn(label: Text('Active Deliveries')),
                DataColumn(label: Text('Rating')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('Suresh Solanki')),
                  DataCell(Text('Honda Activa (GJ-01-AB-1234)')),
                  DataCell(Text('Kubernagar')),
                  DataCell(Chip(label: Text('ONLINE'), backgroundColor: Color(0xFFD1E7DD))),
                  DataCell(Text('1 Active Drop')),
                  DataCell(Text('4.9 ★')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Manish Vaghela')),
                  DataCell(Text('Hero Splendor (GJ-18-CD-5678)')),
                  DataCell(Text('Gandhinagar')),
                  DataCell(Chip(label: Text('ONLINE'), backgroundColor: Color(0xFFD1E7DD))),
                  DataCell(Text('Idle (Waiting)')),
                  DataCell(Text('4.8 ★')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionsTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
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
              subtitle: Text('Default: 10% on delivered order subtotal (Configurable via Remote Config)'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.monetization_on_rounded, color: AppColors.accent),
              title: Text('Store Coins Referral Ratio'),
              subtitle: Text('1 Coin earned per ₹100 of referral order value • Redeemable against platform fees'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.calendar_today_rounded, color: AppColors.success),
              title: Text('Settlement Schedule'),
              subtitle: Text('Weekly automated cycle every Tuesday to retailer registered bank accounts'),
            ),
          ],
        ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D), fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFFADB5BD))),
          ],
        ),
      ),
    );
  }
}

class _MarketProgress extends StatelessWidget {
  final String market;
  final String share;
  final double percentage;

  const _MarketProgress({required this.market, required this.share, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(market, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(share, style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D))),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: percentage, backgroundColor: const Color(0xFFE9ECEF), color: AppColors.accent, minHeight: 6),
      ],
    );
  }
}
