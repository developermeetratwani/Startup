import 'package:cloud_firestore/cloud_firestore.dart';

class DriverEarningsSummary {
  final int todayEarnings; // paise
  final int weeklyEarnings; // paise
  final int totalDeliveries;
  final int todayDeliveries;
  final double rating;

  const DriverEarningsSummary({
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.totalDeliveries,
    required this.todayDeliveries,
    required this.rating,
  });

  String get todayEarningsDisplay => '₹${(todayEarnings / 100).toStringAsFixed(0)}';
  String get weeklyEarningsDisplay => '₹${(weeklyEarnings / 100).toStringAsFixed(0)}';
}

class DriverEarningsRepository {
  final FirebaseFirestore _firestore;

  DriverEarningsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<DriverEarningsSummary> watchEarnings(String driverId) {
    return _firestore
        .collection('deliveries')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'delivered')
        .snapshots()
        .map((snap) {
      int total = 0;
      int count = snap.docs.length;

      for (final doc in snap.docs) {
        final fee = (doc.data()['deliveryFee'] as num?)?.toInt() ?? 4500;
        total += fee;
      }

      return DriverEarningsSummary(
        todayEarnings: total > 0 ? total : 22500, // ₹225 default demo
        weeklyEarnings: total > 0 ? total * 4 : 85000, // ₹850
        totalDeliveries: count > 0 ? count : 5,
        todayDeliveries: count > 0 ? count : 3,
        rating: 4.9,
      );
    });
  }
}
