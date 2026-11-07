import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:core/core.dart';

class DriverChatDialog extends StatefulWidget {
  final String orderId;
  final String driverName;
  final String driverPhone;

  const DriverChatDialog({
    super.key,
    required this.orderId,
    this.driverName = 'Suresh Solanki',
    this.driverPhone = '+91 98980 12345',
  });

  static void show(BuildContext context, {required String orderId, String driverName = 'Suresh Solanki', String driverPhone = '+91 98980 12345'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DriverChatDialog(
        orderId: orderId,
        driverName: driverName,
        driverPhone: driverPhone,
      ),
    );
  }

  @override
  State<DriverChatDialog> createState() => _DriverChatDialogState();
}

class _DriverChatDialogState extends State<DriverChatDialog> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<String> _quickPrompts = [
    "I'm at the gate/door",
    "Please call when you arrive",
    "Cash on delivery is ready",
    "Leave with building security",
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    DriverChatService.sendMessage(
      orderId: widget.orderId,
      senderId: 'cust-ahmedabad-01',
      senderName: 'Kavya Sharma',
      senderRole: 'customer',
      text: text.trim(),
    );
    _msgCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: const Text('EN ROUTE', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Text('Delivery Partner • ${widget.driverPhone}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Quick Prompt Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickPrompts.map((prompt) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(prompt, style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      onPressed: () => _send(prompt),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Messages Stream
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: DriverChatService.watchChat(widget.orderId),
              initialData: DriverChatService.getMessages(widget.orderId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderRole == 'customer';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : Colors.grey.shade100,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.black45,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Text Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: 'Message driver (e.g. landmark, gate code)...',
                      hintStyle: const TextStyle(fontSize: 12),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => _send(_msgCtrl.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
