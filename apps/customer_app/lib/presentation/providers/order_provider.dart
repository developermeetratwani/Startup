import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../data/repositories/order_repository_impl.dart';
import 'auth_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl();
});

final customerOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchCustomerOrders(user.uid);
});

final singleOrderStreamProvider = StreamProvider.family<OrderEntity?, String>((ref, orderId) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchOrder(orderId);
});
