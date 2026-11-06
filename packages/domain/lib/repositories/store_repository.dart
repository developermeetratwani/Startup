import '../entities/store_entity.dart';
import '../core/failure.dart';

abstract class StoreRepository {
  Future<(List<StoreEntity>?, Failure?)> getNearbyStores({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? categoryId,
    int limit = 20,
  });
  Future<(StoreEntity?, Failure?)> getStoreById(String storeId);
  Future<(StoreEntity?, Failure?)> getStoreByVendorId(String vendorId);
  Stream<StoreEntity?> watchStore(String storeId);
  Future<Failure?> updateStore({
    required String storeId,
    required Map<String, dynamic> fields,
  });
  Future<Failure?> setStoreOpenStatus({
    required String storeId,
    required bool isOpen,
  });
}
