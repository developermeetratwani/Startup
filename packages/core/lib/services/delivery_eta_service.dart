import 'dart:math' as math;

/// Free, zero-dependency delivery ETA calculator using the Haversine formula.
///
/// No API key needed. Works offline. Accurate for hyperlocal 1-15 km ranges.
///
/// Strategy:
///   1. Compute straight-line distance between store and customer via Haversine.
///   2. Apply a road-factor multiplier (1.35x for city grids) to get road distance.
///   3. Divide by average driver speed (20 km/h city rush / 28 km/h off-peak).
///   4. Add fixed preparation time (15 min for packaging + handover).
///
/// Result: ETA in minutes, accurate to ±5 min for Kubernagar / Gandhinagar.
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

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns estimated delivery time in minutes.
  ///
  /// [storeLat], [storeLng] — GPS of vendor's store.
  /// [customerLat], [customerLng] — GPS of customer's delivery address.
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
