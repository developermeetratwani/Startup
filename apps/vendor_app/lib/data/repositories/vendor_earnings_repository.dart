import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';

class VendorEarningsSummary {
  final int totalSales; // paise
  final int platformCommission; // paise
  final int netEarnings; // paise
  final int completedOrders;
  final int storeCoins;
  final String referralCode;

  const VendorEarningsSummary({
    required this.totalSales,
    required this.platformCommission,
    required this.netEarnings,
    required this.completedOrders,
    required this.storeCoins,
    required this.referralCode,
  });

  String get totalSalesDisplay => '₹${(totalSales / 100).toStringAsFixed(0)}';
  String get commissionDisplay => '₹${(platformCommission / 100).toStringAsFixed(0)}';
  String get netEarningsDisplay => '₹${(netEarnings / 100).toStringAsFixed(0)}';
}

class VendorEarningsRepository {
  final FirebaseFirestore _firestore;

  VendorEarningsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<VendorEarningsSummary> watchEarnings(String storeId, String vendorId) {
    return _firestore
        .collection('orders')
        .where('storeId', isEqualTo: storeId)
        .where('status', isEqualTo: 'DELIVERED')
        .snapshots()
        .asyncMap((ordersSnap) async {
      int totalSales = 0;
      int platformCommission = 0;
      int netEarnings = 0;

      for (final doc in ordersSnap.docs) {
        final data = doc.data();
        final rawPricing = data['pricing'] as Map<String, dynamic>? ?? {};
        final subtotal = (rawPricing['subtotal'] as num?)?.toInt() ?? 0;
        final commission = (rawPricing['platformCommission'] as num?)?.toInt() ?? (subtotal * 10 ~/ 100);
        final payout = (rawPricing['retailerPayout'] as num?)?.toInt() ?? (subtotal - commission);

        totalSales += subtotal;
        platformCommission += commission;
        netEarnings += payout;
      }

      // Fetch store coins & referral code
      int coins = 250; // Welcome starter coins
      String referralCode = 'STORE-${storeId.substring(0, 6).toUpperCase()}';

      try {
        final vendorDoc = await _firestore.collection('users').doc(vendorId).get();
        if (vendorDoc.exists) {
          final data = vendorDoc.data()!;
          coins = (data['storeCoins'] as num?)?.toInt() ?? 250;
          referralCode = data['referralCode'] ?? referralCode;
        }
      } catch (e) {
        AppLogger.error('watchEarnings.vendorDoc', e.toString());
      }

      return VendorEarningsSummary(
        totalSales: totalSales,
        platformCommission: platformCommission,
        netEarnings: netEarnings,
        completedOrders: ordersSnap.docs.length,
        storeCoins: coins,
        referralCode: referralCode,
      );
    });
  }
}
