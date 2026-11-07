import 'dart:convert';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

const String _kUsername = 'developermeetratwani@gmail.com';
const String _kPassword = 'ixly pnec uvrp iiby';
const int _kPort = 5055;

// Shared file for persistent order state
final File _ordersFile = File('${Directory.current.path}/orders_state.json');

List<Map<String, dynamic>> _orders = [];

void _initOrders() {
  try {
    if (_ordersFile.existsSync()) {
      final content = _ordersFile.readAsStringSync();
      final decoded = jsonDecode(content);
      if (decoded is List) {
        _orders = decoded.cast<Map<String, dynamic>>();
        print('📦 Loaded ${_orders.length} orders from persistent disk storage');
        return;
      }
    }
  } catch (e) {
    print('⚠️ Error loading orders_state.json: $e');
  }

  // Baseline seed orders
  _orders = [
    {
      'id': 'ord-kubernagar-8920',
      'customerId': 'cust-ahmedabad-01',
      'storeId': 'store-kubernagar-1',
      'vendorId': 'vendor-kubernagar-1',
      'driverId': null,
      'deliveryAddressId': 'addr-ahmedabad-01',
      'deliveryAddressSnapshot': {
        'recipientName': 'Kavya Sharma',
        'phone': '+91 98765 43210',
        'addressLine1': 'B-42, Krishna Park Colony, Kubernagar Main Bazar',
        'city': 'Ahmedabad',
        'pincode': '382340',
      },
      'status': 'readyForPickup',
      'paymentMethod': 'cod',
      'paymentStatus': 'pending',
      'pricing': {
        'productTotal': 89900,
        'deliveryCharge': 2500,
        'packagingCharge': 899,
        'codCharge': 2100,
        'exchangeCharge': 0,
        'discount': 0,
        'coinRedemption': 0,
        'grandTotal': 95399,
        'platformCommission': 8990,
        'vendorEarning': 80910,
        'driverEarning': 4500,
      },
      'estimatedDeliveryMinutes': 28,
      'placedAt': DateTime.now().subtract(const Duration(minutes: 12)).toIso8601String(),
    },
    {
      'id': 'ord-delivered-7731',
      'customerId': 'cust-ahmedabad-01',
      'storeId': 'store-kubernagar-1',
      'vendorId': 'vendor-kubernagar-1',
      'driverId': 'driver-1',
      'deliveryAddressId': 'addr-ahmedabad-01',
      'deliveryAddressSnapshot': {
        'recipientName': 'Kavya Sharma',
        'phone': '+91 98765 43210',
        'addressLine1': 'B-42, Krishna Park Colony, Kubernagar Main Bazar',
        'city': 'Ahmedabad',
        'pincode': '382340',
      },
      'status': 'delivered',
      'paymentMethod': 'payOnline',
      'paymentStatus': 'paid',
      'pricing': {
        'productTotal': 149900,
        'deliveryCharge': 0,
        'packagingCharge': 1499,
        'codCharge': 0,
        'exchangeCharge': 0,
        'discount': 0,
        'coinRedemption': 0,
        'grandTotal': 151399,
        'platformCommission': 14990,
        'vendorEarning': 134910,
        'driverEarning': 4500,
      },
      'estimatedDeliveryMinutes': 35,
      'placedAt': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      'deliveredAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
    },
  ];
  _persistOrders();
}

void _persistOrders() {
  try {
    _ordersFile.writeAsStringSync(jsonEncode(_orders), flush: true);
  } catch (e) {
    print('⚠️ Error persisting orders to disk: $e');
  }
}

