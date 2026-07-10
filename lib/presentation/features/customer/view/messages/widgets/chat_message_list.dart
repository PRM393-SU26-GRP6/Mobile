import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/chat_date_separator.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/chat_message_bubble.dart';
import 'package:flutter/material.dart';

class ChatMessageList extends StatelessWidget {
  final ScrollController controller;
  final List<MessageModel> messages;
  final bool isLoadingOlder;
  final String? currentUserId;
  final String myRole;
  final String partnerRole;

  const ChatMessageList({
    super.key,
    required this.controller,
    required this.messages,
    required this.isLoadingOlder,
    required this.currentUserId,
    required this.myRole,
    required this.partnerRole,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (isLoadingOlder ? 1 : 0),
      itemBuilder: (context, index) {
        if (isLoadingOlder && index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final messageIndex = index - (isLoadingOlder ? 1 : 0);
        final message = messages[messageIndex];
        final isMe = message.senderId == currentUserId;
        return Column(
          children: [
            if (_shouldShowDate(messageIndex))
              ChatDateSeparator(date: message.sentAt),
            ChatMessageBubble(
              message: message,
              isMe: isMe,
              senderRoleLabel: isMe ? myRole : partnerRole,
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowDate(int index) {
    if (index == 0) return true;
    final currentDate = messages[index].sentAt;
    final previousDate = messages[index - 1].sentAt;
    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }
}
