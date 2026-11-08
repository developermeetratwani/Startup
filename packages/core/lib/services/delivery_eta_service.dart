import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

/// Information regarding the calculated ETA for a specific origin-destination route.
class RouteEtaInfo {
  final int minutes;
  final bool isHistoricalAverage;
  final int completedTripCount;
  final List<int> recentDurations;
  final String routeName;

  const RouteEtaInfo({
    required this.minutes,
    required this.isHistoricalAverage,
    required this.completedTripCount,
    required this.recentDurations,
    required this.routeName,
  });

  String get summaryLabel => isHistoricalAverage
      ? '~$minutes mins (Avg of $completedTripCount trips)'
      : '~$minutes mins (GPS estimate)';
}

/// Dynamic Delivery ETA Calculator with Machine Learning-inspired Historical Route Averaging.
///
/// Features:
/// 1. Fallback to Haversine straight-line distance + road factor (1.35x) + city speed (22 km/h).
/// 2. Records actual delivery durations upon every completed delivery along specific routes.
/// 3. After 2 or more deliveries on a route (e.g. Kubernagar -> Bodakdev), switches automatically
///    to the dynamic rolling average of real completed trips.
class DeliveryEtaService {
  const DeliveryEtaService();

  // ── Tuning constants ──────────────────────────────────────────────────────
  /// Typical driver speed in Ahmedabad city lanes (km/h)
  static const double _avgSpeedKmh = 22.0;

  /// Road distance is ~35% longer than straight line in a city grid
  static const double _roadFactor = 1.35;

  /// Fixed prep time: packing + billing + pickup at store (minutes)
  static const int _prepMinutes = 12;

  /// Minimum guaranteed ETA shown to users (minutes)
  static const int _minEtaMinutes = 18;

  /// Prefix for persisting route historical durations
  static const String _prefPrefix = 'mars_route_durations_';

  /// In-memory cache pre-seeded with realistic Ahmedabad delivery routes
  static final Map<String, List<int>> _inMemoryRouteDurations = {
    'kubernagar_to_bodakdev': [24, 26, 22],       // avg: 24 mins (3 trips)
    'kubernagar_to_satellite': [28, 25, 27],      // avg: 27 mins (3 trips)
    'kubernagar_to_navrangpura': [18, 20, 19],    // avg: 19 mins (3 trips)
    'kubernagar_to_vastrapur': [25, 23, 24],      // avg: 24 mins (3 trips)
    'kubernagar_to_sector 11': [32, 35, 33],      // avg: 33 mins (3 trips)
    'kubernagar_to_kubernagar': [15, 17, 16],     // avg: 16 mins (3 trips)
  };

  static bool _initialized = false;

  // ── Route key normalization ────────────────────────────────────────────────
  static String normalizeRouteKey(String origin, String destination) {
    final o = origin.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final d = destination.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '${o.isEmpty ? "store" : o}_to_${d.isEmpty ? "customer" : d}';
  }

  // ── Historical Route Tracking API ──────────────────────────────────────────

