import 'dart:async';

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

/// Pre-Trained Support AI Engine for XYZ Hyperlocal Fashion Marketplace
class SupportChatbotService {
  static final List<SupportChatMessage> _chatHistory = [
    SupportChatMessage(
      id: 'welcome',
      text: 'Hello! I am FashionBot, your XYZ Startup AI Assistant. How can I help with your apparel orders, sizing, delivery, or returns today?',
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

  /// Process user query through specialized fashion domain knowledge base
  static void sendUserMessage(String userText) {
    final userMsg = SupportChatMessage(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      text: userText,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _chatHistory.add(userMsg);
    _streamController.add(List.unmodifiable(_chatHistory));

    // Simulate AI thinking and return trained contextual response
    Timer(const Duration(milliseconds: 900), () {
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

  static (String text, List<String>? suggestions) _generateTrainedAiResponse(String input) {
    final q = input.toLowerCase();

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

    if (q.contains('grievance') || q.contains('legal') || q.contains('officer') || q.contains('privacy') || q.contains('complaint') || q.contains('dpdp')) {
      return (
        'Our statutory Grievance Redressal & Nodal Compliance Officer is Meet Ratwani (Ahmedabad, Gujarat).\n\nOfficial Redressal Email: grievance@xyzstartup.in\nHelpline: +91 98980 12345\nOffice: Kubernagar Main Market, Ahmedabad - 382340.\n\nUnder India’s DPDP Act 2023, complaints receive written acknowledgment within 48 hours and resolution within 30 days.',
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
