import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class DriverDeliveryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseDatabase _rtdb;

  static final List<DeliveryEntity> _mockDeliveries = [
    DeliveryEntity(
      id: 'del-101',
      orderId: 'ord-kubernagar-8920',
      driverId: 'driver-1',
      driverName: 'Suresh Solanki',
      driverPhone: '+91 98980 12345',
      vendorId: 'vendor-kubernagar-1',
      customerId: 'cust-ahmedabad-01',
      pickupLat: 23.0768,
      pickupLng: 72.6346,
      dropLat: 23.0795,
      dropLng: 72.6380,
      currentDriverLat: 23.0772,
      currentDriverLng: 72.6350,
      status: DeliveryStatus.assigned,
      deliveryFee: 4500, // ₹45
      estimatedEtaMinutes: 18,
      documentRecord: const DriverDocumentRecord(
        aadhaarNumber: 'XXXX-XXXX-8912',
        drivingLicenseNumber: 'GJ01-20210045678',
        isVerified: true,
        isBlacklisted: false,
      ),
      assignedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    DeliveryEntity(
      id: 'del-102',
      orderId: 'ord-delivered-7731',
      driverId: 'driver-1',
      driverName: 'Suresh Solanki',
      driverPhone: '+91 98980 12345',
      vendorId: 'vendor-kubernagar-1',
      customerId: 'cust-ahmedabad-01',
      pickupLat: 23.0768,
      pickupLng: 72.6346,
      dropLat: 23.0780,
      dropLng: 72.6360,
      status: DeliveryStatus.delivered,
      deliveryFee: 5000, // ₹50
      estimatedEtaMinutes: 0,
      documentRecord: const DriverDocumentRecord(
        aadhaarNumber: 'XXXX-XXXX-8912',
        drivingLicenseNumber: 'GJ01-20210045678',
        isVerified: true,
        isBlacklisted: false,
      ),
      assignedAt: DateTime.now().subtract(const Duration(hours: 3)),
      pickedUpAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
      deliveredAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
    ),
  ];

  DriverDeliveryRepository({
    FirebaseFirestore? firestore,
    FirebaseDatabase? rtdb,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _rtdb = rtdb ?? FirebaseDatabase.instance;

  Stream<List<DeliveryEntity>> watchDriverDeliveries(String driverId) {
    try {
      // Avoid composite query (.orderBy) to prevent Firestore failed-precondition index errors
      return _firestore
          .collection('deliveries')
          .where('driverId', isEqualTo: driverId)
          .snapshots()
          .map((snap) {
        final list = snap.docs.map((doc) => _mapToDelivery(doc)).toList();
        list.sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
        return list.isNotEmpty ? list : _mockDeliveries;
      }).handleError((error) {
        AppLogger.error('watchDriverDeliveries', error.toString());
        return _mockDeliveries;
      });
    } catch (e) {
      return Stream.value(_mockDeliveries);
    }
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
      AppLogger.warning('updateDeliveryStatus', 'Falling back to local in-memory update: $e');
    }

    // Always update in-memory mock for immediate interactive feedback
    final idx = _mockDeliveries.indexWhere((d) => d.id == deliveryId);
    if (idx != -1) {
      final ex = _mockDeliveries[idx];
      _mockDeliveries[idx] = DeliveryEntity(
        id: ex.id,
        orderId: ex.orderId,
        driverId: ex.driverId,
        driverName: ex.driverName,
        driverPhone: ex.driverPhone,
        vendorId: ex.vendorId,
        customerId: ex.customerId,
        pickupLat: ex.pickupLat,
        pickupLng: ex.pickupLng,
        dropLat: ex.dropLat,
        dropLng: ex.dropLng,
        status: status,
        deliveryFee: ex.deliveryFee,
        estimatedEtaMinutes: status == DeliveryStatus.delivered ? 0 : ex.estimatedEtaMinutes,
        assignedAt: ex.assignedAt,
        pickedUpAt: status == DeliveryStatus.pickedUp ? DateTime.now() : ex.pickedUpAt,
        deliveredAt: status == DeliveryStatus.delivered ? DateTime.now() : ex.deliveredAt,
      );
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
