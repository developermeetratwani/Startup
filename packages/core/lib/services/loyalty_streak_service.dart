import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Secret 8-Week Streak Loyalty Reward Service
/// Quietly calculates user weekly order consistency.
/// If user orders consistently for 8 weeks (2 months), unlocks a secret one-time 10% discount!
class LoyaltyStreakService {
  static const String _keyPrefix = 'mars_order_streak_';
  static const String _rewardClaimedPrefix = 'mars_reward_claimed_';

  /// Record an order for the current week
  static Future<void> recordOrderForUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final currentWeekId = '${now.year}_W${(now.difference(DateTime(now.year, 1, 1)).inDays / 7).ceil()}';

      final historyJson = prefs.getString('$_keyPrefix$userId') ?? '[]';
      final List<dynamic> weeks = jsonDecode(historyJson);

      if (!weeks.contains(currentWeekId)) {
        weeks.add(currentWeekId);
        await prefs.setString('$_keyPrefix$userId', jsonEncode(weeks));
      }
    } catch (_) {}
  }

  /// Check if user has qualified for secret 10% discount (8+ weeks of orders)
  static Future<bool> isSecretDiscountEligible(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isClaimed = prefs.getBool('$_rewardClaimedPrefix$userId') ?? false;
      if (isClaimed) return false;

      final historyJson = prefs.getString('$_keyPrefix$userId') ?? '[]';
      final List<dynamic> weeks = jsonDecode(historyJson);

      // 8 or more distinct weeks of orders
      return weeks.length >= 8;
    } catch (_) {
      return false;
    }
  }

  /// Mark secret discount as used
  static Future<void> markSecretDiscountClaimed(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_rewardClaimedPrefix$userId', true);
    } catch (_) {}
  }
}
