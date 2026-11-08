import 'dart:async';

class DealBanner {
  final String id;
  final String title;
  final String subtitle;
  final String promoCode;
  final int discountPercent;
  final String badgeText;
  final String gradientStart;
  final String gradientEnd;
  final bool isActive;

  const DealBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.promoCode,
    required this.discountPercent,
    required this.badgeText,
    required this.gradientStart,
    required this.gradientEnd,
    this.isActive = true,
  });

  DealBanner copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? promoCode,
    int? discountPercent,
    String? badgeText,
    String? gradientStart,
    String? gradientEnd,
    bool? isActive,
  }) {
    return DealBanner(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      promoCode: promoCode ?? this.promoCode,
      discountPercent: discountPercent ?? this.discountPercent,
      badgeText: badgeText ?? this.badgeText,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      isActive: isActive ?? this.isActive,
    );
  }
}

class DealsService {
  DealsService._();

  static final List<DealBanner> _deals = [
    const DealBanner(
      id: 'deal-1',
      title: 'KUBERNAGAR FESTIVE GALA',
      subtitle: 'Flat 50% Off on Pure Silk & Chanderi Sarees • 45-Min Drop',
      promoCode: 'KUBER50',
      discountPercent: 50,
      badgeText: 'FESTIVE MEGA DEAL',
      gradientStart: '0xFF171717',
      gradientEnd: '0xFFD93670',
      isActive: true,
    ),
    const DealBanner(
      id: 'deal-2',
      title: 'SINDHU BHAVAN DESIGNER SUITS',
      subtitle: 'Flat ₹500 Instant Discount on Premium Italian Wool Suits',
      promoCode: 'SUIT500',
      discountPercent: 20,
      badgeText: 'BOUTIQUE SPECIAL',
      gradientStart: '0xFF1F2937',
      gradientEnd: '0xFF4F46E5',
      isActive: true,
    ),
    const DealBanner(
      id: 'deal-3',
      title: 'FREE EXPRESS 45-MIN DELIVERY',
      subtitle: 'Zero delivery fee across all Ahmedabad & Gandhinagar stores',
      promoCode: 'FREEMARS',
      discountPercent: 100,
      badgeText: 'LIMITED FLASH DEAL',
      gradientStart: '0xFF0F172A',
      gradientEnd: '0xFFF04438',
      isActive: true,
    ),
  ];

  static final StreamController<List<DealBanner>> _controller =
      StreamController<List<DealBanner>>.broadcast();

  static Stream<List<DealBanner>> get dealsStream async* {
    yield List.unmodifiable(_deals.where((d) => d.isActive).toList());
    yield* _controller.stream;
  }

  static List<DealBanner> get allDeals => List.unmodifiable(_deals);

  static void addDeal(DealBanner deal) {
    _deals.insert(0, deal);
    _controller.add(List.unmodifiable(_deals.where((d) => d.isActive).toList()));
  }

  static void toggleDeal(String id) {
    final idx = _deals.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      final current = _deals[idx];
      _deals[idx] = current.copyWith(isActive: !current.isActive);
      _controller.add(List.unmodifiable(_deals.where((d) => d.isActive).toList()));
    }
  }

  static void deleteDeal(String id) {
    _deals.removeWhere((d) => d.id == id);
    _controller.add(List.unmodifiable(_deals.where((d) => d.isActive).toList()));
  }
}
