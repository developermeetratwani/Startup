import 'dart:convert';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

const String _kUsername = 'developermeetratwani@gmail.com';
const String _kPassword = 'ixly pnec uvrp iiby';
const int _kPort = 5055;

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, _kPort);
  print('📧 XYZ Startup SMTP Mail Bridge running on http://localhost:$_kPort');

  await for (HttpRequest request in server) {
    // Enable CORS for Flutter Web running on localhost:3000, 3001, 3002, 3003
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Origin, Accept');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    if (request.uri.path == '/health') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'status': 'healthy', 'service': 'XYZ SMTP Bridge'}));
      await request.response.close();
      continue;
    }

    if (request.method == 'POST' && request.uri.path == '/send-email') {
      try {
        final content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content) as Map<String, dynamic>;

        final to = data['to'] as String? ?? '';
        final subject = data['subject'] as String? ?? 'XYZ Startup Notification';
        final html = data['html'] as String? ?? '';
        final appName = data['appName'] as String? ?? 'XYZ Startup';

        if (to.isEmpty) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'error': 'Recipient email "to" is required'}));
          await request.response.close();
          continue;
        }

        print('Sending email to $to | Subject: $subject');
        final smtpServer = gmail(_kUsername, _kPassword);
        final message = Message()
          ..from = Address(_kUsername, appName)
          ..recipients.add(to)
          ..subject = subject
          ..html = html;

        await send(message, smtpServer);
        print('✅ Email delivered successfully to $to');

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'success': true, 'to': to, 'subject': subject}));
      } catch (e, st) {
        print('❌ Error sending email: $e\n$st');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': e.toString()}));
      } finally {
        await request.response.close();
      }
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Endpoint not found');
      await request.response.close();
    }
  }
}
