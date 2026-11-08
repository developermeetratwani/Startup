import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:domain/domain.dart';
import '../utils/app_logger.dart';

/// MARS SMTP Email Service
/// Sends branded transactional emails from developermeetratwani@gmail.com
class SmtpAuthService {
  final String host;
  final int port;
  final String username;
  final String password;
  final bool ssl;

  const SmtpAuthService({
    this.host = 'smtp.gmail.com',
    this.port = 587,
    this.username = 'developermeetratwani@gmail.com',
    this.password = 'ixly pnec uvrp iiby',
    this.ssl = false,
  });

  // ── Shared brand header & footer ─────────────────────────────────────────

  static String _header(String appName) => '''
    <div style="font-family:'Segoe UI',Arial,sans-serif;max-width:580px;margin:auto;border:1px solid #e8e8f0;border-radius:12px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.07);">
    <!-- Header banner -->
    <div style="background:linear-gradient(135deg,#6C5CE7 0%,#a29bfe 100%);padding:32px 36px;">
      <table cellpadding="0" cellspacing="0" border="0" width="100%"><tr>
        <td><span style="font-size:28px;">🛍️</span></td>
        <td style="padding-left:12px;">
          <div style="color:#fff;font-size:20px;font-weight:700;letter-spacing:-0.5px;">$appName</div>
          <div style="color:rgba(255,255,255,0.75);font-size:12px;margin-top:2px;">Hyperlocal Fashion Marketplace</div>
        </td>
      </tr></table>
    </div>
    <!-- Body -->
    <div style="padding:32px 36px;background:#fafaf8;">
  ''';

  static String _footer() => '''
    </div>
    <!-- Footer -->
    <div style="background:#f1f0f7;padding:20px 36px;border-top:1px solid #e0dff5;">
      <p style="margin:0;font-size:12px;color:#9b9bb4;text-align:center;">
        You received this email from <strong>MARS</strong> because you have an account with us.<br/>
        Kubernagar &amp; Gandhinagar, Gujarat, India &nbsp;|&nbsp;
        <a href="mailto:developermeetratwani@gmail.com" style="color:#6C5CE7;text-decoration:none;">Support</a>
      </p>
    </div>
    </div>
  ''';

  // ── OTP helper ────────────────────────────────────────────────────────────

  static String generateOtp() {
    final rand = Random.secure();
    return (100000 + rand.nextInt(900000)).toString();
  }

  // ── Send helpers ──────────────────────────────────────────────────────────

