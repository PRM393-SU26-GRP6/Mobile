import 'package:flutter/material.dart';

import '../../data/booking_mock_data.dart';
import '../../domain/booking_models.dart';
import '../widgets/booking_ui.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({required this.onSelect, super.key});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return BookingShell(
      key: const ValueKey('conversations'),
      child: Column(
        children: [
          const BookingTopBar(title: 'Tin nhắn'),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm hội thoại...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: bookingMint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
              itemCount: bookingConversations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final conversation = bookingConversations[index];
                return _ConversationTile(conversation: conversation, onTap: () => onSelect(conversation.name));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      onTap: onTap,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: bookingMint,
                foregroundColor: bookingPrimary,
                child: Icon(conversation.isGroup ? Icons.groups_outlined : Icons.person_outline),
              ),
              if (conversation.online)
                const Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 6, backgroundColor: bookingPrimaryLight)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(conversation.name, style: const TextStyle(fontWeight: FontWeight.w900))),
                    Text(
                      conversation.time,
                      style: TextStyle(
                        color: conversation.unread > 0 ? bookingPrimary : bookingMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: bookingMuted),
                      ),
                    ),
                    if (conversation.unread > 0)
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: bookingPrimary,
                        child: Text('${conversation.unread}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
