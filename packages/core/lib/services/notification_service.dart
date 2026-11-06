import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/app_logger.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    AppLogger.info('NotificationService', 'Permission: ${settings.authorizationStatus}');

    // Get FCM token
    final token = await _messaging.getToken();
    AppLogger.info('NotificationService', 'FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      AppLogger.info('NotificationService', 'Foreground: ${message.notification?.title}');
      // TODO: show in-app notification banner
    });
  }

  Future<String?> getFcmToken() => _messaging.getToken();

  void onTokenRefresh(void Function(String) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }
}
