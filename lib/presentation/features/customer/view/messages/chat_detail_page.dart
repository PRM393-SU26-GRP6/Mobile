import 'dart:async';

import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/data/remote/signalr_service.dart';
import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/chat_conversation_header.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/chat_input_area.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/chat_message_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatRoomModel chatRoom;

  const ChatDetailPage({
    super.key,
    required this.chatRoom,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  static const int _pageSize = 30;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];

  bool _isLoading = true;
  bool _isLoadingOlder = false;
  bool _hasMoreOlder = true;
  bool _isSending = false;
  int _currentPage = 1;
  String? _currentUserId;
  String? _currentUserRole;
  StreamSubscription? _chatSubscription;

  String get _chatPartnerName => widget.chatRoom.getPartnerName(_currentUserId);
  String get _partnerRole => widget.chatRoom.getPartnerRoleLabelForAuthRole(
        _currentUserId,
        _currentUserRole,
      );
  String get _myRole => widget.chatRoom.getCurrentUserRoleLabelForAuthRole(
        _currentUserId,
        _currentUserRole,
      );

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadInitialMessages();
    _scrollController.addListener(_onScroll);
    _initSignalR();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingOlder || !_hasMoreOlder) {
      return;
    }
    if (_scrollController.position.pixels <= 80) {
      _loadOlderMessages();
    }
  }

  void _initSignalR() {
    final signalRService = Get.find<SignalRService>();
    signalRService.initChatConnection().then((_) {
      signalRService.joinChatRoom(widget.chatRoom.roomId);
    });

    _chatSubscription = signalRService.onChatMessageReceived.listen((msgData) {
      if (!mounted) return;
      if (msgData['roomId'] == widget.chatRoom.roomId) {
        _loadInitialMessages();
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      final apiService = Get.find<ApiServiceImpl>();
      final userId = await apiService.getUserId();
      final userRole = await apiService.getUserRole();
      if (mounted && userId != null) {
        setState(() {
          _currentUserId = userId;
          _currentUserRole = userRole;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadInitialMessages() async {
    try {
      final apiService = Get.find<ApiServiceImpl>();
      await _loadCurrentUser();

      final messages = await apiService.getChatMessages(
        roomId: widget.chatRoom.roomId,
        pageNumber: 1,
        pageSize: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _currentPage = 1;
        _hasMoreOlder = messages.length == _pageSize;
        _messages
          ..clear()
          ..addAll(_sortAscending(messages));
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingOlder || !_hasMoreOlder) return;
    setState(() {
      _isLoadingOlder = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final beforeHeight = _scrollController.hasClients
          ? _scrollController.position.maxScrollExtent
          : 0.0;
      final apiService = Get.find<ApiServiceImpl>();
      final older = await apiService.getChatMessages(
        roomId: widget.chatRoom.roomId,
        pageNumber: nextPage,
        pageSize: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _currentPage = nextPage;
        _hasMoreOlder = older.length == _pageSize;
        final knownIds = _messages.map((m) => m.messageId).toSet();
        _messages.insertAll(
          0,
          _sortAscending(older)
              .where((message) => !knownIds.contains(message.messageId)),
        );
        _isLoadingOlder = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        final afterHeight = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(afterHeight - beforeHeight + 80);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingOlder = false;
        });
      }
    }
  }

  List<MessageModel> _sortAscending(List<MessageModel> messages) {
    return [...messages]..sort((a, b) => a.sentAt.compareTo(b.sentAt));
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
      await _loadInitialMessages();
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
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          children: [
            Text(_chatPartnerName),
            const SizedBox(height: 2),
            Text(
              '${widget.chatRoom.contextLabel} - Bạn là $_myRole',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                ChatConversationHeader(partnerRole: _partnerRole),
                Expanded(
                  child: ChatMessageList(
                    controller: _scrollController,
                    messages: _messages,
                    isLoadingOlder: _isLoadingOlder,
                    currentUserId: _currentUserId,
                    myRole: _myRole,
                    partnerRole: _partnerRole,
                  ),
                ),
                ChatInputArea(
                  controller: _messageController,
                  isSending: _isSending,
                  onSend: _sendMessage,
                ),
              ],
            ),
    );
  }
}
