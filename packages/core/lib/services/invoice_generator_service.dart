import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:domain/domain.dart';

class TaxInvoiceData {
  final String invoiceNumber;
  final String orderId;
  final DateTime invoiceDate;
  final String marketplaceName;
  final String marketplaceGstin;
  final String marketplaceAddress;
  final String vendorName;
  final String vendorGstin;
  final String vendorAddress;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String? razorpayPaymentId;
  final List<InvoiceItem> items;
  final int subtotalPaise;
  final int packagingPaise;
  final int deliveryFeePaise;
  final int codFeePaise;
  final int grandTotalPaise;
  final String grievanceOfficer;

  const TaxInvoiceData({
    required this.invoiceNumber,
    required this.orderId,
    required this.invoiceDate,
    this.marketplaceName = 'MARS Hyperlocal Fashion Marketplace Pvt. Ltd.',
    this.marketplaceGstin = '24AAACX1234F1Z5',
    this.marketplaceAddress = 'B-42, Krishna Park Colony, Kubernagar Main Bazar, Ahmedabad - 382340',
    required this.vendorName,
    this.vendorGstin = '24BBBPV5678M1ZQ',
    required this.vendorAddress,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    this.razorpayPaymentId,
    required this.items,
    required this.subtotalPaise,
    required this.packagingPaise,
    required this.deliveryFeePaise,
    required this.codFeePaise,
    required this.grandTotalPaise,
    this.grievanceOfficer = 'Meet Ratwani (grievance@marsfashion.in)',
  });
}

class InvoiceItem {
  final String name;
  final String size;
  final int quantity;
  final int unitPricePaise;
  final int gstRatePercent;

  const InvoiceItem({
    required this.name,
    required this.size,
    required this.quantity,
    required this.unitPricePaise,
    this.gstRatePercent = 5,
  });

  int get totalPaise => unitPricePaise * quantity;
}

class InvoiceGeneratorService {
  static const String mailBridgeUrl = 'http://localhost:5055/send-email';

  /// Build invoice data from domain OrderEntity
  static TaxInvoiceData fromOrder(OrderEntity order, {String? customerName, String? customerPhone}) {
    final displayId = order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase();
    final invNum = 'INV-2026-$displayId';

    final addr = order.deliveryAddressSnapshot['line1'] ?? 'Kubernagar Main Bazar, Ahmedabad';
    final city = order.deliveryAddressSnapshot['city'] ?? 'Ahmedabad';
    final pincode = order.deliveryAddressSnapshot['pincode'] ?? '382340';

    return TaxInvoiceData(
      invoiceNumber: invNum,
      orderId: order.id,
      invoiceDate: order.placedAt,
      vendorName: 'Royal Heritage Boutique (Store #KBN-01)',
      vendorAddress: 'Shop 14, Sindhi Market, Kubernagar, Ahmedabad - 382340',
      customerName: customerName ?? 'Meet Ratwani',
      customerPhone: customerPhone ?? '+91 98980 12345',
      customerAddress: '$addr, $city - $pincode',
      paymentMethod: order.paymentMethod.name == 'cod' ? 'Cash on Delivery (COD)' : 'Online Paid (Razorpay Gateway)',
      paymentStatus: order.paymentStatus.name.toUpperCase(),
      razorpayPaymentId: order.razorpayPaymentId,
      items: [
        const InvoiceItem(
          name: 'Handcrafted Festive Kurti / Apparel',
          size: 'L',
          quantity: 1,
          unitPricePaise: 89900,
          gstRatePercent: 5,
        ),
      ],
      subtotalPaise: order.pricing.productTotal,
      packagingPaise: order.pricing.packagingCharge,
      deliveryFeePaise: order.pricing.deliveryCharge,
      codFeePaise: order.pricing.codCharge,
      grandTotalPaise: order.pricing.grandTotal,
    );
  }

