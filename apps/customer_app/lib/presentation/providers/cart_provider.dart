import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../data/repositories/cart_repository_impl.dart';
import 'auth_provider.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl();
});

final cartStreamProvider = StreamProvider<List<CartItemEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final repo = ref.watch(cartRepositoryProvider);
  return repo.watchCart(user.uid);
});

final selectedPaymentMethodProvider = StateProvider<PaymentMethod>((ref) => PaymentMethod.cod);

class CartSummary {
  final List<CartItemEntity> items;
  final int subtotal;         // in paise
  final int deliveryCharge;   // in paise
  final int packagingCharge;  // in paise (1% per quantity base)
  final int codCharge;        // in paise (₹21 = 2100 paise if COD)
  final int discount;         // in paise
  final int coinRedemption;   // in paise
  final int grandTotal;       // in paise
  final String? activeStoreId;

  const CartSummary({
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.packagingCharge,
    this.codCharge = 0,
    required this.discount,
    required this.coinRedemption,
    required this.grandTotal,
    this.activeStoreId,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  String get subtotalDisplay => '₹${(subtotal / 100).toStringAsFixed(0)}';
  String get deliveryDisplay => deliveryCharge == 0 ? 'FREE' : '₹${(deliveryCharge / 100).toStringAsFixed(0)}';
  String get packagingDisplay => '₹${(packagingCharge / 100).toStringAsFixed(0)}';
  String get codDisplay => '₹${(codCharge / 100).toStringAsFixed(0)}';
  String get grandTotalDisplay => '₹${(grandTotal / 100).toStringAsFixed(0)}';
}

final cartSummaryProvider = Provider<CartSummary>((ref) {
  final cartAsync = ref.watch(cartStreamProvider);
  final paymentMethod = ref.watch(selectedPaymentMethodProvider);
  final items = cartAsync.valueOrNull ?? [];

  int subtotal = 0;
  String? storeId;

  for (var item in items) {
    subtotal += item.lineTotal;
    storeId = item.storeId;
  }

  // Delivery fee: ₹25 (2500 paise), Free if cart > ₹999 (99900 paise)
  final int deliveryCharge = (subtotal > 99900 || items.isEmpty) ? 0 : 2500;
  
  // Packaging fee: 1% of item total (per quantity)
  final int packagingCharge = items.isEmpty ? 0 : (subtotal * 0.01).round();

  // COD fee: ₹21 (2100 paise) if COD chosen
  final int codCharge = (paymentMethod == PaymentMethod.cod && items.isNotEmpty) ? 2100 : 0;

  const int discount = 0;
  const int coinRedemption = 0;
  final int grandTotal = (subtotal + deliveryCharge + packagingCharge + codCharge - discount - coinRedemption).clamp(0, 99999999);

  return CartSummary(
    items: items,
    subtotal: subtotal,
    deliveryCharge: deliveryCharge,
    packagingCharge: packagingCharge,
    codCharge: codCharge,
    discount: discount,
    coinRedemption: coinRedemption,
    grandTotal: grandTotal,
    activeStoreId: storeId,
  );
});
