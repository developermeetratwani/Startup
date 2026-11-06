import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class DriverDeliveryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseDatabase _rtdb;

  DriverDeliveryRepository({
    FirebaseFirestore? firestore,
    FirebaseDatabase? rtdb,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _rtdb = rtdb ?? FirebaseDatabase.instance;

  Stream<List<DeliveryEntity>> watchDriverDeliveries(String driverId) {
    return _firestore
        .collection('deliveries')
        .where('driverId', isEqualTo: driverId)
        .orderBy('assignedAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => _mapToDelivery(doc)).toList();
    });
  }

  Future<void> updateDeliveryStatus(String deliveryId, DeliveryStatus status, String orderId) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == DeliveryStatus.pickedUp) {
        updates['pickedUpAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('orders').doc(orderId).update({'status': 'picked_up'});
      } else if (status == DeliveryStatus.delivered) {
        updates['deliveredAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('orders').doc(orderId).update({
          'status': 'delivered',
          'deliveredAt': FieldValue.serverTimestamp(),
          'paymentStatus': 'paid',
        });
      }

      await _firestore.collection('deliveries').doc(deliveryId).update(updates);
    } catch (e) {
      AppLogger.error('updateDeliveryStatus', e.toString());
    }
  }

  Future<void> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    required bool isOnline,
  }) async {
    try {
      await _rtdb.ref('driverLocations/$driverId').set({
        'latitude': latitude,
        'longitude': longitude,
        'isOnline': isOnline,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      AppLogger.error('updateDriverLocation', e.toString());
    }
  }

  DeliveryEntity _mapToDelivery(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final statusStr = d['status'] as String? ?? 'assigned';
    final status = DeliveryStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => DeliveryStatus.assigned,
    );

    return DeliveryEntity(
      id: doc.id,
      orderId: d['orderId'] ?? '',
      driverId: d['driverId'] ?? '',
      vendorId: d['vendorId'] ?? '',
      customerId: d['customerId'] ?? '',
      pickupLat: (d['pickupLat'] as num?)?.toDouble() ?? 23.0768,
      pickupLng: (d['pickupLng'] as num?)?.toDouble() ?? 72.6346,
      dropLat: (d['dropLat'] as num?)?.toDouble() ?? 23.0780,
      dropLng: (d['dropLng'] as num?)?.toDouble() ?? 72.6360,
      status: status,
      deliveryFee: (d['deliveryFee'] as num?)?.toInt() ?? 4500, // ₹45
      assignedAt: (d['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pickedUpAt: (d['pickedUpAt'] as Timestamp?)?.toDate(),
      deliveredAt: (d['deliveredAt'] as Timestamp?)?.toDate(),
    );
  }
}
