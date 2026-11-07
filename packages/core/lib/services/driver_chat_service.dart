import 'dart:async';

class ChatMessage {
  final String id;
  final String orderId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'customer' or 'driver'
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'senderId': senderId,
    'senderName': senderName,
    'senderRole': senderRole,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    orderId: json['orderId'] as String,
    senderId: json['senderId'] as String,
    senderName: json['senderName'] as String,
    senderRole: json['senderRole'] as String,
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class DriverChatService {
  static final Map<String, List<ChatMessage>> _orderChats = {
    'ord-kubernagar-8920': [
      ChatMessage(
        id: 'msg-1',
        orderId: 'ord-kubernagar-8920',
        senderId: 'driver-1',
        senderName: 'Suresh Solanki',
        senderRole: 'driver',
        text: 'Namaste! I have picked up your clothing parcel from Shreeji Ethnic Studio. On my way now!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
    ],
  };

  static final StreamController<List<ChatMessage>> _chatStreamController =
      StreamController<List<ChatMessage>>.broadcast();

  static Stream<List<ChatMessage>> watchChat(String orderId) {
    // Initial emit
    Timer.run(() {
      if (!_chatStreamController.isClosed) {
        _chatStreamController.add(List.unmodifiable(_orderChats[orderId] ?? []));
      }
    });
    return _chatStreamController.stream;
  }

  static List<ChatMessage> getMessages(String orderId) {
    return List.unmodifiable(_orderChats[orderId] ?? []);
  }

  static void sendMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) {
    final list = _orderChats.putIfAbsent(orderId, () => []);
    final newMsg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text,
      timestamp: DateTime.now(),
    );
    list.add(newMsg);
    _chatStreamController.add(List.unmodifiable(list));

    // Automated intelligent driver reply simulation if customer texts
    if (senderRole == 'customer') {
      Timer(const Duration(milliseconds: 1400), () {
        String driverReply = 'Got it! I am navigating on Google Maps, will be at your door shortly.';
        final lower = text.toLowerCase();
        if (lower.contains('gate') || lower.contains('security')) {
          driverReply = 'Understood! I will notify the security guard and hand over the parcel.';
        } else if (lower.contains('change') || lower.contains('cod') || lower.contains('cash')) {
          driverReply = 'Yes, I have cash change ready with me for ₹100/₹500 notes!';
        } else if (lower.contains('call') || lower.contains('phone')) {
          driverReply = 'Sure, I will call your mobile number once I arrive at your building.';
        }

        final autoReply = ChatMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          orderId: orderId,
          senderId: 'driver-1',
          senderName: 'Suresh Solanki',
          senderRole: 'driver',
          text: driverReply,
          timestamp: DateTime.now(),
        );
        list.add(autoReply);
        _chatStreamController.add(List.unmodifiable(list));
      });
    }
  }
}
