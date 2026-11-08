import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SupportChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? actionSuggestions;

  const SupportChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionSuggestions,
  });
}

/// Pre-Trained & LLM-Enabled HelpBot AI Assistant for XYZ Hyperlocal Fashion Marketplace
class SupportChatbotService {
  static String? llmApiKey;
  static String llmBaseUrl = 'https://integrate.api.nvidia.com/v1';
  static String llmModel = 'meta/llama-3.1-70b-instruct';

  static const String systemGuardrailPrompt = '''
You are HelpBot, the official customer support AI assistant for MARS Hyperlocal Fashion Marketplace in Ahmedabad and Gandhinagar, Gujarat.
STRICT DOMAIN GUARDRAILS:
1. You only answer questions related to MARS: clothing orders, sizing, 48-Hour Doorstep Size Exchange, delivery timelines (25-35 mins local, ~65 mins cross-city), Cash on Delivery (COD), boutique partner stores in Kubernagar/Gandhinagar/Sindhu Bhavan Road, and DPDP Act 2023 compliance.
2. If asked about programming, general knowledge, politics, sports, or anything outside MARS fashion shopping, politely decline: "I am HelpBot, dedicated exclusively to assisting you with XYZ Fashion Marketplace orders, sizing, 48-Hour exchanges, and delivery. How may I assist with your shopping today?"
3. Tone: Warm, helpful, concise, professional.
''';

  static final List<SupportChatMessage> _chatHistory = [
    SupportChatMessage(
      id: 'welcome',
      text: 'Hello! I am HelpBot, your MARS Fashion Assistant. How can I help with your apparel orders, sizing, 48-Hour exchange, or delivery tracking today?',
      isUser: false,
      timestamp: DateTime.now(),
      actionSuggestions: [
        'Where is my order?',
        'How does 48-Hour Size Exchange work?',
        'Can I pay via Cash on Delivery?',
        'Contact Grievance Officer',
      ],
    ),
  ];

  static final StreamController<List<SupportChatMessage>> _streamController =
      StreamController<List<SupportChatMessage>>.broadcast();

  static Stream<List<SupportChatMessage>> get stream {
    Timer.run(() {
      if (!_streamController.isClosed) {
        _streamController.add(List.unmodifiable(_chatHistory));
      }
    });
    return _streamController.stream;
  }

  static List<SupportChatMessage> get history => List.unmodifiable(_chatHistory);