  Future<Failure?> _send({
    required String to,
    required String subject,
    required String htmlBody,
    String appName = 'MARS',
  }) async {
    try {
      if (kIsWeb) {
        // In Web browsers, raw TCP sockets to port 587 are blocked by browser sandboxes.
        // Route through the active SMTP Bridge daemon on http://localhost:5055
        try {
          final res = await http.post(
            Uri.parse('http://localhost:5055/send-email'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'to': to,
              'subject': subject,
              'html': htmlBody,
              'appName': appName,
            }),
          );
          if (res.statusCode == 200) {
            AppLogger.info('SmtpAuthService', '✅ Email sent via SMTP Bridge → $to | $subject');
            return null;
          }
        } catch (webErr) {
          AppLogger.warning('SmtpAuthService', 'Web bridge attempt: $webErr');
        }
      }

      if (password.isEmpty) {
        AppLogger.info('SmtpAuthService', 'SMTP password not set – email simulation mode.');
        return null;
      }
      final smtpServer = gmail(username, password);
      final message = Message()
        ..from = Address(username, appName)
        ..recipients.add(to)
        ..subject = subject
        ..html = htmlBody;
      await send(message, smtpServer);
      AppLogger.info('SmtpAuthService', 'Email sent → $to | $subject');
      return null;
    } catch (e) {
      AppLogger.error('SmtpAuthService._send', e.toString());
      return null; // Always non-fatal so app never crashes on email
    }
  }

  // ── 1. Welcome email after signup ─────────────────────────────────────────

  Future<Failure?> sendWelcomeEmail({
    required String recipientEmail,
    required String displayName,
    String appName = 'MARS',
  }) async {
    final body = '''
      ${_header(appName)}
        <h2 style="margin:0 0 8px;color:#2d2d4e;font-size:22px;">Welcome, $displayName! 🎉</h2>
        <p style="color:#555;line-height:1.7;margin:0 0 20px;">
          We are thrilled to have you on <strong>$appName</strong> — your hyperlocal fashion destination for <strong>Kubernagar &amp; Gandhinagar</strong>.
          Local stores. Real style. Lightning-fast delivery.
        </p>

        <!-- CTA button -->
        <div style="text-align:center;margin:28px 0;">
          <a href="https://mars-1d49a.web.app"
             style="background:linear-gradient(135deg,#6C5CE7,#a29bfe);color:#fff;padding:14px 36px;
                    border-radius:8px;font-size:15px;font-weight:700;text-decoration:none;display:inline-block;
                    letter-spacing:0.3px;box-shadow:0 4px 14px rgba(108,92,231,0.4);">
            🛍️ Start Shopping Now
          </a>
        </div>

        <!-- Feature tiles -->
        <table cellpadding="0" cellspacing="0" border="0" width="100%" style="margin-top:12px;">
          <tr>
            <td align="center" style="padding:12px 8px;background:#fff;border-radius:10px;border:1px solid #ece9ff;width:33%;">
              <div style="font-size:24px;">⚡</div>
              <div style="font-size:12px;font-weight:700;color:#6C5CE7;margin-top:4px;">45-Min Delivery</div>
            </td>
            <td width="8"></td>
            <td align="center" style="padding:12px 8px;background:#fff;border-radius:10px;border:1px solid #ece9ff;width:33%;">
              <div style="font-size:24px;">🏪</div>
              <div style="font-size:12px;font-weight:700;color:#6C5CE7;margin-top:4px;">Local Stores</div>
            </td>
            <td width="8"></td>
            <td align="center" style="padding:12px 8px;background:#fff;border-radius:10px;border:1px solid #ece9ff;width:33%;">
              <div style="font-size:24px;">💰</div>
              <div style="font-size:12px;font-weight:700;color:#6C5CE7;margin-top:4px;">COD Available</div>
            </td>
          </tr>
        </table>

        <p style="color:#9b9bb4;font-size:12px;margin-top:28px;">
          From the MARS team — if you have any questions, reply to this email or reach us at
          <a href="mailto:developermeetratwani@gmail.com" style="color:#6C5CE7;">developermeetratwani@gmail.com</a>.
        </p>
      ${_footer()}
    ''';

    return _send(
      to: recipientEmail,
      subject: '🎉 Welcome to $appName, $displayName!',
      htmlBody: body,
      appName: appName,
    );
  }

  // ── 2. OTP / verification email ───────────────────────────────────────────

  Future<Failure?> sendOtpEmail({
    required String recipientEmail,
    required String otpCode,
    String appName = 'MARS',
  }) async {
    final body = '''
      ${_header(appName)}
        <h2 style="margin:0 0 8px;color:#2d2d4e;font-size:22px;">Your Verification Code</h2>
        <p style="color:#555;line-height:1.7;margin:0 0 24px;">
          From <strong>$appName</strong>, we are sending you this one-time code to verify your identity.
          Please use it within <strong>10 minutes</strong>.
        </p>

        <!-- OTP box -->
        <div style="background:linear-gradient(135deg,#6C5CE7 0%,#a29bfe 100%);border-radius:12px;padding:28px;text-align:center;margin:0 0 24px;">
          <div style="color:rgba(255,255,255,0.8);font-size:13px;letter-spacing:1px;margin-bottom:12px;">ONE-TIME PASSWORD</div>
          <div style="color:#fff;font-size:42px;font-weight:800;letter-spacing:14px;font-family:'Courier New',monospace;">$otpCode</div>
        </div>

        <p style="color:#e17055;font-size:13px;background:#fff5f3;border-left:4px solid #e17055;padding:10px 14px;border-radius:4px;margin:0 0 20px;">
          ⚠️ Never share this code with anyone. $appName will never ask for your OTP.
        </p>
        <p style="color:#9b9bb4;font-size:12px;">
          If you did not request this code, you can safely ignore this email.
          Sent by the <strong>MARS</strong> team.
        </p>
      ${_footer()}
    ''';

    return _send(
      to: recipientEmail,
      subject: '[$appName] Your OTP: $otpCode',
      htmlBody: body,
      appName: appName,
    );
  }

  // ── 3. Order confirmation email ───────────────────────────────────────────

  Future<Failure?> sendOrderConfirmationEmail({
    required String recipientEmail,
    required String customerName,
    required String orderId,
    required String storeName,
    required int grandTotalPaise,
    required int etaMinutes,
    String appName = 'MARS',
  }) async {
    final total = '₹${(grandTotalPaise / 100).toStringAsFixed(0)}';
    final shortId = orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase();

    final body = '''
      ${_header(appName)}
        <h2 style="margin:0 0 4px;color:#2d2d4e;font-size:22px;">Order Confirmed! ✅</h2>
        <p style="color:#555;line-height:1.7;margin:0 0 20px;">
          Hi <strong>$customerName</strong>, your order from <strong>$storeName</strong> has been placed successfully.
          From the MARS team — we are on it!
        </p>

        <!-- Order info card -->
        <div style="background:#fff;border:1px solid #ece9ff;border-radius:12px;padding:20px 24px;margin-bottom:20px;">
          <table cellpadding="0" cellspacing="0" border="0" width="100%">
            <tr>
              <td style="font-size:13px;color:#9b9bb4;">Order ID</td>
              <td align="right" style="font-size:13px;font-weight:700;color:#2d2d4e;font-family:'Courier New',monospace;">#$shortId</td>
            </tr>
            <tr><td colspan="2" style="padding:6px 0;"><hr style="border:none;border-top:1px solid #f0eeff;"/></td></tr>
            <tr>
              <td style="font-size:13px;color:#9b9bb4;">Store</td>
              <td align="right" style="font-size:13px;font-weight:600;color:#2d2d4e;">$storeName</td>
            </tr>
            <tr><td colspan="2" style="padding:6px 0;"><hr style="border:none;border-top:1px solid #f0eeff;"/></td></tr>
            <tr>
              <td style="font-size:13px;color:#9b9bb4;">Total Paid</td>
              <td align="right" style="font-size:16px;font-weight:800;color:#6C5CE7;">$total</td>
            </tr>
            <tr><td colspan="2" style="padding:6px 0;"><hr style="border:none;border-top:1px solid #f0eeff;"/></td></tr>
            <tr>
              <td style="font-size:13px;color:#9b9bb4;">Estimated ETA</td>
              <td align="right" style="font-size:13px;font-weight:700;color:#00b894;">⚡ ~$etaMinutes mins</td>
            </tr>
          </table>
        </div>

        <p style="color:#9b9bb4;font-size:12px;">
          Questions? Contact us at
          <a href="mailto:developermeetratwani@gmail.com" style="color:#6C5CE7;">developermeetratwani@gmail.com</a>.
          We will make sure your fashion arrives on time. 🛵
        </p>
      ${_footer()}
    ''';

    return _send(
      to: recipientEmail,
      subject: '[$appName] Order #$shortId Confirmed — ETA ~$etaMinutes mins',
      htmlBody: body,
      appName: appName,
    );
  }

  // ── 4. Rider Hub COD Handover OTP Email ─────────────────────────────────────

  Future<Failure?> sendCodRemittanceOtpEmail({
    required String recipientEmail,
    required String driverName,
    required String otpCode,
    required int amountPaise,
    required String hubLocation,
    String appName = 'MARS',
  }) async {
    final amountText = '₹${(amountPaise / 100).toStringAsFixed(0)}';

    final body = '''
      ${_header(appName)}
        <h2 style="margin:0 0 8px;color:#2d2d4e;font-size:22px;">COD Cash Handover OTP 🔐</h2>
        <p style="color:#555;line-height:1.7;margin:0 0 20px;">
          Hi <strong>$driverName</strong>, you have initiated a physical cash deposit of collected COD funds.
        </p>

        <!-- Handover Details Card -->
        <div style="background:#fff;border:1px solid #ece9ff;border-radius:12px;padding:20px 24px;margin-bottom:20px;">
          <table cellpadding="0" cellspacing="0" border="0" width="100%">
            <tr>
              <td style="font-size:13px;color:#9b9bb4;">Hub Collection Location</td>
              <td align="right" style="font-size:13px;font-weight:700;color:#2d2d4e;">$hubLocation</td>
            </tr>
            <tr><td colspan="2" style="padding:6px 0;"><hr style="border:none;border-top:1px solid #f0eeff;"/></td></tr>
            <tr>
              <td style="font-size:13px;color:#9b9bb4;">Cash Amount to Handover</td>
              <td align="right" style="font-size:18px;font-weight:800;color:#e67e22;">$amountText</td>
            </tr>
          </table>
        </div>

        <!-- OTP box -->
        <div style="background:linear-gradient(135deg,#e67e22 0%,#f39c12 100%);border-radius:12px;padding:24px;text-align:center;margin:0 0 24px;">
          <div style="color:rgba(255,255,255,0.85);font-size:12px;letter-spacing:1px;margin-bottom:8px;">SHARE THIS OTP WITH HUB CASHIER / ADMIN</div>
          <div style="color:#fff;font-size:40px;font-weight:800;letter-spacing:12px;font-family:'Courier New',monospace;">$otpCode</div>
        </div>

        <p style="color:#d35400;font-size:12px;background:#fef5e7;border-left:4px solid #e67e22;padding:10px 14px;border-radius:4px;margin:0 0 20px;">
          ⚠️ Hand over the exact physical cash of <strong>$amountText</strong> to the Hub Cashier. Once the Admin verifies this OTP on their console, your cash-in-hand liability will be cleared immediately.
        </p>
      ${_footer()}
    ''';

    return _send(
      to: recipientEmail,
      subject: '[$appName] COD Handover OTP: $otpCode ($amountText at $hubLocation)',
      htmlBody: body,
      appName: appName,
    );
  }

  // ── 5. Rider COD Settlement Confirmed Receipt Email ────────────────────────

  Future<Failure?> sendCodSettlementConfirmedEmail({
    required String recipientEmail,
    required String driverName,
    required String settlementId,
    required int amountPaise,
    required String hubLocation,
    required String adminId,
    String appName = 'MARS',
  }) async {
    final amountText = '₹${(amountPaise / 100).toStringAsFixed(0)}';

    final body = '''
      ${_header(appName)}
        <h2 style="margin:0 0 8px;color:#27ae60;font-size:22px;">Cash Settlement Verified & Cleared! ✅</h2>
        <p style="color:#555;line-height:1.7;margin:0 0 20px;">
          Hi <strong>$driverName</strong>, your physical cash handover of <strong>$amountText</strong> has been verified and settled by Admin <strong>$adminId</strong>.
        </p>

        <!-- Receipt Card -->
        <div style="background:#fff;border:1px solid #d4edda;border-radius:12px;padding:20px 24px;margin-bottom:20px;">
          <table cellpadding="0" cellspacing="0" border="0" width="100%">
            <tr>
              <td style="font-size:13px;color:#9b9bb4;">Receipt Reference</td>
              <td align="right" style="font-size:13px;font-weight:700;color:#2d2d4e;font-family:'Courier New',monospace;">#$settlementId</td>
            </tr>
            <tr><td colspan="2" style="padding:6px 0;"><hr style="border:none;border-top:1px solid #f0eeff;"/></td></tr>
            <tr>
              <td style="font-size:13px;color:#9b9bb4;">Deposit Location</td>
              <td align="right" style="font-size:13px;font-weight:600;color:#2d2d4e;">$hubLocation</td>
            </tr>
            <tr><td colspan="2" style="padding:6px 0;"><hr style="border:none;border-top:1px solid #f0eeff;"/></td></tr>
            <tr>
              <td style="font-size:13px;color:#9b9bb4;">Amount Cleared</td>
              <td align="right" style="font-size:16px;font-weight:800;color:#27ae60;">$amountText</td>
            </tr>
            <tr><td colspan="2" style="padding:6px 0;"><hr style="border:none;border-top:1px solid #f0eeff;"/></td></tr>
            <tr>
              <td style="font-size:13px;color:#9b9bb4;">Verification Status</td>
              <td align="right" style="font-size:13px;font-weight:700;color:#27ae60;">VERIFIED BY ADMIN</td>
            </tr>
          </table>
        </div>

        <p style="color:#555;font-size:12px;">
          Your Cash In Hand balance has been updated. Thank you for your punctual settlement!
        </p>
      ${_footer()}
    ''';

    return _send(
      to: recipientEmail,
      subject: '[$appName] Receipt #$settlementId: $amountText COD Settled at $hubLocation',
      htmlBody: body,
      appName: appName,
    );
  }
}
