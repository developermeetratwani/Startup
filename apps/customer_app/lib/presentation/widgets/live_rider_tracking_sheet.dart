import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:core/core.dart';
import '../providers/location_provider.dart';

/// Nearby roaming rider model for Zomato-style live radar
class RoamingRider {
  final String id;
  final String name;
  final String vehicleModel;
  final String vehicleRegNo;
  final double rating;
  final LatLng position;
  final String cluster;
  final bool isOnline;

  const RoamingRider({
    required this.id,
    required this.name,
    required this.vehicleModel,
    required this.vehicleRegNo,
    required this.rating,
    required this.position,
    required this.cluster,
    this.isOnline = true,
  });
}

class LiveRiderTrackingSheet extends ConsumerStatefulWidget {
  const LiveRiderTrackingSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LiveRiderTrackingSheet(),
    );
  }

  @override
  ConsumerState<LiveRiderTrackingSheet> createState() => _LiveRiderTrackingSheetState();
}

class _LiveRiderTrackingSheetState extends ConsumerState<LiveRiderTrackingSheet> {
  late final MapController _mapController;
  RoamingRider? _selectedRider;

  // Ahmedabad neighborhood coordinates
  static const Map<String, LatLng> _clusterCenters = {
    'Kubernagar': LatLng(23.0768, 72.6346),
    'Sindhu Bhavan Road': LatLng(23.0402, 72.5028),
    'Bodakdev & SG Highway': LatLng(23.0375, 72.5120),
    'Prahlad Nagar': LatLng(23.0125, 72.5108),
    'Gandhinagar': LatLng(23.2156, 72.6369),
  };

  late String _activeArea;
  late LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _activeArea = 'Kubernagar';
    _currentLocation = _clusterCenters['Kubernagar']!;
  }

  List<RoamingRider> _generateNearbyRiders(LatLng center, String areaName) {
    // Generate realistic nearby roaming riders around the current area
    return [
      RoamingRider(
        id: 'r-1',
        name: 'Suresh Solanki',
        vehicleModel: 'Honda Activa 6G',
        vehicleRegNo: 'GJ-01-AB-1234',
        rating: 4.9,
        position: LatLng(center.latitude + 0.0042, center.longitude + 0.0035),
        cluster: areaName,
      ),
      RoamingRider(
        id: 'r-2',
        name: 'Jignesh Patel',
        vehicleModel: 'Hero Splendor Plus',
        vehicleRegNo: 'GJ-01-CD-5678',
        rating: 4.8,
        position: LatLng(center.latitude - 0.0038, center.longitude + 0.0045),
        cluster: areaName,
      ),
      RoamingRider(
        id: 'r-3',
        name: 'Amit Vaghela',
        vehicleModel: 'TVS Jupiter 125',
        vehicleRegNo: 'GJ-01-EF-9012',
        rating: 4.9,
        position: LatLng(center.latitude + 0.0055, center.longitude - 0.0040),
        cluster: areaName,
      ),
      RoamingRider(
        id: 'r-4',
        name: 'Rahul Prajapati',
        vehicleModel: 'Bajaj Pulsar 150',
        vehicleRegNo: 'GJ-01-GH-3456',
        rating: 5.0,
        position: LatLng(center.latitude - 0.0060, center.longitude - 0.0050),
        cluster: areaName,
      ),
    ];
  }

  double _calculateDistanceKm(LatLng p1, LatLng p2) {
    const double p = 0.017453292519943295;
    final a = 0.5 -
        cos((p2.latitude - p1.latitude) * p) / 2 +
        cos(p1.latitude * p) * cos(p2.latitude * p) * (1 - cos((p2.longitude - p1.longitude) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  int _calculateEtaMinutes(double distKm) {
    return max(4, (distKm * 3.5).round());
  }

  void _onAreaChanged(String area) {
    final center = _clusterCenters[area] ?? _clusterCenters['Kubernagar']!;
    setState(() {
      _activeArea = area;
      _currentLocation = center;
      _selectedRider = null;
    });
    _mapController.move(center, 14.5);
  }

  @override
  Widget build(BuildContext context) {
    final riders = _generateNearbyRiders(_currentLocation, _activeArea);
    final displayedRider = _selectedRider ?? riders.first;
    final distanceKm = _calculateDistanceKm(_currentLocation, displayedRider.position);
    final etaMinutes = _calculateEtaMinutes(distanceKm);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Live Delivery Radar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(radius: 3, backgroundColor: Colors.green),
                              SizedBox(width: 4),
                              Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('4 Active Delivery Partners in $_activeArea', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Area Switcher Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _clusterCenters.keys.map((area) {
                final isSelected = area == _activeArea;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(area, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(color: isSelected ? AppColors.primary : Colors.black87),
                    side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                    onSelected: (_) => _onAreaChanged(area),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Interactive Map (100% Free OpenStreetMap)
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 14.5,
                  ),
                  children: [
                    // Free OpenStreetMap Raster Tiles
                    TileLayer(
                      urlTemplate: 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                      fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'in.xyzstartup.app',
                    ),

                    // Markers Layer (User pin + Roaming riders)
                    MarkerLayer(
                      markers: [
                        // Customer Location Marker
                        Marker(
                          point: _currentLocation,
                          width: 60,
                          height: 60,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 18),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                ),
                                child: const Text('You', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                        // Roaming Rider Markers
                        ...riders.map((r) {
                          final isSelected = displayedRider.id == r.id;
                          return Marker(
                            point: r.position,
                            width: 70,
                            height: 70,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedRider = r);
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.accent : AppColors.purple,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected ? AppColors.accent.withValues(alpha: 0.5) : AppColors.shadow,
                                          blurRadius: isSelected ? 10 : 4,
                                          spreadRadius: isSelected ? 2 : 0,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.accent : Colors.black87,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${_calculateEtaMinutes(_calculateDistanceKm(_currentLocation, r.position))}m',
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                // Free Map Badge
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Text('© OpenStreetMap • Free Tier', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ),
                ),
              ],
            ),
          ),

          // Zomato-Style Bottom Selected Rider Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.purple.withValues(alpha: 0.15),
                      child: const Icon(Icons.person_rounded, color: AppColors.purple, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(displayedRider.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, size: 11, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text('${displayedRider.rating}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${displayedRider.vehicleModel} • ${displayedRider.vehicleRegNo}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$etaMinutes mins', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.success)),
                        Text('${distanceKm.toStringAsFixed(1)} km away', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary,
                          content: Text('⚡ Order from local stores in $_activeArea for instant dispatch by ${displayedRider.name}!'),
                        ),
                      );
                    },
                    child: Text('Shop Stores in $_activeArea ($etaMinutes Min Delivery)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
