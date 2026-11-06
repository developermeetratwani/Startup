import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../data/repositories/driver_delivery_repository.dart';
import '../../data/repositories/driver_earnings_repository.dart';

final driverDeliveryRepoProvider = Provider<DriverDeliveryRepository>((ref) {
  return DriverDeliveryRepository();
});

final driverEarningsRepoProvider = Provider<DriverEarningsRepository>((ref) {
  return DriverEarningsRepository();
});

// Duty state (Online / Offline)
final driverDutyProvider = StateProvider<bool>((ref) => true);

// Deliveries Stream
final driverDeliveriesProvider = StreamProvider<List<DeliveryEntity>>((ref) {
  final repo = ref.watch(driverDeliveryRepoProvider);
  String driverId = 'driver-1';
  try {
    driverId = FirebaseAuth.instance.currentUser?.uid ?? driverId;
  } catch (_) {}

  return repo.watchDriverDeliveries(driverId).map((list) {
    if (list.isEmpty) {
      return [
        DeliveryEntity(
          id: 'del-101',
          orderId: 'ord-101',
          driverId: driverId,
          vendorId: 'vendor-1',
          customerId: 'cust-1',
          pickupLat: 23.0768,
          pickupLng: 72.6346,
          dropLat: 23.0795,
          dropLng: 72.6380,
          status: DeliveryStatus.assigned,
          deliveryFee: 4500, // ₹45
          assignedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];
    }
    return list;
  });
});

// Active Delivery (current ongoing trip)
final activeDeliveryProvider = Provider<DeliveryEntity?>((ref) {
  final deliveriesAsync = ref.watch(driverDeliveriesProvider);
  final list = deliveriesAsync.valueOrNull ?? [];
  try {
    return list.firstWhere(
      (d) => d.status != DeliveryStatus.delivered,
    );
  } catch (_) {
    return null;
  }
});

// Driver Earnings Provider
final driverEarningsProvider = StreamProvider<DriverEarningsSummary>((ref) {
  final repo = ref.watch(driverEarningsRepoProvider);
  String driverId = 'driver-1';
  try {
    driverId = FirebaseAuth.instance.currentUser?.uid ?? driverId;
  } catch (_) {}

  return repo.watchEarnings(driverId);
});
