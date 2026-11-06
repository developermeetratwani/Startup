import '../entities/product_entity.dart';
import '../core/failure.dart';

abstract class ProductRepository {
  Future<(List<ProductEntity>?, Failure?)> getProductsByStore({
    required String storeId,
    String? categoryId,
    int limit = 20,
    dynamic lastDocument,
  });
  Future<(List<ProductEntity>?, Failure?)> getProductsByCategory({
    required String categoryId,
    int limit = 20,
    dynamic lastDocument,
  });
  Future<(ProductEntity?, Failure?)> getProductById(String productId);
  Future<(List<ProductEntity>?, Failure?)> searchProducts({
    required String query,
    String? storeId,
    int limit = 20,
  });
  Future<(String?, Failure?)> createProduct(ProductEntity product);
  Future<Failure?> updateProduct({
    required String productId,
    required Map<String, dynamic> fields,
  });
  Future<Failure?> addVariant({
    required String productId,
    required ProductVariantEntity variant,
  });
  Future<Failure?> updateStock({
    required String productId,
    required String variantId,
    required int newStock,
  });
}
