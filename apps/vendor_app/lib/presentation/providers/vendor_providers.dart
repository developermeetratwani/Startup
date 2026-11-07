import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../data/repositories/vendor_store_repository.dart';
import '../../data/repositories/vendor_product_repository.dart';
import '../../data/repositories/vendor_order_repository.dart';
import '../../data/repositories/vendor_earnings_repository.dart';

final vendorStoreRepoProvider = Provider<VendorStoreRepository>((ref) {
  return VendorStoreRepository();
});

final vendorProductRepoProvider = Provider<VendorProductRepository>((ref) {
  return VendorProductRepository();
});

final vendorOrderRepoProvider = Provider<VendorOrderRepository>((ref) {
  return VendorOrderRepository();
});

final vendorEarningsRepoProvider = Provider<VendorEarningsRepository>((ref) {
  return VendorEarningsRepository();
});

final vendorStoreStatusOverrideProvider = StateProvider<bool?>((ref) => null);

// Current active store for this vendor
final currentStoreProvider = StreamProvider<StoreEntity?>((ref) {
  final repo = ref.watch(vendorStoreRepoProvider);
  final statusOverride = ref.watch(vendorStoreStatusOverrideProvider);
  String uid = 'vendor-preview-1';
  try {
    uid = FirebaseAuth.instance.currentUser?.uid ?? uid;
  } catch (_) {}

  return repo.watchStoreByVendorId(uid).map((store) {
    final baseStore = store ?? StoreEntity(
      id: 'store-kubernagar-1',
      vendorId: uid,
      name: 'Shreeji Ethnic & Bridal Studio',
      description: 'Authentic Chaniya Choli, Kurtis & Designer Bridal Wear in Kubernagar Market',
      bannerImageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop',
      logoImageUrl: null,
      categoryIds: const ['women', 'ethnic'],
      location: const GeoLocation(
        latitude: 23.0768,
        longitude: 72.6346,
        geohash: 'ts5g',
        address: 'Shop 12-14, Main Market, Kubernagar',
        city: 'Ahmedabad',
        pincode: '382340',
      ),
      isOpen: true,
      isActive: true,
      rating: 4.8,
      totalRatings: 142,
      createdAt: DateTime.now(),
    );
    if (statusOverride != null) {
      return StoreEntity(
        id: baseStore.id,
        vendorId: baseStore.vendorId,
        name: baseStore.name,
        description: baseStore.description,
        bannerImageUrl: baseStore.bannerImageUrl,
        logoImageUrl: baseStore.logoImageUrl,
        categoryIds: baseStore.categoryIds,
        location: baseStore.location,
        isOpen: statusOverride,
        isActive: baseStore.isActive,
        rating: baseStore.rating,
        totalRatings: baseStore.totalRatings,
        createdAt: baseStore.createdAt,
      );
    }
    return baseStore;
  });
});

// Vendor's products stream
final vendorProductsProvider = StreamProvider<List<ProductEntity>>((ref) {
  final repo = ref.watch(vendorProductRepoProvider);
  final storeAsync = ref.watch(currentStoreProvider);
  final storeId = storeAsync.valueOrNull?.id ?? 'store-kubernagar-1';

  return repo.watchVendorProducts(storeId).map((products) {
    if (products.isEmpty) {
      return [
        ProductEntity(
          id: 'vprod-1',
          storeId: storeId,
          vendorId: 'vendor-1',
          name: 'Royal Velvet Embroidered Kurti',
          description: 'Handcrafted zari work velvet kurti with intricate border detailing.',
          categoryId: 'women',
          imageUrls: const [
            'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&auto=format&fit=crop',
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop',
          ],
          basePrice: 129900,
          discountedPrice: 89900,
          isPublished: true,
          tags: const ['kurti', 'ethnic'],
          rating: 4.8,
          totalRatings: 38,
          totalSold: 120,
          variants: const [
            ProductVariantEntity(
              id: 'v1',
              productId: 'vprod-1',
              size: 'M',
              color: 'Maroon',
              colorHex: '#800000',
              additionalPrice: 0,
              sku: 'KUR-MAR-M',
              stockCount: 15,
              isAvailable: true,
            ),
            ProductVariantEntity(
              id: 'v2',
              productId: 'vprod-1',
              size: 'L',
              color: 'Navy Blue',
              colorHex: '#000080',
              additionalPrice: 0,
              sku: 'KUR-NAV-L',
              stockCount: 12,
              isAvailable: true,
            ),
          ],
          createdAt: DateTime.now(),
        ),
        ProductEntity(
          id: 'vprod-2',
          storeId: storeId,
          vendorId: 'vendor-1',
          name: 'Navratri Chaniya Choli Set',
          description: 'Traditional Gujarati Kutchi mirror work flare chaniya.',
          categoryId: 'ethnic',
          imageUrls: const [
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop',
          ],
          basePrice: 349900,
          discountedPrice: 249900,
          isPublished: true,
          tags: const ['chaniyacholi', 'ethnic'],
          rating: 4.9,
          totalRatings: 86,
          totalSold: 210,
          variants: const [
            ProductVariantEntity(
              id: 'v3',
              productId: 'vprod-2',
              size: 'Free Size',
              color: 'Multicolor',
              colorHex: '#FF4500',
              additionalPrice: 0,
              sku: 'CC-MULTI-FS',
              stockCount: 8,
              isAvailable: true,
            ),
          ],
          createdAt: DateTime.now(),
        ),
      ];
    }
    return products;
  });
});

