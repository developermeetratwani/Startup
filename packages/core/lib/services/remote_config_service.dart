import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../utils/app_logger.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _rc = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    try {
      await _rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _rc.setDefaults({
        'commission_rate': 0.10,
        'max_coin_redemption_per_order': 10000, // paise = ₹100
        'delivery_fee_flat': 2500,              // paise = ₹25
        'referral_coin_reward': 5000,           // paise = ₹50
        'min_order_for_referral_reward': 20000, // paise = ₹200
        'low_stock_threshold': 5,
        'store_discovery_radius_km': 10.0,
      });
      await _rc.fetchAndActivate();
    } catch (e) {
      AppLogger.warning('RemoteConfig', 'Failed to fetch remote config: $e');
    }
  }

  double get commissionRate => _rc.getDouble('commission_rate');
  int get maxCoinRedemptionPerOrder => _rc.getInt('max_coin_redemption_per_order');
  int get deliveryFeeFlat => _rc.getInt('delivery_fee_flat');
  int get referralCoinReward => _rc.getInt('referral_coin_reward');
  int get minOrderForReferralReward => _rc.getInt('min_order_for_referral_reward');
  int get lowStockThreshold => _rc.getInt('low_stock_threshold');
  double get storeDiscoveryRadiusKm => _rc.getDouble('store_discovery_radius_km');
}