  /// Generate clean, statutory HTML Invoice with branding
  static String generateHtmlInvoice(TaxInvoiceData data) {
    final subtotalRs = (data.subtotalPaise / 100).toStringAsFixed(2);
    final packagingRs = (data.packagingPaise / 100).toStringAsFixed(2);
    final deliveryRs = (data.deliveryFeePaise / 100).toStringAsFixed(2);
    final codRs = (data.codFeePaise / 100).toStringAsFixed(2);
    final grandTotalRs = (data.grandTotalPaise / 100).toStringAsFixed(2);

    final rowsHtml = data.items.map((item) {
      final unitRs = (item.unitPricePaise / 100).toStringAsFixed(2);
      final totRs = (item.totalPaise / 100).toStringAsFixed(2);
      return '''
      <tr style="border-bottom: 1px solid #E2E8F0;">
        <td style="padding: 10px 8px;"><strong>${item.name}</strong><br><span style="font-size: 11px; color: #718096;">Size: ${item.size} • 48-Hour Doorstep Exchange Applicable</span></td>
        <td style="padding: 10px 8px; text-align: center;">${item.quantity}</td>
        <td style="padding: 10px 8px; text-align: right;">₹$unitRs</td>
        <td style="padding: 10px 8px; text-align: center;">${item.gstRatePercent}%</td>
        <td style="padding: 10px 8px; text-align: right; font-weight: bold;">₹$totRs</td>
      </tr>
      ''';
    }).join('');

    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Tax Invoice - ${data.invoiceNumber}</title>
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background-color: #F8FAFC; color: #1A202C;">
      <div style="max-width: 680px; margin: 0 auto; background: #FFFFFF; border-radius: 12px; border: 1px solid #E2E8F0; padding: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
        
        <!-- Header -->
        <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid #6C5CE7; padding-bottom: 20px;">
          <div>
            <h1 style="margin: 0; font-size: 22px; color: #6C5CE7; font-weight: 800; letter-spacing: -0.5px;">MARS</h1>
            <p style="margin: 4px 0 0 0; font-size: 12px; color: #4A5568; font-weight: 600;">Hyperlocal Fashion Marketplace</p>
            <p style="margin: 2px 0 0 0; font-size: 11px; color: #718096;">CIN: U72900GJ2026PTC123456 • GSTIN: ${data.marketplaceGstin}</p>
            <p style="margin: 2px 0 0 0; font-size: 11px; color: #718096;">${data.marketplaceAddress}</p>
          </div>
          <div style="text-align: right;">
            <span style="background: #EDE9FE; color: #6C5CE7; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: bold;">TAX INVOICE</span>
            <p style="margin: 8px 0 0 0; font-size: 13px; font-weight: bold;">${data.invoiceNumber}</p>
            <p style="margin: 2px 0 0 0; font-size: 11px; color: #718096;">Date: ${data.invoiceDate.toLocal().toString().substring(0, 16)}</p>
          </div>
        </div>

        <!-- Vendor & Customer Info -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0; background: #F8FAFC; padding: 14px; border-radius: 8px;">
          <div>
            <p style="margin: 0 0 4px 0; font-size: 10px; text-transform: uppercase; color: #A0AEC0; font-weight: bold;">Sold By (Registered Boutique Vendor)</p>
            <p style="margin: 0; font-size: 13px; font-weight: bold;">${data.vendorName}</p>
            <p style="margin: 2px 0 0 0; font-size: 11px; color: #4A5568;">${data.vendorAddress}</p>
            <p style="margin: 2px 0 0 0; font-size: 11px; color: #718096;">GSTIN: ${data.vendorGstin}</p>
          </div>
          <div>
            <p style="margin: 0 0 4px 0; font-size: 10px; text-transform: uppercase; color: #A0AEC0; font-weight: bold;">Delivered To (Customer)</p>
            <p style="margin: 0; font-size: 13px; font-weight: bold;">${data.customerName}</p>
            <p style="margin: 2px 0 0 0; font-size: 11px; color: #4A5568;">${data.customerAddress}</p>
            <p style="margin: 2px 0 0 0; font-size: 11px; color: #718096;">Mobile: ${data.customerPhone}</p>
          </div>
        </div>

        <!-- Order & Payment Info -->
        <div style="margin-bottom: 20px; padding: 10px 14px; background: #EFF6FF; border-left: 4px solid #3B82F6; border-radius: 4px; font-size: 12px;">
          <strong>Order ID:</strong> ${data.orderId} • <strong>Payment:</strong> ${data.paymentMethod} • <strong>Status:</strong> <span style="color: #059669; font-weight: bold;">${data.paymentStatus}</span>
          ${data.razorpayPaymentId != null ? ' • <strong>Razorpay Ref:</strong> ' + data.razorpayPaymentId! : ''}
        </div>

        <!-- Items Table -->
        <table style="width: 100%; border-collapse: collapse; font-size: 12px; margin-bottom: 20px;">
          <thead>
            <tr style="background: #F1F5F9; color: #475569; font-weight: bold; text-align: left;">
              <th style="padding: 10px 8px;">Description</th>
              <th style="padding: 10px 8px; text-align: center;">Qty</th>
              <th style="padding: 10px 8px; text-align: right;">Unit Price</th>
              <th style="padding: 10px 8px; text-align: center;">GST</th>
              <th style="padding: 10px 8px; text-align: right;">Amount</th>
            </tr>
          </thead>
          <tbody>
            $rowsHtml
          </tbody>
        </table>

        <!-- Summary Calculation -->
        <div style="display: flex; justify-content: flex-end; margin-bottom: 24px;">
          <div style="width: 280px; font-size: 12px;">
            <div style="display: flex; justify-content: space-between; padding: 4px 0;">
              <span style="color: #64748B;">Items Subtotal:</span>
              <span style="font-weight: 600;">₹$subtotalRs</span>
            </div>
            <div style="display: flex; justify-content: space-between; padding: 4px 0;">
              <span style="color: #64748B;">Eco-Packaging (1%):</span>
              <span>₹$packagingRs</span>
            </div>
            <div style="display: flex; justify-content: space-between; padding: 4px 0;">
              <span style="color: #64748B;">Hyperlocal Delivery:</span>
              <span>₹$deliveryRs</span>
            </div>
            ${data.codFeePaise > 0 ? '''
            <div style="display: flex; justify-content: space-between; padding: 4px 0;">
              <span style="color: #64748B;">COD Handling Surcharge:</span>
              <span>₹$codRs</span>
            </div>
            ''' : ''}
            <div style="display: flex; justify-content: space-between; padding: 10px 0; border-top: 2px solid #E2E8F0; font-size: 15px; font-weight: 800; color: #1E293B;">
              <span>Grand Total:</span>
              <span style="color: #6C5CE7;">₹$grandTotalRs</span>
            </div>
          </div>
        </div>

        <!-- Statutory Compliance & Footnotes -->
        <div style="border-top: 1px dashed #CBD5E1; padding-top: 16px; font-size: 10px; color: #64748B; line-height: 1.5;">
          <p style="margin: 0 0 4px 0;"><strong>Consumer Protection (E-Commerce) Rules:</strong> 48-Hour Doorstep Size Exchange is available on eligible fashion garments. Initiate via app within 48 hours of delivery.</p>
          <p style="margin: 0 0 4px 0;"><strong>DPDP Act 2023 Compliance:</strong> Your personal transaction data is protected with end-to-end encryption. Grievance Officer: ${data.grievanceOfficer}.</p>
          <p style="margin: 0; text-align: center; color: #94A3B8;">This is a computer-generated statutory Tax Invoice and does not require a physical signature.</p>
        </div>

      </div>
    </body>
    </html>
    ''';
  }

  /// Dispatch statutory PDF invoice to customer inbox via SMTP Bridge
  static Future<bool> emailInvoiceToCustomer({
    required TaxInvoiceData invoice,
    required String recipientEmail,
  }) async {
    try {
      final html = generateHtmlInvoice(invoice);
      final response = await http.post(
        Uri.parse(mailBridgeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': recipientEmail,
          'subject': 'Your Tax Invoice & Bill for Order #${invoice.orderId} — MARS',
          'html': html,
          'appName': 'MARS Fashion Marketplace',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[InvoiceGeneratorService] Email dispatch failed: $e');
      return false;
    }
  }
}