  /// Process user query through specialized fashion domain knowledge base and LLM
  static Future<void> sendUserMessage(String userText) async {
    final userMsg = SupportChatMessage(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      text: userText,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _chatHistory.add(userMsg);
    _streamController.add(List.unmodifiable(_chatHistory));

    // Check if an external LLM key is configured
    if (llmApiKey != null && llmApiKey!.trim().isNotEmpty) {
      try {
        final llmResponse = await _callExternalLlm(userText);
        if (llmResponse != null) {
          final botMsg = SupportChatMessage(
            id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
            text: llmResponse,
            isUser: false,
            timestamp: DateTime.now(),
            actionSuggestions: ['Track My Order', '48h Size Exchange', 'Help Helpline'],
          );
          _chatHistory.add(botMsg);
          _streamController.add(List.unmodifiable(_chatHistory));
          return;
        }
      } catch (e) {
        debugPrint('[HelpBot] External LLM error, using trained engine: $e');
      }
    }

    // Default fast & resilient trained knowledge engine
    Timer(const Duration(milliseconds: 700), () {
      final (replyText, suggestions) = _generateTrainedAiResponse(userText);
      final botMsg = SupportChatMessage(
        id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
        actionSuggestions: suggestions,
      );
      _chatHistory.add(botMsg);
      _streamController.add(List.unmodifiable(_chatHistory));
    });
  }

  /// External LLM call (NVIDIA / OpenAI / Gemini compatible endpoint)
  static Future<String?> _callExternalLlm(String prompt) async {
    final url = Uri.parse('$llmBaseUrl/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $llmApiKey',
      },
      body: jsonEncode({
        'model': llmModel,
        'messages': [
          {'role': 'system', 'content': systemGuardrailPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.3,
        'max_tokens': 350,
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['choices']?[0]?['message']?['content'] as String?;
    }
    return null;
  }

  static (String text, List<String>? suggestions) _generateTrainedAiResponse(String input) {
    final q = input.toLowerCase();

    // Guardrail: Filter completely unrelated off-topic queries
    final offTopicKeywords = ['python', 'javascript', 'write code', 'movie', 'cricket match', 'president', 'weather', 'recipe', 'song'];
    if (offTopicKeywords.any((k) => q.contains(k))) {
      return (
        'I am HelpBot, trained exclusively to assist you with MARS Fashion Marketplace orders, sizing, doorstep exchanges, and delivery logistics in Ahmedabad & Gandhinagar. How can I assist with your garment order today?',
        ['Track My Order', '48-Hour Size Exchange', 'Payment Options', 'Contact Grievance Desk']
      );
    }

    if (q.contains('track') || q.contains('where is my order') || q.contains('delivery time') || q.contains('eta')) {
      return (
        'Your order is tracked in real-time on our live interactive OpenStreetMap! Deliveries within the same cluster (e.g. Kubernagar or Gandhinagar) take ~25-35 minutes. Cross-city orders (such as Kubernagar to Sindhu Bhavan Road, ~19.2 km) take approximately 65 minutes. You can check live rider movement directly on your active order tracking screen.',
        ['View Live Order Tracking', 'Chat with Delivery Driver', 'Delivery Policy']
      );
    }

    if (q.contains('size') || q.contains('exchange') || q.contains('return') || q.contains('fit') || q.contains('48')) {
      return (
        'We offer a hassle-free 48-Hour Doorstep Size Exchange under Rule 5(3) of Consumer Protection E-Commerce Rules! If the garment runs too tight or loose, go to "My Orders" -> Tap "Exchange Size" -> Select your requested size (XS to 3XL). A rider will arrive at your door with the replacement size at zero additional delivery charge.',
        ['Initiate Size Exchange', 'View Return Policy', 'Speak to Support']
      );
    }

    if (q.contains('cod') || q.contains('cash') || q.contains('payment') || q.contains('pay') || q.contains('upi')) {
      return (
        'We support both Cash on Delivery (COD) and Online UPI / Cards via Razorpay. For COD, our delivery partners carry physical change. Riders settle collected cash at authorized physical hubs (Kubernagar, Gandhinagar, etc.) using a 6-digit OTP verification desk.',
        ['Payment Methods', 'Is COD Free?', 'How Rider Hub Settlement Works']
      );
    }

    if (q.contains('cancel') || q.contains('refund')) {
      return (
        'Orders can be cancelled free of charge before the merchant marks them as "Preparing Item". Once packing begins or the courier is dispatched, cancellation is restricted to protect local boutique merchants. Online prepaid orders are refunded to the original payment source within 3-5 business days.',
        ['Cancellation Policy', 'Refund Status', 'Speak with Store']
      );
    }

    if (q.contains('otp') || q.contains('handover') || q.contains('pickup')) {
      return (
        'For secure store pickups, multiple drivers reaching a boutique must share a unique 4-digit Pickup OTP (e.g. 4821) with the vendor. The boutique verifies this code before releasing the garment parcel to ensure zero mix-ups.',
        ['Store Pickup OTP Details', 'Driver App Flow', 'Order Status']
      );
    }

    if (q.contains('grievance') || q.contains('legal') || q.contains('officer') || q.contains('privacy') || q.contains('complaint') || q.contains('dpdp')) {
      return (
        'Our statutory Grievance Redressal & Nodal Compliance Officer is Meet Ratwani (Ahmedabad, Gujarat).\n\nOfficial Redressal Email: grievance@marsfashion.in\nHelpline: +91 98980 12345\nOffice: Kubernagar Main Market, Ahmedabad - 382340.\n\nUnder India’s DPDP Act 2023, complaints receive written acknowledgment within 48 hours and resolution within 30 days.',
        ['View Privacy Policy', 'Submit Data Erasure', 'Contact Grievance Desk']
      );
    }

    if (q.contains('store') || q.contains('merchant') || q.contains('seller') || q.contains('vendor') || q.contains('boutique')) {
      return (
        'We partner directly with authentic local clothing boutiques across Ahmedabad (Kubernagar, Bodakdev, Sindhu Bhavan Road, Prahlad Nagar) and Gandhinagar. All garments are genuine store inventory inspected for quality before dispatch.',
        ['Explore Local Stores', 'Stores in Sindhu Bhavan', 'Stores in Kubernagar']
      );
    }

    // Default intelligent fallback
    return (
      'I can assist you with active order tracking, our 48-Hour Size Exchange guarantee, Cash on Delivery procedures, and connecting you directly with our delivery team. What would you like to know more about?',
      ['Track My Order', '48h Size Exchange', 'Chat with Driver', 'Grievance Officer']
    );
  }
}
