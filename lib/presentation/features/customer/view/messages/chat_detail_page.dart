import 'dart:async';

import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/booking_context_card.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/chat_date_separator.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/chat_message_bubble.dart';
import 'package:exe101/data/remote/signalr_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatRoomModel chatRoom;
  final BookingDto? bookingContext;

  const ChatDetailPage({
    super.key,
    required this.chatRoom,
    this.bookingContext,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;
  StreamSubscription? _chatSubscription;

  String get _chatPartnerName => widget.chatRoom.getPartnerName(_currentUserId);

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
    _initSignalR();
  }

  void _initSignalR() {
    final signalRService = Get.find<SignalRService>();
    signalRService.initChatConnection().then((_) {
      signalRService.joinChatRoom(widget.chatRoom.roomId);
    });

    _chatSubscription = signalRService.onChatMessageReceived.listen((msgData) {
      if (!mounted) return;
      // Convert map to MessageModel and append
      if (msgData['roomId'] == widget.chatRoom.roomId) {
        // To be completely safe and avoid missing messages or duplicating, 
        // we can just reload the message list when a new message event arrives
        _loadMessages();
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      final apiService = Get.find<ApiServiceImpl>();
      final userId = await apiService.getUserId();
      if (mounted && userId != null) {
        setState(() {
          _currentUserId = userId;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadMessages() async {
    try {
      final apiService = Get.find<ApiServiceImpl>();
      await _loadCurrentUser();

      final messages = await apiService.getChatMessages(
        roomId: widget.chatRoom.roomId,
      );

      if (mounted) {
        setState(() {
          _messages.clear();
          messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
          _messages.addAll(messages);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final apiService = Get.find<ApiServiceImpl>();
      await apiService.sendMessage(
        roomId: widget.chatRoom.roomId,
        messageText: text,
      );

      _messageController.clear();
      await _loadMessages();
    } catch (_) {
      Get.snackbar(
        'Lỗi',
        'Không thể gửi tin nhắn. Vui lòng thử lại.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    final signalRService = Get.find<SignalRService>();
    signalRService.leaveChatRoom(widget.chatRoom.roomId);
    _messageController.dispose();
    super.dispose();
  }

  bool _shouldShowDate(int index) {
    if (index == 0) return true;
    final currentDate = _messages[index].sentAt;
    final previousDate = _messages[index - 1].sentAt;
    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }

  void _showBookingDetails() {
    final booking = widget.bookingContext;
    if (booking == null) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.inputBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Chi tiết đơn đặt sân',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                BookingContextCard(booking: booking),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(_chatPartnerName),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                if (widget.bookingContext != null)
                  BookingContextCard(
                    booking: widget.bookingContext!,
                    onViewDetails: _showBookingDetails,
                  ),
                Expanded(child: _buildMessageList()),
                _buildInputArea(),
              ],
            ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      reverse: false,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId == _currentUserId;
        return Column(
          children: [
            if (_shouldShowDate(index)) ChatDateSeparator(date: message.sentAt),
            ChatMessageBubble(message: message, isMe: isMe),
          ],
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
