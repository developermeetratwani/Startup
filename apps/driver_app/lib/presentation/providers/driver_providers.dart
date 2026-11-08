import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';
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

  return repo.watchDriverDeliveries(driverId);
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

// Driver COD & Remittance Reconciliation Provider
final driverCodSummaryProvider = Provider<DriverCodSummary>((ref) {
  // Listen to order updates to recalculate COD metrics live
  ref.watch(driverDeliveriesProvider);
  return OrderSyncService.getDriverCodSummary('driver-1', 'Suresh Solanki');
});

// Driver Remittance History Stream
final driverRemittancesProvider = StreamProvider<List<DriverRemittanceRecord>>((ref) {
  return OrderSyncService.remittancesStream;
});

// Driver Hub Cash Handover OTP Stream
final driverHandoversProvider = StreamProvider<List<DriverHubHandoverRequest>>((ref) {
  return OrderSyncService.handoversStream;
});

// Driver Profile & Fleet Security state
class DriverProfileState {
  final String name;
  final String phone;
  final String vehicleModel;
  final String vehicleRegNo;
  final String vehicleType;
  final String aadhaarNumber;
  final String electricityBillProvider;
  final String cluster;
  final bool isVerified;
  final bool isBlacklisted;

  const DriverProfileState({
    this.name = 'Suresh Solanki',
    this.phone = '+91 98980 12345',
    this.vehicleModel = 'Honda Activa 6G',
    this.vehicleRegNo = 'GJ-01-AB-1234',
    this.vehicleType = 'Two-Wheeler Scooter',
    this.aadhaarNumber = 'XXXX-XXXX-8912',
    this.electricityBillProvider = 'Torrent Power (Ahmedabad)',
    this.cluster = 'All Ahmedabad (Sindhu Bhavan, Bodakdev, Kubernagar & Gandhinagar)',
    this.isVerified = false,
    this.isBlacklisted = false,
  });

  DriverProfileState copyWith({
    String? name,
    String? phone,
    String? vehicleModel,
    String? vehicleRegNo,
    String? vehicleType,
    String? aadhaarNumber,
    String? electricityBillProvider,
    String? cluster,
    bool? isVerified,
    bool? isBlacklisted,
  }) {
    return DriverProfileState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleRegNo: vehicleRegNo ?? this.vehicleRegNo,
      vehicleType: vehicleType ?? this.vehicleType,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      electricityBillProvider: electricityBillProvider ?? this.electricityBillProvider,
      cluster: cluster ?? this.cluster,
      isVerified: isVerified ?? this.isVerified,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
    );
  }
}

final driverProfileProvider = StateProvider<DriverProfileState>((ref) => const DriverProfileState());