// Vendor's orders stream
final vendorOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  final repo = ref.watch(vendorOrderRepoProvider);
  final storeAsync = ref.watch(currentStoreProvider);
  final storeId = storeAsync.valueOrNull?.id ?? 'store-kubernagar-1';

  return repo.watchVendorOrders(storeId).handleError((_) => OrderSyncService.getOrdersForStore(storeId)).map((orders) {
    if (orders.isEmpty) {
      return [
        OrderEntity(
          id: 'ord-101',
          customerId: 'cust-1',
          storeId: storeId,
          vendorId: 'vendor-1',
          status: OrderStatus.pending,
          deliveryAddressId: 'addr-1',
          deliveryAddressSnapshot: const {
            'recipientName': 'Kavya Sharma',
            'phone': '+91 98765 43210',
            'addressLine1': 'Block C-4, Krishna Complex, Kubernagar',
            'city': 'Ahmedabad',
          },
          paymentMethod: PaymentMethod.cod,
          paymentStatus: PaymentStatus.pending,
          pricing: const OrderPricing(
            productTotal: 89900,
            deliveryCharge: 2500,
            packagingCharge: 899,
            codCharge: 2100,
            discount: 0,
            coinRedemption: 0,
            grandTotal: 95399,
            platformCommission: 8990,
            vendorEarning: 80910,
            driverEarning: 2500,
          ),
          placedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        OrderEntity(
          id: 'ord-102',
          customerId: 'cust-2',
          storeId: storeId,
          vendorId: 'vendor-1',
          status: OrderStatus.confirmed,
          deliveryAddressId: 'addr-2',
          deliveryAddressSnapshot: const {
            'recipientName': 'Priya Patel',
            'phone': '+91 91234 56789',
            'addressLine1': 'Flat 202, Shivalik Tower, Sector 21',
            'city': 'Gandhinagar',
          },
          paymentMethod: PaymentMethod.payOnline,
          paymentStatus: PaymentStatus.paid,
          pricing: const OrderPricing(
            productTotal: 249900,
            deliveryCharge: 0,
            packagingCharge: 2499,
            codCharge: 0,
            discount: 0,
            coinRedemption: 0,
            grandTotal: 252399,
            platformCommission: 24990,
            vendorEarning: 224910,
            driverEarning: 2500,
          ),
          placedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
      ];
    }
    return orders;
  });
});

// Earnings summary provider
final vendorEarningsProvider = StreamProvider<VendorEarningsSummary>((ref) {
  final repo = ref.watch(vendorEarningsRepoProvider);
  final storeAsync = ref.watch(currentStoreProvider);
  final storeId = storeAsync.valueOrNull?.id ?? 'store-kubernagar-1';
  final vendorId = storeAsync.valueOrNull?.vendorId ?? 'vendor-1';

  return repo.watchEarnings(storeId, vendorId).map((summary) {
    if (summary.totalSales == 0) {
      return const VendorEarningsSummary(
        totalSales: 339800,
        platformCommission: 33980,
        netEarnings: 305820,
        completedOrders: 3,
        storeCoins: 350,
        referralCode: 'SHREEJI-KUBER',
      );
    }
    return summary;
  });
});


