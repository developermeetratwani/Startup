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
                          selectedTileColor: const Color(0xFF0F3460),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          leading: Icon(icons[index], color: isSelected ? const Color(0xFFE94560) : const Color(0xFFADB5BD), size: 20),
                          title: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFFADB5BD),
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
                const Divider(color: Color(0xFF2E3856)),
                const ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFE94560),
                    child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  title: Text('Admin Manager', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('admin@xyzstartup.in', style: TextStyle(color: Color(0xFFADB5BD), fontSize: 11)),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: Column(
                children: [
                  // Top App Bar
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Color(0xFFE9ECEF))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tabs[_selectedTab],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1E7DD),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.cloud_done_rounded, color: Color(0xFF0F5132), size: 16),
                                  SizedBox(width: 8),
                                  Text('Firestore & Cloudinary Live Sync', style: TextStyle(color: Color(0xFF0F5132), fontSize: 12, fontWeight: FontWeight.bold)),
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
            Expanded(child: _KPICard(title: 'Gross Merchandise Value (GMV)', value: '₹1,84,520', subtitle: 'This Month (+18.4%)', color: Color(0xFF0D6EFD))),
            SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Active Stores (Kubernagar/Vapi)', value: '38 Stores', subtitle: '94% Onboarded & Verified', color: Color(0xFF198754))),
            SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Platform Commission (10%)', value: '₹18,452', subtitle: 'Direct Net Margin', color: Color(0xFF6F42C1))),
            SizedBox(width: 16),
            Expanded(child: _KPICard(title: 'Verified Riders Fleet', value: '42 Drivers', subtitle: 'Aadhaar & License KYC Verified', color: Color(0xFFFD7E14))),
          ],
        ),
      ],
    );
  }

  Widget _buildApprovalsTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
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
                  const DataCell(Text('Vapi Main Market')),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Live Store Catalogs across Kubernagar, Gandhinagar, and Vapi are healthy and operational.'),
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
            const Text('Live Orders & Delivery Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Store')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Packaging + COD Fee')),
                DataColumn(label: Text('Status')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('ORD-8920')),
                  DataCell(Text('Shreeji Ethnic Studio')),
                  DataCell(Text('Meet Ratwani')),
                  DataCell(Text('₹899')),
                  DataCell(Text('₹9 (1% Pack) + ₹21 COD')),
                  DataCell(Text('Out for Delivery')),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rider Fleet, Aadhaar KYC & Vehicle Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_rounded),
                  label: const Text('Register New Rider'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Rider & Photo')),
                DataColumn(label: Text('Vehicle & Reg No.')),
                DataColumn(label: Text('Aadhaar / KYC')),
                DataColumn(label: Text('Electricity Bill')),
                DataColumn(label: Text('Cluster')),
                DataColumn(label: Text('Duty Status')),
                DataColumn(label: Text('Security Status')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Row(
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100')),
                      SizedBox(width: 8),
                      Text('Suresh Solanki'),
                    ],
                  )),
                  DataCell(Text('Honda Activa (GJ-01-AB-1234)\nPhoto: Uploaded ✅')),
                  DataCell(Text('XXXX-XXXX-8912\nVerified ✅')),
                  DataCell(Text('Torrent Power Bill ✅')),
                  DataCell(Text('Kubernagar Cluster')),
                  DataCell(Chip(label: Text('ONLINE'), backgroundColor: Color(0xFFD1E7DD))),
                  DataCell(Chip(label: Text('CLEAN RECORD'), backgroundColor: Color(0xFFD1E7DD))),
                ]),
                DataRow(cells: [
                  DataCell(Row(
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100')),
                      SizedBox(width: 8),
                      Text('Manish Vaghela'),
                    ],
                  )),
                  DataCell(Text('Hero Splendor (GJ-18-CD-5678)\nPhoto: Uploaded ✅')),
                  DataCell(Text('XXXX-XXXX-4567\nVerified ✅')),
                  DataCell(Text('UGVCL Bill Verified ✅')),
                  DataCell(Text('Gandhinagar & Vapi')),
                  DataCell(Chip(label: Text('ONLINE'), backgroundColor: Color(0xFFD1E7DD))),
                  DataCell(Chip(label: Text('CLEAN RECORD'), backgroundColor: Color(0xFFD1E7DD))),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeTab() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE9ECEF))),
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
              title: Text('Cluster 3: Vapi Industrial & Retail Belt'),
              subtitle: Text('Max Delivery Radius: 14 km • Max Promised Time: 40 Minutes • Distance matrix automated'),
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
