import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/app_logger.dart';

/// In-app and push notification model across Customer, Vendor, and Driver apps
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'order_status', 'proximity_alert', 'handover_otp', 'invoice_ready', 'delivery_complete'
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    DateTime? timestamp,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final StreamController<AppNotification> _streamController =
      StreamController<AppNotification>.broadcast();

  static final List<AppNotification> _history = [];

  /// Global stream of in-app and push notifications for real-time listener widgets
  static Stream<AppNotification> get notificationStream => _streamController.stream;

  /// Recent notification inbox history
  static List<AppNotification> get notificationHistory => List.unmodifiable(_history);

  Future<void> init() async {
    // Request permission
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      AppLogger.info('NotificationService', 'Permission: ${settings.authorizationStatus}');

      // Get FCM token
      final token = await _messaging.getToken();
      AppLogger.info('NotificationService', 'FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        AppLogger.info('NotificationService', 'Foreground: ${message.notification?.title}');
        if (message.notification != null) {
          dispatchNotification(
            AppNotification(
              id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: message.notification!.title ?? 'Order Update',
              body: message.notification!.body ?? '',
              type: 'fcm_remote',
              data: message.data,
            ),
          );
        }
      });
    } catch (e) {
      AppLogger.warning('NotificationService.init', 'Firebase messaging init info: $e');
    }
  }

  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  void onTokenRefresh(void Function(String) callback) {
    try {
      _messaging.onTokenRefresh.listen(callback);
    } catch (_) {}
  }

  /// Dispatch an in-app push notification across the platform
  static void dispatchNotification(AppNotification notification) {
    _history.insert(0, notification);
    if (_history.length > 50) _history.removeLast();
    _streamController.add(notification);
    AppLogger.info('NotificationService', 'Dispatched notification: ${notification.title} - ${notification.body}');
  }

  /// Dispatch proximity geofence alert when driver is within 100 meters
  static void dispatchProximityAlert({
    required String orderId,
    required String driverName,
    int distanceMeters = 95,
  }) {
    dispatchNotification(
      AppNotification(
        id: 'prox-${DateTime.now().millisecondsSinceEpoch}',
        title: '🔔 Rider Within 100m of Your Gate!',
        body: '$driverName is arriving with your fashion package. Please be ready at your doorstep.',
        type: 'proximity_alert',
        data: {'orderId': orderId, 'distance': distanceMeters},
      ),
    );
  }

  /// Dispatch order stage transition alert
  static void dispatchStageChange({
    required String orderId,
    required String status,
    required String message,
  }) {
    dispatchNotification(
      AppNotification(
        id: 'stage-${DateTime.now().millisecondsSinceEpoch}',
        title: '📦 Order Status: $status',
        body: message,
        type: 'order_status',
        data: {'orderId': orderId, 'status': status},
      ),
    );
  }

  /// Dispatch pickup handover OTP alert to boutique vendor
  static void dispatchHandoverOtp({
    required String orderId,
    required String driverName,
    required String otpCode,
  }) {
    dispatchNotification(
      AppNotification(
        id: 'otp-${DateTime.now().millisecondsSinceEpoch}',
        title: '🔑 Driver Arrived for Store Handover',
        body: '$driverName has arrived at your boutique. Verify Pickup OTP $otpCode before handing over garments.',
        type: 'handover_otp',
        data: {'orderId': orderId, 'otp': otpCode},
      ),
    );
  }

  /// Dispatch delivery completed notification
  static void dispatchDeliveryCompleted({
    required String orderId,
    required String customerName,
  }) {
    dispatchNotification(
      AppNotification(
        id: 'deliv-${DateTime.now().millisecondsSinceEpoch}',
        title: '🎉 Delivery Completed!',
        body: 'Package successfully delivered to $customerName. Tax invoice has been emailed to you.',
        type: 'delivery_complete',
        data: {'orderId': orderId},
      ),
    );
  }
}
