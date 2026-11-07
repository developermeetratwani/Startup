import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../data/repositories/product_repository_impl.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});

final storeProductsProvider = FutureProvider.family<List<ProductEntity>, ({String storeId, String? categoryId})>((ref, arg) async {
  final repo = ref.watch(productRepositoryProvider);
  final (products, failure) = await repo.getProductsByStore(
    storeId: arg.storeId,
    categoryId: arg.categoryId,
  );
  if (failure != null) throw Exception(failure.message);
  return products ?? [];
});

final singleProductProvider = FutureProvider.family<ProductEntity?, String>((ref, productId) async {
  final repo = ref.watch(productRepositoryProvider);
  final (product, failure) = await repo.getProductById(productId);
  if (failure != null) throw Exception(failure.message);
  return product;
});

final homeProductsProvider = FutureProvider.family<List<ProductEntity>, String?>((ref, categoryId) async {
  final repo = ref.watch(productRepositoryProvider);
  final (products, failure) = await repo.getProductsByCategory(
    categoryId: categoryId ?? 'all',
    limit: 20,
  );
  if (failure != null) throw Exception(failure.message);
  return products ?? [];
});

final productSearchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final query = ref.watch(productSearchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repo = ref.watch(productRepositoryProvider);
  final (results, failure) = await repo.searchProducts(query: query);
  if (failure != null) throw Exception(failure.message);
  return results ?? [];
});
