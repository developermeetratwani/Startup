import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';
import '../../providers/order_provider.dart';
import '../../widgets/driver_chat_dialog.dart';
import '../../widgets/support_chatbot_sheet.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  late final MapController _mapController;
  StreamSubscription<AppNotification>? _notificationSub;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();



    // Listen to real-time notification stream for in-app alert toasts
    _notificationSub = NotificationService.notificationStream.listen((notification) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: const Color(0xFF1E293B),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE23744),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                    Text(notification.body, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(singleOrderStreamProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Order Tracking'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.smart_toy_rounded, size: 16, color: AppColors.accent),
            label: const Text('Help AI', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
            onPressed: () => SupportChatbotSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          final statusSteps = [
            {'title': 'Order Placed', 'subtitle': 'Order received by marketplace', 'status': OrderStatus.pending},
            {'title': 'Order Confirmed', 'subtitle': 'Store accepted your order', 'status': OrderStatus.confirmed},
            {'title': 'Preparing Item', 'subtitle': 'Store is packing your clothing', 'status': OrderStatus.preparing},
            {'title': 'Ready for Pickup', 'subtitle': 'Handover to delivery partner', 'status': OrderStatus.readyForPickup},
            {'title': 'Out for Delivery', 'subtitle': 'Driver on the way to your address', 'status': OrderStatus.pickedUp},
            {'title': 'Delivered', 'subtitle': 'Package delivered to doorstep', 'status': OrderStatus.delivered},
          ];

          final int currentStepIndex = _getStepIndex(order.status);
          final bool isCancelled = order.status == OrderStatus.cancelled;
          final bool isExchange = order.status == OrderStatus.exchangeRequested || order.status == OrderStatus.exchanged;

          // Coordinates for Store, Rider, and Customer in Ahmedabad (Kubernagar)
          const storeLocation = LatLng(23.0768, 72.6346); // Kubernagar Store Hub
          const riderLocation = LatLng(23.0782, 72.6360); // Roaming Rider En Route
          const customerLocation = LatLng(23.0795, 72.6380); // Customer Doorstep

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── ZOMATO / SWIGGY HEADER STATUS HERO ────────────────────
                if (!isCancelled && order.status != OrderStatus.delivered) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE23744), Color(0xFFFF5252)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE23744).withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.status == OrderStatus.pickedUp
                                    ? 'Arriving in ~${order.estimatedDeliveryMinutes} Mins'
                                    : 'Preparing & Packing • ~${order.estimatedDeliveryMinutes} Mins',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white, letterSpacing: -0.3),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.status == OrderStatus.pickedUp
                                    ? 'Suresh Solanki is riding towards your address'
                                    : 'Boutique is carefully packaging your fashion pieces',
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(radius: 4, backgroundColor: Colors.green),
                              SizedBox(width: 5),
                              Text('LIVE ROUTE', style: TextStyle(color: Color(0xFF171717), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dynamic Traffic & Delay Status Banner
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Moderate Traffic on Kubernagar / S.G. Highway (+4 mins delay calculated)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7A4F01)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('SLIGHT DELAY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ),
                      ],
                    ),
                  ),
                ],

                // Size Exchange Requested Banner
                if (isExchange)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.change_circle_rounded, color: AppColors.warning, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Size Exchange Active: ${order.requestedExchangeSize ?? 'Requested'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                'Reason: ${order.exchangeReason ?? 'Size adjustment'}. Rider is en route with your replacement size.',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── AUTHENTIC SWIGGY & ZOMATO GRADE LIVE RADAR MAP ───────────
                if (!isCancelled) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 270,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: const MapOptions(
                              initialCenter: LatLng(23.0782, 72.6360),
                              initialZoom: 15.3,
                            ),
                            children: [
                              // High-DPI CartoDB Voyager Map Tiles (Clean Swiggy/Uber Look)
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                fallbackUrl: 'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                                userAgentPackageName: 'in.marsfashion.app',
                              ),

                              // Proximity Geofence Radius Ring (100m around destination)
                              CircleLayer(
                                circles: [
                                  CircleMarker(
                                    point: customerLocation,
                                    radius: 75,
                                    useRadiusInMeter: true,
                                    color: const Color(0x1810B981),
                                    borderColor: const Color(0x6610B981),
                                    borderStrokeWidth: 1.5,
                                  ),
                                ],
                              ),

                              // Route Polylines: Two-Layer Glow + Solid Brand Path
                              PolylineLayer(
                                polylines: [
                                  // Under-layer Soft Route Glow
                                  Polyline(
                                    points: const [storeLocation, riderLocation, customerLocation],
                                    color: const Color(0xFFE23744).withValues(alpha: 0.22),
                                    strokeWidth: 8.0,
                                  ),
                                  // Vibrant Forefront Courier Path
                                  Polyline(
                                    points: const [storeLocation, riderLocation, customerLocation],
                                    color: const Color(0xFFE23744),
                                    strokeWidth: 4.0,
                                  ),
                                ],
                              ),

                              // Custom Vector Markers Layer
                              MarkerLayer(
                                markers: [
                                  // 1. Boutique Store Pin
                                  Marker(
                                    point: storeLocation,
                                    width: 80,
                                    height: 60,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.blue.shade300),
                                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                                          ),
                                          child: const Text('Store Hub', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E40AF),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                          ),
                                          child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 16),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 2. Premium Delivery Partner Scooter Marker (Clean Zomato/Uber styling)
                                  Marker(
                                    point: riderLocation,
                                    width: 100,
                                    height: 75,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Floating Driver Status Pill
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0F172A),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF10B981)),
                                              SizedBox(width: 5),
                                              Text(
                                                'Suresh • 12m',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        // Elevated Scooter Core Badge with Direction Heading
                                        Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFFE23744), Color(0xFFDC2626)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 2.5),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFFE23744).withValues(alpha: 0.35),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                  const BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 22),
                                              ),
                                            ),

                                            // Directional Heading Indicator
                                            Positioned(
                                              top: -2,
                                              right: -2,
                                              child: Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: const [
                                                    BoxShadow(color: Colors.black26, blurRadius: 3),
                                                  ],
                                                  border: Border.all(color: const Color(0xFFE23744), width: 1.2),
                                                ),
                                                child: const Icon(
                                                  Icons.navigation_rounded,
                                                  size: 10,
                                                  color: Color(0xFFE23744),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 3. Customer Destination Pin
                                  Marker(
                                    point: customerLocation,
                                    width: 80,
                                    height: 60,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.green.shade400),
                                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                                          ),
                                          child: const Text('Your Doorstep', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF059669),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                          ),
                                          child: const Icon(Icons.home_rounded, color: Colors.white, size: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Top-Left Floating Live Status Pill (Frosted Glass)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'LIVE DRIVER GPS',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.3),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(width: 1, height: 12, color: Colors.grey.shade300),
                                  const SizedBox(width: 6),
                                  const Text(
                                    '26 km/h',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Top-Right Recenter Button
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                shape: BoxShape.circle,
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.my_location_rounded, size: 18, color: Color(0xFF1E293B)),
                                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                                padding: EdgeInsets.zero,
                                tooltip: 'Recenter on Courier',
                                onPressed: () {
                                  _mapController.move(riderLocation, 15.3);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── PROXIMITY GEOFENCE ARRIVAL NOTIFICATION (Within 100 meters) ──
                  if (order.status == OrderStatus.pickedUp)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.indigo.shade50],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Proximity Alert • Rider within 100m', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A))),
                                    SizedBox(width: 6),
                                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text('Suresh Solanki is arriving at your gate. Please keep cash / UPI ready.', style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── SWIGGY / ZOMATO DELIVERY PARTNER PROFILE & ACTION CARD ───
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Delivery Partner Label & Verification
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ASSIGNED DELIVERY PARTNER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 12, color: Color(0xFF16A34A)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified Partner',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Driver Profile Main Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: AppColors.onyx.withValues(alpha: 0.08),
                                  child: const Icon(Icons.person_rounded, color: AppColors.onyx, size: 30),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.two_wheeler_rounded, size: 14, color: AppColors.accent),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. Driver Name
                                  const Text(
                                    'Suresh Solanki',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF171717),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),

                                  // Vehicle
                                  const Text(
                                    'Honda Activa 6G • GJ-01-AB-1234',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // 2. Rating & 3. Since when is he driving
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      // Rating Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF15803D),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '4.9',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                            SizedBox(width: 3),
                                            Icon(Icons.star_rounded, size: 12, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text(
                                              '(1,240 ratings)',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Driving Experience Badge (Since when is he driving)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2F6),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFCBD5E1)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.history_toggle_off_rounded, size: 12, color: Color(0xFF475569)),
                                            SizedBox(width: 4),
                                            Text(
                                              'Driving since 2022 (3+ yrs)',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF334155),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Experience & Trust Highlights Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.military_tech_rounded, size: 15, color: Color(0xFFD97706)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Top Delivery Partner • 1,240+ deliveries completed with 99.4% on-time record',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Action Buttons: Chat & Call
                        Row(
                          children: [
                            // Direct Chat Button
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                label: const Text('Chat with Suresh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () => DriverChatDialog.show(
                                  context,
                                  orderId: order.id,
                                  driverName: 'Suresh Solanki',
                                  driverPhone: '+91 98980 12345',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Direct Call Button
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.phone_rounded, size: 16),
                                label: const Text('Call Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () async {
                                  final uri = Uri.parse('tel:+919898012345');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Rider Phone: +91 98980 12345')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],

                // Order Status Summary Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}', style: AppTextStyles.titleMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCancelled
                                  ? AppColors.error.withValues(alpha: 0.15)
                                  : AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.status.name.toUpperCase(),
                              style: TextStyle(
                                color: isCancelled ? AppColors.error : AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Text(
                        'Total: ₹${(order.pricing.grandTotal / 100).toStringAsFixed(0)} • ${_formatPaymentMethod(order.paymentMethod)}',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Packaging (1%): ₹${(order.pricing.packagingCharge / 100).toStringAsFixed(0)} • COD Fee: ₹${(order.pricing.codCharge / 100).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Destination: ${order.deliveryAddressSnapshot['line1'] ?? ''}, ${order.deliveryAddressSnapshot['city'] ?? ''}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      // Handover OTP & Tax Invoice Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              icon: const Icon(Icons.receipt_long_rounded, size: 16),
                              label: const Text('Tax Invoice & Bill 🧾', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              onPressed: () => _showTaxInvoiceSheet(context, order),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.pin_rounded, size: 14, color: Colors.orange),
                                SizedBox(width: 4),
                                Text('Pickup OTP: 4821', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF7A4F01))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (isCancelled)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Cancelled',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reason: ${order.cancellationReason ?? 'Cancelled upon customer request'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text('Live Delivery Timeline', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),

                  // Status timeline
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: statusSteps.length,
                    itemBuilder: (context, index) {
                      final step = statusSteps[index];
                      final isPassed = index <= currentStepIndex;
                      final isCurrent = index == currentStepIndex;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isPassed ? AppColors.accent : AppColors.divider,
                                ),
                                child: Icon(
                                  isPassed ? Icons.check : Icons.circle,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              if (index < statusSteps.length - 1)
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: isPassed ? AppColors.accent : AppColors.divider,
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['title'] as String,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: isPassed ? AppColors.textPrimary : AppColors.textHint,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  step['subtitle'] as String,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isPassed ? AppColors.textSecondary : AppColors.textHint,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // Size Exchange Button (if delivered)
                if (order.status == OrderStatus.delivered && !isExchange)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Size didn\'t fit well?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('Request a size exchange within 48 hours for immediate replacement.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Request Size Exchange',
                          variant: AppButtonVariant.primary,
                          onPressed: () => context.push('/orders/${order.id}/exchange'),
                        ),
                      ],
                    ),
                  ),

                // Cancellation Option (if pending)
                if (order.status == OrderStatus.pending)
                  AppButton(
                    label: 'Cancel Order',
                    variant: AppButtonVariant.outline,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Cancel Order?'),
                          content: const Text('Are you sure you want to cancel this order?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel')),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final repo = ref.read(orderRepositoryProvider);
                        await repo.cancelOrder(orderId: order.id, reason: 'Customer cancelled from app');
                        if (context.mounted) {
                          AppSnackbar.show(context, message: 'Order cancelled', type: SnackbarType.info);
                        }
                      }
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _formatPaymentMethod(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cod => 'Cash on Delivery',
      PaymentMethod.payOnDelivery => 'Pay on Delivery (QR)',
      PaymentMethod.payOnline => 'Online Paid',
      PaymentMethod.directPay => 'Direct Store Pay',
    };
  }

  int _getStepIndex(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => 0,
      OrderStatus.confirmed => 1,
      OrderStatus.preparing => 2,
      OrderStatus.readyForPickup => 3,
      OrderStatus.pickedUp => 4,
      OrderStatus.delivered => 5,
      _ => 0,
    };
  }

  void _showTaxInvoiceSheet(BuildContext context, OrderEntity order) {
    final invoiceData = InvoiceGeneratorService.fromOrder(order);

    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TAX INVOICE & BILL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6C5CE7))),
                        Text('SwiftDrop Hyperlocal Fashion Pvt. Ltd.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bill Metadata
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Invoice No: ${invoiceData.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text('Order ID: ${invoiceData.orderId}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('Marketplace GSTIN: ${invoiceData.marketplaceGstin}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('Date: ${invoiceData.invoiceDate.toLocal().toString().substring(0, 16)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Vendor Details
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BOUTIQUE VENDOR (SELLER)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7))),
                              const SizedBox(height: 2),
                              Text(invoiceData.vendorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(invoiceData.vendorAddress, style: const TextStyle(fontSize: 11)),
                              Text('Vendor GSTIN: ${invoiceData.vendorGstin}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Customer Details
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BILL TO (CUSTOMER)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                              const SizedBox(height: 2),
                              Text(invoiceData.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(invoiceData.customerAddress, style: const TextStyle(fontSize: 11)),
                              Text('Phone: ${invoiceData.customerPhone}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Items Table
                        const Text('Itemized Particulars', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        ...invoiceData.items.map((it) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text('Size: ${it.size} • 5% GST Included • 48h Size Exchange', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Text('Qty: ${it.quantity} • ₹${(it.totalPaise / 100).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        )),
                        const Divider(height: 16),
                        // Financial Calculation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Items Subtotal:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('₹${(invoiceData.subtotalPaise / 100).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Eco-Packaging & Handling (1%):', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('₹${(invoiceData.packagingPaise / 100).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Hyperlocal Courier Delivery:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('₹${(invoiceData.deliveryFeePaise / 100).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        if (invoiceData.codFeePaise > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('COD Surcharge:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text('₹${(invoiceData.codFeePaise / 100).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total Paid:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('₹${(invoiceData.grandTotalPaise / 100).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6C5CE7))),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'DPDP Act 2023 & Consumer Protection Compliant. Designated Grievance Officer: Meet Ratwani (grievance@marsfashion.in, Kubernagar, Ahmedabad).',
                            style: TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Actions: Email Invoice & Print
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: isSending
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.email_outlined, size: 18),
                        label: Text(isSending ? 'Sending...' : 'Email Bill to Customer 📧', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: isSending
                            ? null
                            : () async {
                                setModalState(() => isSending = true);
                                final success = await InvoiceGeneratorService.emailInvoiceToCustomer(
                                  invoice: invoiceData,
                                  recipientEmail: 'developermeetratwani@gmail.com',
                                );
                                setModalState(() => isSending = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: success ? AppColors.success : AppColors.error,
                                      content: Text(success ? '✅ Tax Invoice sent to developermeetratwani@gmail.com!' : 'Email service offline'),
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