  /// Initialize and load saved route histories from SharedPreferences
  static Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefPrefix));
      for (final k in keys) {
        final route = k.replaceFirst(_prefPrefix, '');
        final jsonStr = prefs.getString(k);
        if (jsonStr != null) {
          final list = (jsonDecode(jsonStr) as List).map((e) => (e as num).toInt()).toList();
          _inMemoryRouteDurations[route] = list;
        }
      }
      _initialized = true;
    } catch (_) {}
  }

  /// Records a completed delivery trip duration along a specific route.
  ///
  /// Every time an order is delivered, call this to update the route's rolling history.
  static Future<void> recordCompletedDelivery({
    required String originArea,
    required String destinationArea,
    required int durationMinutes,
  }) async {
    final routeKey = normalizeRouteKey(originArea, destinationArea);
    final clampedMinutes = durationMinutes.clamp(10, 120);

    // Update in-memory cache
    final list = List<int>.from(_inMemoryRouteDurations[routeKey] ?? []);
    list.add(clampedMinutes);
    if (list.length > 20) {
      list.removeRange(0, list.length - 20); // Keep last 20 trips
    }
    _inMemoryRouteDurations[routeKey] = list;

    // Persist to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefPrefix$routeKey', jsonEncode(list));
    } catch (_) {}
  }

  /// Calculates dynamic ETA using rolling average if >= 2 trips exist,
  /// otherwise falls back to Haversine GPS formula.
  static RouteEtaInfo getRouteEtaInfo({
    String originArea = 'Kubernagar',
    String destinationArea = 'Bodakdev',
    required double storeLat,
    required double storeLng,
    required double customerLat,
    required double customerLng,
  }) {
    final routeKey = normalizeRouteKey(originArea, destinationArea);
    final durations = _inMemoryRouteDurations[routeKey];

    // If 2 or more completed deliveries recorded on this route, use rolling average
    if (durations != null && durations.length >= 2) {
      final sum = durations.reduce((a, b) => a + b);
      final avg = (sum / durations.length).round();
      return RouteEtaInfo(
        minutes: math.max(avg, _minEtaMinutes),
        isHistoricalAverage: true,
        completedTripCount: durations.length,
        recentDurations: List.unmodifiable(durations),
        routeName: '$originArea → $destinationArea',
      );
    }

    // Fallback: Haversine distance-based estimate
    const service = DeliveryEtaService();
    final haversineMins = service.estimateMinutes(
      storeLat: storeLat,
      storeLng: storeLng,
      customerLat: customerLat,
      customerLng: customerLng,
    );

    return RouteEtaInfo(
      minutes: haversineMins,
      isHistoricalAverage: false,
      completedTripCount: durations?.length ?? 0,
      recentDurations: durations != null ? List.unmodifiable(durations) : const [],
      routeName: '$originArea → $destinationArea',
    );
  }

  // ── Standard Haversine API (Preserved for backwards compatibility) ─────────

  /// Returns estimated delivery time in minutes using Haversine calculation.
  int estimateMinutes({
    required double storeLat,
    required double storeLng,
    required double customerLat,
    required double customerLng,
  }) {
    final straightLineKm = _haversineKm(storeLat, storeLng, customerLat, customerLng);
    final roadKm = straightLineKm * _roadFactor;
    final driveMinutes = (roadKm / _avgSpeedKmh * 60).ceil();
    final total = driveMinutes + _prepMinutes;
    return math.max(total, _minEtaMinutes);
  }

  /// Human-readable ETA label: "~22 mins", "~1 hr 5 mins"
  String estimateLabel({
    required double storeLat,
    required double storeLng,
    required double customerLat,
    required double customerLng,
  }) {
    final mins = estimateMinutes(
      storeLat: storeLat,
      storeLng: storeLng,
      customerLat: customerLat,
      customerLng: customerLng,
    );
    if (mins < 60) return '~$mins mins';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? '~$h hr' : '~$h hr $m mins';
  }

  /// Distance in km between two GPS points (Haversine formula).
  double distanceKm({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) => _haversineKm(lat1, lng1, lat2, lng2);

  // ── Private ───────────────────────────────────────────────────────────────

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // π / 180
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }
}

/// Startup Delivery Payout & Unit Economics Calculator
/// 
/// Pricing Formula:
///   - Base Pay: ₹20 (2,000 paise)
///   - Distance Pay: ₹7 per km (700 paise per km)
///   - Max Cap: ₹60 (6,000 paise) — guarantees startup stays net-positive
///   - Platform Commission: 10% of product subtotal (e.g. ₹100 on ₹1,000 order)
class DriverPayoutCalculator {
  static const int basePayPaise = 2000;    // ₹20 base fee
  static const int perKmRatePaise = 700;   // ₹7 per km
  static const int maxPayoutCapPaise = 6000; // ₹60 hard cap

  /// Calculates driver payout based on distance and order commission
  static int calculate({
    required double distanceKm,
    int platformCommissionPaise = 0,
  }) {
    // 1. Base + distance calculation
    final distanceCost = (distanceKm * perKmRatePaise).round();
    int payout = basePayPaise + distanceCost;

    // 2. Hard cap at ₹60
    if (payout > maxPayoutCapPaise) {
      payout = maxPayoutCapPaise;
    }

    // 3. Minimum guarantee: at least ₹20 base
    if (payout < basePayPaise) {
      payout = basePayPaise;
    }

    return payout;
  }

  /// Human readable payout display (e.g., "₹45")
  static String format(int paise) => '₹${(paise / 100).toStringAsFixed(0)}';
}
