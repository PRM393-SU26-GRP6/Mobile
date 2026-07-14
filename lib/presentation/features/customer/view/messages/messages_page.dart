import 'package:dio/dio.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/presentation/features/customer/view/messages/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesPage extends StatefulWidget {
  final bool showBackButton;

  const MessagesPage({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<ChatRoomModel> _chatRooms = [];
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadChatRooms();
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

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = Get.find<ApiServiceImpl>();
      final rooms = await apiService.getChatRooms();

      if (mounted) {
        setState(() {
          _chatRooms = rooms;
          _isLoading = false;
        });
      }
    } on DioException catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Không thể tải danh sách chat';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Đã xảy ra lỗi';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            if (widget.showBackButton)
              IconButton(
                onPressed: Get.back,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              )
            else
              const SizedBox(width: 48),
            const Expanded(
              child: Text(
                'Tin nhắn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.red.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChatRooms,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_chatRooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.accent),
            SizedBox(height: 16),
            Text(
              'Không có tin nhắn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Các tin nhắn với chủ sân sẽ hiển thị tại đây',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChatRooms,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _chatRooms.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
        itemBuilder: (context, index) {
          return _buildChatRoomTile(_chatRooms[index]);
        },
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoomModel room) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primary,
        child: Text(
          room.getPartnerAvatarText(_currentUserId),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        room.getPartnerName(_currentUserId),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '${room.contextLabel} - ${room.getPartnerRoleLabelForAuthRole(
          _currentUserId,
          _currentUserRole,
        )}'
        ' - ${room.lastMessagePreview ?? 'Chưa có tin nhắn'}',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (room.lastMessageTime != null)
            Text(
              room.timeAgo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          const SizedBox(height: 4),
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
      onTap: () {
        Get.to(
          () => ChatDetailPage(chatRoom: room),
          transition: Transition.rightToLeft,
        );
      },
    );
  }
}
