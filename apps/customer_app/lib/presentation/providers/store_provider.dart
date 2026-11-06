import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../data/repositories/store_repository_impl.dart';
import 'location_provider.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepositoryImpl();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final nearbyStoresProvider = FutureProvider<List<StoreEntity>>((ref) async {
  final repo = ref.watch(storeRepositoryProvider);
  final location = ref.watch(locationProvider);
  final category = ref.watch(selectedCategoryProvider);

  final (stores, failure) = await repo.getNearbyStores(
    latitude: location.latitude,
    longitude: location.longitude,
    radiusKm: 15.0,
    categoryId: category,
  );

  if (failure != null) {
    throw Exception(failure.message);
  }
  return stores ?? [];
});

final singleStoreProvider = StreamProvider.family<StoreEntity?, String>((ref, storeId) {
  final repo = ref.watch(storeRepositoryProvider);
  return repo.watchStore(storeId);
});
