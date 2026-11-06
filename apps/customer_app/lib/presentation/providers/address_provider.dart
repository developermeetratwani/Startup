import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../data/repositories/address_repository_impl.dart';
import 'auth_provider.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepositoryImpl();
});

final userAddressesProvider = StreamProvider<List<AddressEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final repo = ref.watch(addressRepositoryProvider);
  return repo.watchAddresses(user.uid);
});

final selectedAddressIdProvider = StateProvider<String?>((ref) => null);

final selectedAddressProvider = Provider<AddressEntity?>((ref) {
  final addressesAsync = ref.watch(userAddressesProvider);
  final selectedId = ref.watch(selectedAddressIdProvider);
  final list = addressesAsync.valueOrNull ?? [];

  if (list.isEmpty) return null;
  if (selectedId != null) {
    return list.firstWhere((a) => a.id == selectedId, orElse: () => list.first);
  }
  return list.firstWhere((a) => a.isDefault, orElse: () => list.first);
});
