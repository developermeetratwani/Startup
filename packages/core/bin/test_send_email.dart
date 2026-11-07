import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  const username = 'developermeetratwani@gmail.com';
  const password = 'ixly pnec uvrp iiby';
  
  print('Connecting to Gmail SMTP server...');
  final smtpServer = gmail(username, password);
  
  final message = Message()
    ..from = const Address(username, 'XYZ Startup Team')
    ..recipients.add('developermeetratwani@gmail.com')
    ..subject = '⚡ Live Verification: XYZ Startup Email Engine is Active'
    ..html = '''
      <div style="font-family:'Segoe UI',Arial,sans-serif;max-width:580px;margin:auto;border:1px solid #e8e8f0;border-radius:12px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.07);">
        <div style="background:linear-gradient(135deg,#6C5CE7 0%,#a29bfe 100%);padding:32px 36px;color:#fff;">
          <h1 style="margin:0;font-size:24px;">XYZ Startup</h1>
          <p style="margin:4px 0 0;font-size:14px;opacity:0.9;">Hyperlocal Fashion Marketplace • Live Email Test</p>
        </div>
        <div style="padding:32px 36px;background:#ffffff;">
          <h2 style="color:#2d2d4e;font-size:20px;margin-top:0;">Hello Meet, Email Dispatch Verified! 🚀</h2>
          <p style="color:#4a4a68;line-height:1.6;font-size:15px;">
            This is an automated verification test sent directly from your XYZ Startup SMTP engine.
          </p>
          <div style="background:#f4f3ff;border-left:4px solid #6C5CE7;padding:16px;border-radius:6px;margin:20px 0;">
            <p style="margin:0;color:#2d2d4e;font-weight:600;font-size:14px;">Service Details:</p>
            <ul style="margin:8px 0 0;padding-left:20px;color:#555;font-size:13px;">
              <li><strong>Sender:</strong> developermeetratwani@gmail.com</li>
              <li><strong>Recipient:</strong> developermeetratwani@gmail.com</li>
              <li><strong>Protocol:</strong> Gmail SMTP (App Password Secured)</li>
              <li><strong>Status:</strong> Active &amp; Ready for Production</li>
            </ul>
          </div>
          <p style="color:#666;font-size:13px;line-height:1.5;">
            All transactional emails (Customer signup OTPs, Vendor order notifications, and Driver Hub COD OTPs) are flowing smoothly.
          </p>
        </div>
        <div style="background:#f1f0f7;padding:16px 36px;text-align:center;font-size:12px;color:#888;">
          XYZ Startup Ahmedabad & Gandhinagar • Live Production Test
        </div>
      </div>
    ''';

  try {
    final sendReport = await send(message, smtpServer);
    print('SUCCESS: Email sent successfully! Report: $sendReport');
  } catch (e) {
    print('ERROR: Failed to send email: $e');
  }
}
