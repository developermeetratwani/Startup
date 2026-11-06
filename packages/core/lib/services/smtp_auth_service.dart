import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:domain/domain.dart';
import '../utils/app_logger.dart';

class SmtpAuthService {
  final String host;
  final int port;
  final String username;
  final String password;
  final bool ssl;

  const SmtpAuthService({
    this.host = 'smtp.gmail.com',
    this.port = 587,
    this.username = 'meetgaming43@gmail.com',
    this.password = '',
    this.ssl = false,
  });

  /// Send verification or OTP email to a user
  Future<Failure?> sendOtpEmail({
    required String recipientEmail,
    required String otpCode,
    String appName = 'XYZ Hyperlocal Fashion',
  }) async {
    try {
      if (password.isEmpty) {
        // Safe simulation fallback when SMTP secret is not injected
        AppLogger.info('SmtpAuthService', 'Simulated OTP $otpCode dispatched to $recipientEmail via SMTP');
        return null;
      }

      final smtpServer = SmtpServer(
        host,
        port: port,
        ssl: ssl,
        username: username,
        password: password,
        allowInsecure: true,
      );

      final message = Message()
        ..from = Address(username, appName)
        ..recipients.add(recipientEmail)
        ..subject = '$appName — Your Verification OTP: $otpCode'
        ..html = '''
          <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
            <h2 style="color: #6C5CE7;">$appName</h2>
            <p>Hello,</p>
            <p>Your one-time security authentication code is:</p>
            <h1 style="background: #f1f2f6; padding: 12px 24px; display: inline-block; letter-spacing: 5px; color: #2d3436; border-radius: 8px;">$otpCode</h1>
            <p>This code is valid for 10 minutes. If you did not request this, please ignore this email.</p>
            <br/>
            <p style="font-size: 12px; color: #888;">&copy; 2026 $appName. All rights reserved.</p>
          </div>
        ''';

      await send(message, smtpServer);
      return null;
    } catch (e) {
      AppLogger.error('SmtpAuthService.sendOtpEmail', e.toString());
      return ServerFailure('Failed to send OTP via SMTP: $e');
    }
  }
}
