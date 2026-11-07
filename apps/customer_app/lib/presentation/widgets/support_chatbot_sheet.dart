import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:core/core.dart';

class SupportChatbotSheet extends StatefulWidget {
  const SupportChatbotSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SupportChatbotSheet(),
    );
  }

  @override
  State<SupportChatbotSheet> createState() => _SupportChatbotSheetState();
}

class _SupportChatbotSheetState extends State<SupportChatbotSheet> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    SupportChatbotService.sendUserMessage(text.trim());
    _textCtrl.clear();
    Future.delayed(const Duration(milliseconds: 150), () {
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
      height: MediaQuery.of(context).size.height * 0.85,
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
                  backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                  child: const Icon(Icons.smart_toy_rounded, color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('FashionBot Support AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(width: 6),
                          Icon(Icons.verified_rounded, color: AppColors.accent, size: 14),
                        ],
                      ),
                      Text('Hyperlocal Assistant • Instant Resolution', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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

          // Messages
          Expanded(
            child: StreamBuilder<List<SupportChatMessage>>(
              stream: SupportChatbotService.stream,
              initialData: SupportChatbotService.history,
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.isUser;

                    return Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUser ? AppColors.primary : Colors.grey.shade100,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),

                        // Action Suggestion Chips
                        if (!isUser && msg.actionSuggestions != null && msg.actionSuggestions!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: msg.actionSuggestions!.map((s) {
                                return ActionChip(
                                  label: Text(s, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                                  onPressed: () => _send(s),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
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
                    controller: _textCtrl,
                    decoration: InputDecoration(
                      hintText: 'Ask about sizing, orders, exchanges, refund...',
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
                  backgroundColor: AppColors.accent,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => _send(_textCtrl.text),
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