void main() async {
  _initOrders();
  final server = await HttpServer.bind(InternetAddress.anyIPv4, _kPort);
  print('🚀 XYZ Startup Inter-App Order Bridge & SMTP Server running on http://0.0.0.0:$_kPort');

  await for (HttpRequest request in server) {
    // Enable CORS for Flutter Web running on localhost:3000, 3001, 3002, 3003, 8000
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PATCH, DELETE');
    request.response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Origin, Accept');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    final path = request.uri.path;

    // ── HEALTH CHECK ────────────────────────────────────────────────
    if (path == '/health') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'status': 'healthy', 'service': 'XYZ Bridge', 'ordersCount': _orders.length}));
      await request.response.close();
      continue;
    }

    // ── ORDERS API: GET ALL ──────────────────────────────────────────
    if (request.method == 'GET' && path == '/api/orders') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(_orders));
      await request.response.close();
      continue;
    }

    // ── ORDERS API: CREATE OR REGISTER ORDER ─────────────────────────
    if (request.method == 'POST' && path == '/api/orders') {
      try {
        final bodyStr = await utf8.decoder.bind(request).join();
        final orderMap = jsonDecode(bodyStr) as Map<String, dynamic>;
        final orderId = orderMap['id'] as String? ?? 'ord-${DateTime.now().millisecondsSinceEpoch}';
        orderMap['id'] = orderId;

        final idx = _orders.indexWhere((o) => o['id'] == orderId);
        if (idx >= 0) {
          _orders[idx] = orderMap;
        } else {
          _orders.insert(0, orderMap);
        }
        _persistOrders();
        print('📦 [Bridge] Order registered: $orderId (Store: ${orderMap['storeId']}, Status: ${orderMap['status']})');

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'success': true, 'order': orderMap}));
      } catch (e) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': e.toString()}));
      } finally {
        await request.response.close();
      }
      continue;
    }

    // ── ORDERS API: UPDATE STATUS ────────────────────────────────────
    if (request.method == 'POST' && path == '/api/orders/update-status') {
      try {
        final bodyStr = await utf8.decoder.bind(request).join();
        final data = jsonDecode(bodyStr) as Map<String, dynamic>;
        final orderId = data['orderId'] as String?;
        final newStatus = data['status'] as String?;
        final driverId = data['driverId'] as String?;

        if (orderId == null || newStatus == null) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'error': 'orderId and status required'}));
          await request.response.close();
          continue;
        }

        final idx = _orders.indexWhere((o) => o['id'] == orderId);
        if (idx >= 0) {
          final existing = Map<String, dynamic>.from(_orders[idx]);
          existing['status'] = newStatus;
          if (driverId != null) {
            existing['driverId'] = driverId;
          }
          if (newStatus == 'delivered') {
            existing['deliveredAt'] = DateTime.now().toIso8601String();
            existing['paymentStatus'] = 'paid';
          }
          _orders[idx] = existing;
          _persistOrders();
          print('🔄 [Bridge] Order $orderId status updated to $newStatus (driver: ${existing['driverId']})');

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'success': true, 'order': existing}));
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'error': 'Order not found'}));
        }
      } catch (e) {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': e.toString()}));
      } finally {
        await request.response.close();
      }
      continue;
    }

    // ── ORDERS API: DRIVER ATOMIC ACCEPTANCE LOCK ────────────────────
    if (request.method == 'POST' && path == '/api/orders/accept-driver') {
      try {
        final bodyStr = await utf8.decoder.bind(request).join();
        final data = jsonDecode(bodyStr) as Map<String, dynamic>;
        final orderId = data['orderId'] as String?;
        final driverId = data['driverId'] as String?;
        final driverName = data['driverName'] as String? ?? 'Driver Partner';

        if (orderId == null || driverId == null) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'error': 'orderId and driverId required'}));
          await request.response.close();
          continue;
        }

        final idx = _orders.indexWhere((o) => o['id'] == orderId);
        if (idx >= 0) {
          final existing = Map<String, dynamic>.from(_orders[idx]);
          // Check concurrency lock: if already claimed by another driver
          final currentClaimant = existing['driverId'] as String?;
          if (currentClaimant != null && currentClaimant != driverId) {
            request.response
              ..statusCode = HttpStatus.conflict
              ..headers.contentType = ContentType.json
              ..write(jsonEncode({'success': false, 'message': 'Already claimed by another driver'}));
            await request.response.close();
            continue;
          }

          existing['driverId'] = driverId;
          existing['driverName'] = driverName;
          _orders[idx] = existing;
          _persistOrders();
          print('🛵 [Bridge] Order $orderId locked to driver $driverName ($driverId)');

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'success': true, 'claimed': true, 'order': existing}));
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'error': 'Order not found'}));
        }
      } catch (e) {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': e.toString()}));
      } finally {
        await request.response.close();
      }
      continue;
    }

    // ── SMTP EMAIL BRIDGE ────────────────────────────────────────────
    if (request.method == 'POST' && path == '/send-email') {
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
      continue;
    }

    // Default 404
    request.response
      ..statusCode = HttpStatus.notFound
      ..write('Endpoint not found');
    await request.response.close();
  }
}
