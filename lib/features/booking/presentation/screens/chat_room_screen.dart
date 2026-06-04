import 'package:flutter/material.dart';

import '../../data/booking_mock_data.dart';
import '../../domain/booking_models.dart';
import '../widgets/booking_ui.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({required this.ownerName, required this.onBack, super.key});

  final String ownerName;
  final VoidCallback onBack;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _controller = TextEditingController();
  final _messages = List<ChatMessage>.of(initialChatMessages);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(sender: 'customer', text: text, time: '09:30', read: false));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BookingShell(
      key: const ValueKey('chat'),
      child: Column(
        children: [
          _ChatHeader(ownerName: widget.ownerName, onBack: widget.onBack),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return const Center(child: BookingSoftChip(label: 'Hôm nay'));
                return _MessageBubble(message: _messages[index - 1]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: const BoxDecoration(color: bookingSurface, border: Border(top: BorderSide(color: bookingLine))),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.image_outlined)),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: bookingLine)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  heroTag: 'send-message',
                  onPressed: _send,
                  backgroundColor: bookingPrimary,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.ownerName, required this.onBack});

  final String ownerName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, MediaQuery.paddingOf(context).top + 8, 12, 10),
      decoration: const BoxDecoration(color: bookingSurface, border: Border(bottom: BorderSide(color: bookingLine))),
      child: Row(
        children: [
          IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
          const CircleAvatar(backgroundColor: bookingMint, foregroundColor: bookingPrimary, child: Icon(Icons.person_outline)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ownerName, style: const TextStyle(fontWeight: FontWeight.w900, color: bookingText)),
                const Text('Đang hoạt động', style: TextStyle(color: bookingMuted, fontSize: 12)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.sender == 'customer';
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: mine ? bookingPrimary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(mine ? 18 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 18),
                ),
                border: mine ? null : Border.all(color: bookingLine),
              ),
              child: Text(message.text, style: TextStyle(color: mine ? Colors.white : bookingText, height: 1.35)),
            ),
            const SizedBox(height: 4),
            Text(message.time, style: const TextStyle(color: bookingMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
