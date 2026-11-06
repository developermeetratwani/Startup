import '../entities/address_entity.dart';
import '../core/failure.dart';

abstract class AddressRepository {
  Future<(List<AddressEntity>?, Failure?)> getAddresses(String userId);
  Stream<List<AddressEntity>> watchAddresses(String userId);
  Future<(String?, Failure?)> addAddress(AddressEntity address);
  Future<Failure?> updateAddress(AddressEntity address);
  Future<Failure?> deleteAddress(String addressId);
  Future<Failure?> setDefaultAddress(String userId, String addressId);
  Future<(AddressEntity?, Failure?)> getDefaultAddress(String userId);
}
